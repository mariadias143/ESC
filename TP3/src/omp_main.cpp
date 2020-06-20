#include "crs_omp.h"
#include <cstdlib>
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

int main(int argc, char *argv[]) {

  srand(1);
  int SIZE = argc > 1 ? atoi(argv[1]) : 4096;
  int bcd = argc > 2 ? atoi(argv[2]) : 1;

  int ROWS = SIZE;
  int COLS = SIZE;
  bool balanced = bcd == 1;

  CRS * server = new CRS(ROWS,COLS,0.2,balanced);
  double start = omp_get_wtime();
  server->sequencial();
  double end = omp_get_wtime();
  printf("time: %f seconds.\n", end-start);
  return 0;
}
