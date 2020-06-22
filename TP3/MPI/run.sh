gmake

/usr/local/bin/mpirun -n 8 -display-map --map-by core --mca btl vader,self ./mpi 1024
