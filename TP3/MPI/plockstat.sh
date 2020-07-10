#!/bin/sh

/usr/local/bin/mpirun -n 4 --map-by core --mca btl vader,self /export/home/a82523/TP3/MPI/dtrace_mpi.sh /export/home/a82523/TP3/plockstat.d $1
