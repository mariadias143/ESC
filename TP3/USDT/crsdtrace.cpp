#include "crsdtrace.h"
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

CRS::CRS(int n_rows,int n_cols,float p_non_zeros,bool balanced){
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

void CRS::transform(){
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

void CRS::print(){
    cout << "Matrx" << endl;

    for (int i = 0; i < ROWS; i++)
    {
        for (int j = 0; j < COLS; j++)
        {
            cout << matrix[i*COLS + j] << " - ";
        }
            cout << endl;
    }

    cout << "Non zeros values" << endl;
    for (int i = 0; i < zeros; i++)
    {
        cout << non_zero_values[i] << " - ";
    }
    cout << endl << "Non non_zero_acu" << endl;
    for (int i = 0; i < (ROWS + 1); i++)
    {
        cout << non_zero_acu[i] << " - ";
    }
    cout << endl << "Non non_zero_pos" << endl;
    for (int i = 0; i < zeros; i++)
    {
        cout << non_zero_pos[i] << " - ";
    }
    cout << endl;
}

void CRS::sequencial(){

  /**
  if (SPARSEGET_QUERY_USERENTRY_ENABLED())
    SPARSEGET_QUERY_USERENTRY();*/

  for(int i = 0; i < ROWS; i++){
    int k = non_zero_acu[i];
    int limit = non_zero_acu[i+1];
    /*
    if (SPARSEGET_QUERY_CHARGE_ENABLED())
      SPARSEGET_QUERY_CHARGE(i, limit-k);*/

    float res = 0;

    for(; k < limit; k++){
        res += non_zero_values[k] * vector[non_zero_pos[k]];
    }
    result[i] = res;
  }

  /*
  if (SPARSEGET_QUERY_USEREXIT_ENABLED())
    SPARSEGET_QUERY_USEREXIT();*/
}
