#!/bin/sh

/usr/local/bin/mpirun -n 4 --map-by core --mca btl vader,self /export/home/a82523/TP3/MPI/pidmpi.sh /export/home/a82523/TP3/MPI/pidmpi.d $1
