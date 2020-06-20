#include "matrix.h"
#include <ostream>
#include <iostream>
#include <omp.h>
#include <stdio.h>
#include <pthread.h>


int thread_count = 4;

float * matrix;
float * non_zero_values;
int * non_zero_acu;
int * non_zero_pos;
float * vector;
float * result;

int ROWS;
int COLS;
int zeros;

int current_i = 0;

pthread_mutex_t mutex;

void transform(){
  int n_nonzeros = 0;
  non_zero_acu[0] = 0;

  for(int i = 0; i < ROWS; i++){
    int n_nonzeros_row = 0;
    for (int j = 0; j < COLS; j++)
    {
        if (matrix[i*COLS + j] != 0.0){
            non_zero_values[n_nonzeros] = matrix[i*COLS + j];
            non_zero_pos[n_nonzeros] = j;
            n_nonzeros++;
            n_nonzeros_row++;
        }
    }
    non_zero_acu[i+1] = non_zero_acu[i] + n_nonzeros_row;
  }
}

void init(int n_rows,int n_cols,float p_non_zeros,bool balanced){
  int n_elem = n_rows * n_cols;
  int n_zeros = ceil(n_cols*p_non_zeros) * n_rows;

  matrix = new float[n_elem];

  non_zero_values = new float[n_zeros];
  non_zero_acu = new int[n_rows+1];
  non_zero_pos = new int[n_zeros];

  vector = new float[n_cols];
  result = new float[n_rows];

  if (balanced)
      rand_sparse_vec_balanced(n_rows,n_cols,matrix,p_non_zeros);
  else{
      rand_sparse_vec(n_rows,n_cols,matrix,p_non_zeros);
  }
  rand_vector(n_cols,vector);

  for(int i = 0; i < n_rows; i++)
      result[i] = 0.0;

  ROWS = n_rows;
  COLS = n_cols;

  transform();

  zeros = n_zeros;
}

void * pth_thread_work(void * rank){
  int local_i = 0;
  pthread_mutex_lock(&mutex);
  local_i = current_i;
  current_i += 128;
  pthread_mutex_unlock(&mutex);

  while (local_i < ROWS) {
    int max = local_i + 128;
    for(; local_i < max; local_i++){
      int k = non_zero_acu[local_i];
      int limit = non_zero_acu[local_i+1];
      float res = 0.0;

      for(; k < limit; k++){
          res += non_zero_values[k] * vector[non_zero_pos[k]];
      }

      result[local_i] = res;
    }

    pthread_mutex_lock(&mutex);
    local_i = current_i;
    current_i += 128;
    pthread_mutex_unlock(&mutex);
  }

  return NULL;
}

void openmp(){
  double start = omp_get_wtime();
  #pragma omp parallel
  {
      #pragma omp single
      {
        for(int i = 0; i < ROWS; i+= 64){
          #pragma omp task firstprivate(i)
          {
            int max = i + 64;
            for(; i < max; i++){
              int k = non_zero_acu[i];
              int limit = non_zero_acu[i+1];
              float res = 0.0;

              for(; k < limit; k++){
                  res += non_zero_values[k] * vector[non_zero_pos[k]];
              }

              result[i] = res;
            }
          }
        }
        #pragma omp taskwait
      }
  }
  double end = omp_get_wtime();
  printf("Para Open Run: %f seconds.\n", end-start);
}

void validation(){
  float * result_test = new float[ROWS];
  double start = omp_get_wtime();
  for(int i = 0; i < ROWS; i++){
    int k = non_zero_acu[i];
    int limit = non_zero_acu[i+1];
    float res = 0;

    for(; k < limit; k++){
        res += non_zero_values[k] * vector[non_zero_pos[k]];
    }
    result_test[i] = res;
  }
  double end = omp_get_wtime();
  printf("Seq Run: %f seconds.\n", end-start);

  for(int i = 0; i < ROWS; i++){
    if (result_test[i] != result[i]){
      std::cout << "error on validation" << std::endl;
      break;
    }
  }
  delete [] result_test;
}

int main(int argc, char const *argv[]) {
  long thread;
  pthread_t* thread_handles;

  srand(1);

  int size = argc >= 2 ? atoi(argv[1]) : 1024;
  float per = argc >= 3 ? atof(argv[2]) : 0.2;
  thread_count = argc >= 4 ? atoi(argv[3]) : 4;

  init(size,size,per,true);

  pthread_mutex_init(&mutex,NULL);
  thread_handles = new pthread_t[thread_count];

  double start = omp_get_wtime();
  for (thread = 0; thread < thread_count; thread++){
    pthread_create(&thread_handles[thread],NULL,pth_thread_work,(void*) thread);
  }

  for (thread = 0; thread < thread_count; thread++){
    pthread_join(thread_handles[thread], NULL);
  }
  double end = omp_get_wtime();
  printf("Parallel Run: %f seconds.\n", end-start);

  validation();
  //openmp();

  return 0;
}
