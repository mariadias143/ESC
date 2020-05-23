#include "crs_omp.h"

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
  for(int i = 0; i < ROWS; i++){
    int k = non_zero_acu[i];
    int limit = non_zero_acu[i+1];
    float res = 0;

    for(; k < limit; k++){
        res += non_zero_values[k] * vector[non_zero_pos[k]];
    }
    result[i] = res;
  }
}

void CRS::parallel(){
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
}
