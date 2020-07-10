#include "matrix.h"
#include <ostream>
#include <iostream>
#include <mpi.h>
#include "crs_mpi.h"
#include <cstdlib>
using namespace std;

double starting_time;
double ending_time;

double Tcomm;
double Tfree;
double Tcomp;

void setTimer(){
    Tcomm = 0.0;
    Tfree = 0.0;
    Tcomp = 0.0;
    starting_time = MPI_Wtime();
}

void getMessage(MPI_Comm comm){
    MPI_Status status;
    double init = MPI_Wtime();
    MPI_Probe(MPI_ANY_SOURCE,MPI_ANY_TAG,comm,&status);
    Tfree += MPI_Wtime() - init;
}

void endTimer(int SIZE,int CHUNK_SIZE,int balanced,int id){
    ending_time = MPI_Wtime();

    double total_time_exectuted = ending_time - starting_time;
    double per_comm = (Tcomm / total_time_exectuted) * 100.0;
    double per_free = (Tfree / total_time_exectuted) * 100.0;
    double per_comp = (Tcomp / total_time_exectuted) * 100.0;

    printf("%d;%5.5lf;%3.2lf;%3.2lf;%3.2lf;\n",id,total_time_exectuted,per_comm,per_free,per_comp);
}

void endTimerMaster(int SIZE,int CHUNK_SIZE,int balanced,int nprocesses){
    ending_time = MPI_Wtime();

    double total_time_exectuted = ending_time - starting_time;
    double per_comm = (Tcomm / total_time_exectuted) * 100.0;
    double per_free = (Tfree / total_time_exectuted) * 100.0;
    double per_comp = (Tcomp / total_time_exectuted) * 100.0;

    printf("MASTER;%5.5lf;%3.2lf;%3.2lf;%3.2lf;\n",total_time_exectuted,per_comm,per_free,per_comp);
}

