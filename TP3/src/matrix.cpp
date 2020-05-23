#include "matrix.h"

float RAND_NUMBERS = 10.0;
float MIN = 9.0;
float MAX = 10.0;

void mult_mat(int ROWS,int COLS, float * m1,float * vector,float * result){
    for(int i = 0; i < ROWS; i++){
        float res = 0.0;
        for (int j = 0; j < COLS; j++){
            res += m1[i*COLS + j] * vector[j];
        }
        result[i] = res;
    }
}


void rand_vector(int N,float * vector){
    for(int i = 0; i < N; i++){
        vector[i] = ((float)rand()/(float)(RAND_MAX)) * RAND_NUMBERS;
    }
}

void rand_sparse_vec(int N_ROWS,int N_COLS, float * matrix,float p_non_zeros){
    int n_zeros = ceil(N_COLS*p_non_zeros) * N_ROWS;
    //int * index_non_zeros = malloc(sizeof(int)*n_zeros);
    int * index_non_zeros = new int[n_zeros];
    int n_elem = N_ROWS*N_COLS;
    //int * mat_hash = malloc(sizeof(int)*n_elem);
    int * mat_hash = new int[n_elem];

    for(int i = 0; i < n_elem; i++)
         mat_hash[i] = 0;

    int k = 0;
    int rand_index;

    while(k < n_zeros){
        int flag = 0;

        while(!flag){
            rand_index = rand() % n_elem;
            if(mat_hash[rand_index] == 0){
                flag = 1;
            }
        }
        mat_hash[rand_index] = 1;
        index_non_zeros[k++] = rand_index;
    }

    for(int i = 0; i < N_ROWS; i++)
         for(int j = 0; j < N_COLS; j++)
             matrix[i*N_COLS + j] = 0.0;

     for(int i = 0; i < n_zeros; i++){
         matrix[index_non_zeros[i]] = ((float)rand()/(float)(RAND_MAX)) * RAND_NUMBERS;
     }

     delete [] index_non_zeros;
     delete [] mat_hash;
 }

void rand_sparse_vec_balanced(int N_ROWS,int N_COLS, float * matrix,float p_non_zeros){
   int n_zeros = ceil(N_COLS*p_non_zeros) * N_ROWS;
   //int * index_non_zeros = malloc(sizeof(int)*n_zeros);
   int * index_non_zeros = new int[n_zeros];
   int n_elem = N_ROWS*N_COLS;
   //int * mat_hash = malloc(sizeof(int)*n_elem);
   int * mat_hash = new int[n_elem];
   int n_zeros_row = ceil(N_COLS*p_non_zeros);


   for(int i = 0; i < n_elem; i++)
        mat_hash[i] = 0;

   int k = 0;
   int t = 0;
   int rand_index;

   for(int i = 0; i < N_ROWS; i++){
       int lower_barrier = i*N_COLS;
       int upper_barrier = (i+1)*N_COLS;
       while(k < n_zeros_row){
           int flag = 0;

           while(!flag){
               rand_index = (rand() % (upper_barrier - lower_barrier)) + lower_barrier;
               if(mat_hash[rand_index] == 0){
                    flag = 1;
               }
           }
           mat_hash[rand_index] = 1;
           index_non_zeros[t++] = rand_index;
           k++;
       }
       k = 0;
   }

    for(int i = 0; i < N_ROWS; i++)
        for(int j = 0; j < N_COLS; j++)
            matrix[i*N_COLS + j] = 0.0;

    for(int i = 0; i < n_zeros; i++){
        matrix[index_non_zeros[i]] = ((float)rand()/(float)(RAND_MAX)) * RAND_NUMBERS;
    }

    delete [] index_non_zeros;
    delete [] mat_hash;
}
