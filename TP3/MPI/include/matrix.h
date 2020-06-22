#include <time.h>
#include <math.h>
#include <cstdlib>

void mult_mat(int ROWS,int COLS, float * m1,float * vector,float * result);

void rand_sparse_vec(int N_ROWS,int N_COLS, float * matrix,float p_non_zeros);

void rand_sparse_vec_balanced(int N_ROWS,int N_COLS, float * matrix,float p_non_zeros);

void rand_vector(int N,float * vector);