int main(int argc, char *argv[])
{
    srand(1);
    int nprocesses;
    int myrank;

    MPI_Status status;
    MPI_Init(&argc, &argv);

    MPI_Comm_size(MPI_COMM_WORLD, &nprocesses);
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

    double time_init;

    int SIZE = argc > 1 ? atoi(argv[1]) : 4096;
    int chunk_size = argc > 2 ? atoi(argv[2]) : 256;
    int SEED = argc > 3 ? atoi(argv[3]) : 1;
    int bcd = argc > 4 ? atoi(argv[4]) : 1;

    bool balanced = bcd == 1;

    int ROWS = SIZE;
    int COLS = SIZE;


    if (myrank == 0){
        MasterYale * server = new MasterYale(ROWS,COLS,0.2,balanced);
        server->setWorkLoad(chunk_size);
        float * receiving_work_buffer = new float[chunk_size];
        float * sending_work_buffer = new float[chunk_size*COLS];

        MPI_Barrier(MPI_COMM_WORLD);

        cout << "Starting: " << SIZE << endl;
        setTimer();

        time_init = MPI_Wtime();
        MPI_Bcast(server->vector,COLS,MPI_FLOAT,0,MPI_COMM_WORLD); //comunicação
        MPI_Bcast(server->non_zero_acu,ROWS+1,MPI_INT,0,MPI_COMM_WORLD);//comunicação
        Tcomm += MPI_Wtime() - time_init;

        int calculated_rows = 0;
        int written_at_buffer = 0;
        int count;

        while (calculated_rows != ROWS){
            getMessage(MPI_COMM_WORLD); //Tfree

            time_init = MPI_Wtime();
            MPI_Recv(receiving_work_buffer,chunk_size,MPI_FLOAT,MPI_ANY_SOURCE,MPI_ANY_TAG,MPI_COMM_WORLD,&status); // comunicação
            Tcomm += MPI_Wtime() - time_init;

            time_init = MPI_Wtime();

            int tag = status.MPI_TAG;
            int origin = status.MPI_SOURCE;
            MPI_Get_count(&status, MPI_INT, &count);

            double Tcomm_getWork = 0.0;
            double control_message = 0.0;

            if (count == 0){
                Tcomm_getWork = server->getWorkLoad(origin);
            }
            else{
                calculated_rows += chunk_size;
                server->saveWorkLoad(receiving_work_buffer,tag);

                if (calculated_rows != ROWS){
                    Tcomm_getWork = server->getWorkLoad(origin); //comunicação
                }
                else {
                    control_message = MPI_Wtime();
                    MPI_Send(sending_work_buffer,0,MPI_FLOAT,origin,0,MPI_COMM_WORLD); //comunicação
                    control_message = MPI_Wtime() - control_message;
                }
            }
            Tcomp += MPI_Wtime() - time_init - Tcomm_getWork - control_message;
            Tcomm += Tcomm_getWork + control_message;
        }

        endTimerMaster(SIZE,chunk_size,balanced,nprocesses);

        //controlo de erros
        float * result2 = new float[ROWS];
        mult_mat(ROWS,COLS,server->matrix,server->vector,result2);
        for (int c = 0; c < ROWS; c++){
            if (server->result[c] != result2[c]){
                cout << "error at " << c << endl;
                break;
            }
        }
    }
    else {
        float * vector = new float[COLS];
        int * non_zero_acu = new int[ROWS+1];

        float * receiving_work_values = new float[chunk_size*COLS];
        int * receiving_work_pos = new int[chunk_size*COLS];
        float * sending_buffer = new float[chunk_size];

        MPI_Barrier(MPI_COMM_WORLD);

        double init;

        setTimer();

        double initTfree = MPI_Wtime();

        init = MPI_Wtime();
        MPI_Bcast(vector,COLS,MPI_FLOAT,0,MPI_COMM_WORLD);
        Tcomm += MPI_Wtime() - init;

        init = MPI_Wtime();
        MPI_Bcast(non_zero_acu,ROWS+1,MPI_INT,0,MPI_COMM_WORLD);
        Tcomm += MPI_Wtime() - init;

        Tfree += MPI_Wtime() - initTfree - Tcomm;

        init = MPI_Wtime();
        MPI_Send(sending_buffer,0,MPI_FLOAT,0,0,MPI_COMM_WORLD);
        Tcomm += MPI_Wtime() - init;

        int count = 0;

        while (1){
            getMessage(MPI_COMM_WORLD);
            init = MPI_Wtime();
            MPI_Recv(receiving_work_values,chunk_size*COLS,MPI_FLOAT,0,MPI_ANY_TAG,MPI_COMM_WORLD,&status);
            Tcomm += MPI_Wtime() - init;

            MPI_Get_count(&status, MPI_INT, &count);
            if (count == 0)
                break;

            getMessage(MPI_COMM_WORLD);
            init = MPI_Wtime();
            MPI_Recv(receiving_work_pos,chunk_size*COLS,MPI_INT,0,MPI_ANY_TAG,MPI_COMM_WORLD,&status);
            Tcomm += MPI_Wtime() - init;

            MPI_Get_count(&status, MPI_INT, &count);
            if (count == 0)
                break;

            int offset = status.MPI_TAG;

            init = MPI_Wtime();
            for(int i = 0; i < chunk_size; i++){
                int k = non_zero_acu[i+offset] - non_zero_acu[offset];
                int limit = non_zero_acu[i+1+offset] - non_zero_acu[offset];
                float result = 0.0;

                for(; k < limit; k++)
                    result += receiving_work_values[k] * vector[receiving_work_pos[k]];
                sending_buffer[i] = result;
            }
            Tcomp += MPI_Wtime() - init;

            init = MPI_Wtime();
            MPI_Send(sending_buffer,chunk_size,MPI_FLOAT,0,offset,MPI_COMM_WORLD);
            Tcomm += MPI_Wtime() - init;
        }
        endTimer(SIZE,chunk_size,balanced,myrank);
    }

    MPI_Finalize();
    return 0;
}
