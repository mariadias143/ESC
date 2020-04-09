c NPROCS = 32 CLASS = C
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        integer            na, nonzer, niter
        double precision   shift, rcond
        parameter(  na=150000,
     >              nonzer=15,
     >              niter=75,
     >              shift=110.,
     >              rcond=1.0d-1 )

c number of nodes for which this version is compiled
        integer    nnodes_compiled
        parameter( nnodes_compiled = 32)
        integer    num_proc_cols, num_proc_rows
        parameter( num_proc_cols=8, num_proc_rows=4 )
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
