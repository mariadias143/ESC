#include "matrix.h"
#include <ostream>
#include <iostream>
#include <mpi.h>

using namespace std;

class MasterYale {
    int COLS;
    int ROWS;
    int zeros;

    int chunk_size;
    int work_sent;

    public:
        float * matrix;
        float * non_zero_values;
        int * non_zero_acu;
        int * non_zero_pos;
        float * vector;
        float * result;

        MasterYale(int n_rows,int n_cols,float p_non_zeros,bool balanced);
        void print();
        void setWorkLoad(int chunk_size);
        double getWorkLoad(int destination);
        void saveWorkLoad(float * buffer,int offset);

    private:
        void transform();
};
