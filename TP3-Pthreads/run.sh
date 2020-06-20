#PBS -N pthreads
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=48:r662
#PBS -q mei

module load gcc/5.3.0
module load gcc/7.2.0

cd $PBS_O_WORKDIR

make

./pthreads 1024 0.2 48
./pthreads 2048 0.2 48
./pthreads 4096 0.2 48
./pthreads 8192 0.2 48
./pthreads 16384 0.2 48
