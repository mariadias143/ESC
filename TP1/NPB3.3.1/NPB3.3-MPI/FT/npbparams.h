c NPROCS = 32 CLASS = C
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        integer nx, ny, nz, maxdim, niter_default, ntdivnp, np_min
        parameter (nx=512, ny=512, nz=512, maxdim=512)
        parameter (niter_default=20)
        parameter (np_min = 32)
        parameter (ntdivnp=((nx*ny)/np_min)*nz)
        double precision ntotal_f
        parameter (ntotal_f=1.d0*nx*ny*nz)
        logical  convertdouble
        parameter (convertdouble = .false.)
        character*11 compiletime
        parameter (compiletime='06 Apr 2020')
        character*5 npbversion
        parameter (npbversion='3.3.1')
        character*7 cs1
        parameter (cs1='mpifort')
        character*9 cs2
        parameter (cs2='$(MPIF77)')
        character*5 cs3
        parameter (cs3='-lmpi')
        character*6 cs4
        parameter (cs4='(none)')
        character*6 cs5
        parameter (cs5='(none)')
        character*6 cs6
        parameter (cs6='(none)')
        character*6 cs7
        parameter (cs7='randi8')
