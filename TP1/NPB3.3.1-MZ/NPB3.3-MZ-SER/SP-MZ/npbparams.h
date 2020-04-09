c CLASS = C
c  
c  
c  This file is generated automatically by the setparams utility.
c  It sets the number of processors and the class of the NPB
c  in this directory. Do not modify it by hand.
c  
        character class
        parameter (class='C')
        integer x_zones, y_zones
        parameter (x_zones=16, y_zones=16)
        integer gx_size, gy_size, gz_size, niter_default
        parameter (gx_size=480, gy_size=320, gz_size=28)
        parameter (niter_default=400)
        integer problem_size
        parameter (problem_size = 30)
        integer max_xysize
        integer proc_max_size, proc_max_size5, proc_max_bcsize
        parameter (max_xysize=158720)
        parameter (proc_max_size=max_xysize*gz_size)
        parameter (proc_max_size5=proc_max_size*5)
        parameter (proc_max_bcsize=max_xysize*20)
        double precision dt_default, ratio
        parameter (dt_default = 0.00067d0, ratio = 1.d0)
        integer start1, start5, qstart_west, qstart_east
        integer qstart_south, qstart_north
        logical  convertdouble
        parameter (convertdouble = .false.)
        character compiletime*11
        parameter (compiletime='07 Apr 2020')
        character npbversion*5
        parameter (npbversion='3.3.1')
        character cs1*5
        parameter (cs1='ifort')
        character cs2*6
        parameter (cs2='$(F77)')
        character cs3*6
        parameter (cs3='(none)')
        character cs4*6
        parameter (cs4='(none)')
        character cs5*2
        parameter (cs5='-O')
        character cs6*2
        parameter (cs6='-O')
        character cs7*6
        parameter (cs7='randi8')
