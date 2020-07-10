#!/bin/sh
# partrace.sh - a helper script to dtrace Open MPI jobs from the
#		start of the job.

dtrace -Fs $1  -c /export/home/a82523/TP3/MPI/mpi -o $OMPI_COMM_WORLD_RANK.$2.trace
