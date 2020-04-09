c------------------------------------------------------------------
      subroutine setuppc
c------------------------------------------------------------------
c     Generate diagonal preconditioner for CG.
c     Preconditioner computed in this subroutine is correct only
c     for collocation point in element interior, on conforming face
c     interior and conforming edge.
c------------------------------------------------------------------

      include 'header.h'

      double precision dxtm1_2(lx1,lx1), rdtime
      integer ie,k,i,j,q,isize

      do j=1,lx1
        do i=1,lx1
          dxtm1_2(i,j)=dxtm1(i,j)**2
        end do
      end do

      rdtime=1.d0/dtime

      do ie = 1, nelt
        call r_init(dpcelm(1,1,1,ie),nxyz,0.d0)
        isize=size_e(ie)
        do k = 1, lx1
          do j = 1, lx1
            do i = 1, lx1
              do q = 1, lx1
                dpcelm(i,j,k,ie) = dpcelm(i,j,k,ie) + 
     &                        g1m1_s(q,j,k,isize) * dxtm1_2(i,q) +
     &                        g1m1_s(i,q,k,isize) * dxtm1_2(j,q) +
     &                        g1m1_s(i,j,q,isize) * dxtm1_2(k,q)
              end do
              dpcelm(i,j,k,ie)=visc*dpcelm(i,j,k,ie)+
     &                      rdtime*bm1_s(i,j,k,isize)
            end do
          end do
        end do
      end do

c.....do the stiffness summation
      call dssum

c.....take inverse.

      call reciprocal(dpcelm,ntot)

c.....compute preconditioner on mortar points. NOTE:  dpcmor for 
c     nonconforming cases will be corrected in subroutine setpcmo 
      do i=1,nmor
        dpcmor(i)=1.d0/dpcmor(i)
      end do

      return
      end


c--------------------------------------------------------------
      subroutine setpcmo_pre
c--------------------------------------------------------------
c     pre-compute elemental contribution to preconditioner  
c     for all situations
c--------------------------------------------------------------
      
      include 'header.h'

      integer element_size, i, j, ii, jj, col
      double precision
     &       p(lx1,lx1,lx1), p0(lx1,lx1,lx1), mtemp(lx1,lx1), 
     &       temp(lx1,lx1,lx1), temp1(lx1,lx1), tmp(lx1,lx1),tig(lx1)

c.....corners on face of type 3 

      call r_init(tcpre,lx1*lx1,0.d0)
      call r_init(tmp,lx1*lx1,0.d0)
      call r_init(tig,5,0.d0)
      tig(1)   =1.d0
      tmp(1,1) =1.d0 

c.....tcpre results from mapping a unit spike field (unity at 
c     collocation point (1,1), zero elsewhere) on an entire element
c     face to the (1,1) segment of a nonconforming face
      do i=2,lx1-1
        do j=1,lx1
          tmp(i,1) = tmp(i,1)+ qbnew(i-1,j,1)*tig(j)
        end do
      end do
 
      do col=1,lx1
        tcpre(col,1)=tmp(col,1)

        do j=2,lx1-1
          do i=1,lx1
            tcpre(col,j) = tcpre(col,j) + qbnew(j-1,i,1)*
     &                                     tmp(col,i)
          end do
        end do
      end do

      do element_size=1,refine_max

c.......for conforming cases

c.......pcmor_c (i,j,element_size) records the intermediate value 
c       (preconditioner=1/pcmor_c) of the preconditor on collocation 
c       point (i,j) on a conforming face of an element of size 
c       element_size.

        do j=1,lx1/2+1
          do i=j,lx1/2+1
            call r_init(p,nxyz,0.d0)
            p(i,j,1)=1.d0
            call laplacian(temp,p,element_size)
            pcmor_c(i,j,element_size)=temp(i,j,1)
            pcmor_c(lx1+1-i,j,element_size)=temp(i,j,1)
            pcmor_c(j,i,element_size)=temp(i,j,1)
            pcmor_c(lx1+1-j,i,element_size)=temp(i,j,1)
            pcmor_c(j,lx1+1-i,element_size)=temp(i,j,1)
            pcmor_c(lx1+1-j,lx1+1-i,element_size)=temp(i,j,1)
            pcmor_c(i,lx1+1-j,element_size)=temp(i,j,1)
            pcmor_c(lx1+1-i,lx1+1-j,element_size)=temp(i,j,1)
          end do
        end do

c.......for nonconforming cases 

c.......nonconforming face interior

c.......pcmor_nc1(i,j,ii,jj,element_size) records the intermediate 
c       preconditioner value on collocation point (i,j) on mortar 
c       (ii,jj)  on a nonconforming face of an element of size element_
c       size
        do j=2,lx1
          do i=j,lx1
            call r_init(mtemp,lx1*lx1,0.d0)
            call r_init(p,nxyz,0.d0)
            mtemp(i,j)=1.d0
c...........when i, j=lx1, mortar points are duplicated, so mtemp needs
c           to be doubled.
            if(i.eq.lx1)mtemp(i,j)=mtemp(i,j)*2.d0
            if(j.eq.lx1)mtemp(i,j)=mtemp(i,j)*2.d0
            call transf_nc(mtemp,p)
            call laplacian(temp,p,element_size)
            call transfb_nc1(temp1,temp)

c...........values at points (i,j) and (j,i) are the same
            pcmor_nc1(i,j,1,1,element_size)=temp1(i,j)
            pcmor_nc1(j,i,1,1,element_size)=temp1(i,j)
          end do

c.........when i, j=lx1, mortar points are duplicated. so pcmor_nc1 needs
c         to be doubled on those points
          pcmor_nc1(lx1,j,1,1,element_size)=
     &          pcmor_nc1(lx1,j,1,1,element_size)*2.d0
          pcmor_nc1(j,lx1,1,1,element_size)=
     &          pcmor_nc1(lx1,j,1,1,element_size)

        end do
        pcmor_nc1(lx1,lx1,1,1,element_size)=
     &      pcmor_nc1(lx1,lx1,1,1,element_size)*2.d0

c.......nonconforming edges
        j=1
        do i=2,lx1
          call r_init(mtemp,lx1*lx1,0.d0)
          call r_init(p,nxyz,0.d0)
          call r_init(p0,nxyz,0.d0)
          mtemp(i,j)=1.d0
          if(i.eq.lx1)mtemp(i,j)=2.d0
          call transf_nc(mtemp,p)
          call laplacian(temp,p,element_size)                          
          call transfb_nc1(temp1,temp)                   
          pcmor_nc1(i,j,1,1,element_size)=temp1(i,j)      
          pcmor_nc1(j,i,1,1,element_size)=temp1(i,j)                              
          do ii=1,lx1
c...........p0 is for the case that a nonconforming edge is shared by
c           two conforming faces
            p0(ii,1,1)=p(ii,1,1)
            do jj=1,lx1 
c.............now p is for the case that a nonconforming edge is shared
c             by nonconforming faces
              p(ii,1,jj)=p(ii,jj,1)
            end do
          end do

          call laplacian(temp,p,element_size)
          call transfb_nc2(temp1,temp)                

c.........pcmor_nc2(i,j,ii,jj,element_size) gives the intermediate
c         preconditioner value on collocation point (i,j) on a 
c         nonconforming face of an element with size size_element

          pcmor_nc2(i,j,1,1,element_size)=temp1(i,j)*2.d0 
          pcmor_nc2(j,i,1,1,element_size)=
     &          pcmor_nc2(i,j,1,1,element_size)

          call laplacian(temp,p0,element_size) 
          call transfb_nc0(temp1,temp)                  

c.........pcmor_nc0(i,j,ii,jj,element_size) gives the intermediate
c         preconditioner value on collocation point (i,j) on a 
c         conforming face of an element, which shares a nonconforming 
c         edge with another conforming face
          pcmor_nc0(i,j,1,1,element_size)=temp1(i,j)
          pcmor_nc0(j,i,1,1,element_size)=temp1(i,j)
        end do
        pcmor_nc1(lx1,j,1,1,element_size)=
     &        pcmor_nc1(lx1,j,1,1,element_size)*2.d0
        pcmor_nc1(j,lx1,1,1,element_size)=
     &        pcmor_nc1(lx1,j,1,1,element_size)
        pcmor_nc2(lx1,j,1,1,element_size)=
     &        pcmor_nc2(lx1,j,1,1,element_size)*2.d0
        pcmor_nc2(j,lx1,1,1,element_size)=
     &        pcmor_nc2(lx1,j,1,1,element_size)
        pcmor_nc0(lx1,j,1,1,element_size)=
     &        pcmor_nc0(lx1,j,1,1,element_size)*2.d0
        pcmor_nc0(j,lx1,1,1,element_size)=
     &        pcmor_nc0(lx1,j,1,1,element_size)

c.......symmetrical copy
        do i=1,lx1-1
          pcmor_nc1(i,j,1,2,element_size)=
     &          pcmor_nc1(lx1+1-i,j,1,1,element_size)
          pcmor_nc0(i,j,1,2,element_size)=                                           
     &          pcmor_nc0(lx1+1-i,j,1,1,element_size)                                      
          pcmor_nc2(i,j,1,2,element_size)=                                           
     &          pcmor_nc2(lx1+1-i,j,1,1,element_size)                                      
        end do

        do j=2,lx1                                            
          do i=1,lx1-1
            pcmor_nc1(i,j,1,2,element_size)=
     &            pcmor_nc1(lx1+1-i,j,1,1,element_size)
          end do
          i=lx1
          pcmor_nc1(i,j,1,2,element_size)=
     &          pcmor_nc1(lx1+1-i,j,1,1,element_size)
          pcmor_nc0(i,j,1,2,element_size)=                                           
     &          pcmor_nc0(lx1+1-i,j,1,1,element_size)                                      
          pcmor_nc2(i,j,1,2,element_size)=                                           
     &          pcmor_nc2(lx1+1-i,j,1,1,element_size)                                      
        end do                                                

        j=1
        i=1
        pcmor_nc1(i,j,2,1,element_size)=
     &        pcmor_nc1(i,lx1+1-j,1,1,element_size)
        pcmor_nc0(i,j,2,1,element_size)=
     &        pcmor_nc0(i,lx1+1-j,1,1,element_size)
        pcmor_nc2(i,j,2,1,element_size)=
     &        pcmor_nc2(i,lx1+1-j,1,1,element_size)
        do j=2,lx1-1
          i=1
          pcmor_nc1(i,j,2,1,element_size)=
     &          pcmor_nc1(i,lx1+1-j,1,1,element_size)
          pcmor_nc0(i,j,2,1,element_size)=
     &          pcmor_nc0(i,lx1+1-j,1,1,element_size)
          pcmor_nc2(i,j,2,1,element_size)=
     &          pcmor_nc2(i,lx1+1-j,1,1,element_size)
          do i=2,lx1
            pcmor_nc1(i,j,2,1,element_size)=
     &            pcmor_nc1(i,lx1+1-j,1,1,element_size)
          end do
        end do

        j=lx1
        do i=2,lx1
          pcmor_nc1(i,j,2,1,element_size)=
     &          pcmor_nc1(i,lx1+1-j,1,1,element_size)
          pcmor_nc0(i,j,2,1,element_size)=
     &          pcmor_nc0(i,lx1+1-j,1,1,element_size)
          pcmor_nc2(i,j,2,1,element_size)=
     &          pcmor_nc2(i,lx1+1-j,1,1,element_size)
        end do

        j=1
        i=lx1
        pcmor_nc1(i,j,2,2,element_size)=
     &        pcmor_nc1(lx1+1-i,lx1+1-j,1,1,element_size)
        pcmor_nc0(i,j,2,2,element_size)=
     &        pcmor_nc0(lx1+1-i,lx1+1-j,1,1,element_size)
        pcmor_nc2(i,j,2,2,element_size)=
     &        pcmor_nc2(lx1+1-i,lx1+1-j,1,1,element_size)
          
        do j=2,lx1-1                                            
          do i=2,lx1-1
            pcmor_nc1(i,j,2,2,element_size)=
     &            pcmor_nc1(lx1+1-i,lx1+1-j,1,1,element_size)
          end do
          i=lx1
          pcmor_nc1(i,j,2,2,element_size)=                                       
     &          pcmor_nc1(lx1+1-i,lx1+1-j,1,1,element_size)                               
          pcmor_nc0(i,j,2,2,element_size)=                                       
     &          pcmor_nc0(lx1+1-i,lx1+1-j,1,1,element_size)   
          pcmor_nc2(i,j,2,2,element_size)=                                       
     &          pcmor_nc2(lx1+1-i,lx1+1-j,1,1,element_size)                     
        end do                                                
        j=lx1
        do i=2,lx1-1
          pcmor_nc1(i,j,2,2,element_size)=                                       
     &          pcmor_nc1(lx1+1-i,lx1+1-j,1,1,element_size)          
          pcmor_nc0(i,j,2,2,element_size)=
     &          pcmor_nc0(lx1+1-i,lx1+1-j,1,1,element_size)          
          pcmor_nc2(i,j,2,2,element_size)=                                       
     &          pcmor_nc2(lx1+1-i,lx1+1-j,1,1,element_size)    
        end do


c.......vertices shared by at least one nonconforming face or edge

c.......Among three edges and three faces sharing a vertex on an element
c       situation 1: only one edge is nonconforming
c       situation 2: two edges are nonconforming
c       situation 3: three edges are nonconforming
c       situation 4: one face is nonconforming 
c       situation 5: one face and one edge are nonconforming 
c       situation 6: two faces are nonconforming
c       situation 7: three faces are nonconforming

        call r_init(p0,nxyz,0.d0)
        p0(1,1,1)=1.d0
        call laplacian(temp,p0,element_size)
        pcmor_cor(8,element_size)=temp(1,1,1)

c.......situation 1
        call r_init(p0,nxyz,0.d0)
        do i=1,lx1
           p0(i,1,1)=tcpre(i,1)
        end do
        call laplacian(temp,p0,element_size) 
        call transfb_cor_e(1,pcmor_cor(1,element_size),temp)                  

c.......situation 2
        call r_init(p0,nxyz,0.d0)
        do i=1,lx1
           p0(i,1,1)=tcpre(i,1)
           p0(1,i,1)=tcpre(i,1)
        end do
        call laplacian(temp,p0,element_size)
        call transfb_cor_e(2,pcmor_cor(2,element_size),temp)                  

c.......situation 3
        call r_init(p0,nxyz,0.d0)
        do i=1,lx1
           p0(i,1,1)=tcpre(i,1)
           p0(1,i,1)=tcpre(i,1)
           p0(1,1,i)=tcpre(i,1)
        end do
        call laplacian(temp,p0,element_size)
        call transfb_cor_e(3,pcmor_cor(3,element_size),temp)                  

c.......situation 4
        call r_init(p0,nxyz,0.d0)
        do j=1,lx1
          do i=1,lx1
            p0(i,j,1)=tcpre(i,j)
          end do
        end do
        call laplacian(temp,p0,element_size)
        call transfb_cor_f(4,pcmor_cor(4,element_size),temp)

c.......situation 5
        call r_init(p0,nxyz,0.d0)
        do j=1,lx1
          do i=1,lx1
            p0(i,j,1)=tcpre(i,j)
          end do
        end do
        do i=1,lx1
           p0(1,1,i)=tcpre(i,1)
        end do
        call laplacian(temp,p0,element_size)
        call transfb_cor_f(5,pcmor_cor(5,element_size),temp)
 
c.......situation 6
        call r_init(p0,nxyz,0.d0)
        do j=1,lx1
          do i=1,lx1
            p0(i,j,1)=tcpre(i,j)
            p0(i,1,j)=tcpre(i,j)
          end do
        end do
        call laplacian(temp,p0,element_size)
        call transfb_cor_f(6,pcmor_cor(6,element_size),temp)

c.......situation 7
        do j=1,lx1
          do i=1,lx1
            p0(i,j,1)=tcpre(i,j)
            p0(i,1,j)=tcpre(i,j)
            p0(1,i,j)=tcpre(i,j)
          end do
        end do
        call laplacian(temp,p0,element_size)
        call transfb_cor_f(7,pcmor_cor(7,element_size),temp)

      end do    
      return
      end 


c------------------------------------------------------------------------
      subroutine setpcmo
c------------------------------------------------------------------------
c     compute the preconditioner by identifying its geometry configuration
c     and sum the values from the precomputed elemental contributions
c------------------------------------------------------------------------
      
      include 'header.h'

      integer face2, nb1, nb2, sizei, imor, enum, i,j, 
     &        iel, iside, nn1, nn2

      call l_init(ifpcmor,nvertex,.false.)
      call l_init(edgevis,24*nelt,.false.)


      do iel=1,nelt
        do iside=1,nsides
c.........for nonconforming faces
          if(cbc(iside,iel).eq.3)then
            sizei=size_e(iel)

c...........vertices

c...........ifpcmor(imor)=.true. indicates that mortar point imor has 
c           been visited
            imor=idmo(1,1,1,1,iside,iel)
            if(.not.ifpcmor(imor))then
c.............compute the preconditioner on mortar point imor
              call pc_corner(imor)
              ifpcmor(imor)=.true.
            end if

            imor=idmo(lx1,1,1,2,iside,iel)
            if(.not.ifpcmor(imor))then
              call pc_corner(imor)
              ifpcmor(imor)=.true.
            end if

            imor=idmo(1,lx1,2,1,iside,iel)
            if(.not.ifpcmor(imor))then
              call pc_corner(imor)
              ifpcmor(imor)=.true.
            end if

            imor=idmo(lx1,lx1,2,2,iside,iel)
            if(.not.ifpcmor(imor))then
              call pc_corner(imor)
              ifpcmor(imor)=.true.
            end if

c...........edges on nonconforming faces, enum is local edge number
            do enum=1,4

c.............edgevis(enum,iside,iel)=.true. indicates that local edge 
c             enum of face iside of iel has been visited
              if(.not.edgevis(enum,iside,iel))then
                edgevis(enum,iside,iel)=.true.

c...............Examing neighbor element information,
c               calculateing the preconditioner value.
                face2= f_e_ef(enum,iside)
                if(cbc(face2,iel).eq.2)then
                  nb1=sje(1,1,face2,iel)
                  if(cbc(iside,nb1).eq.2)then

c...................Compute the preconditioner on local edge enum on face
c                   iside of element iel, 1 is neighborhood information got
c                   by examing neighbors(nb1). For detailed meaning of 1, 
c                   see subroutine com_dpc.

                    call com_dpc(iside,iel,enum,1,sizei)
                    nb2=sje(1,1,iside,nb1)
                    edgevis(op(e_face2(enum,iside)),
     &                      jjface(face2),nb2)=.true.

                  elseif(cbc(iside,nb1).eq.3)then
                    call com_dpc(iside,iel,enum,2,sizei)
                    edgevis(op(enum),iside,nb1)=.true.
                  end if

                elseif(cbc(face2,iel).eq.3)then
                  edgevis(e_face2(enum,iside),face2,iel)=.true.
                  nb1=sje(1,2,face2,iel)
                  if(cbc(iside,nb1).eq.1)then
                    call com_dpc(iside,iel,enum,3,sizei)
                    nb2=sje(1,1,iside,nb1)
                    edgevis(op(enum),jjface(iside),nb2)=.true.
                    edgevis(op(e_face2(enum,iside)),
     &                      jjface(face2),nb2)=.true.
                  elseif(cbc(iside,nb1).eq.2)then
                    call com_dpc(iside,iel,enum,4,sizei)
                  end if
                else if (cbc(face2,iel).eq.0)then
                  call com_dpc(iside,iel,enum,0,sizei)
                end if
              end if
            end do

c...........mortar element interior (not edge of mortar) 

            do nn1=1,2
              do nn2=1,2
                do j=2,lx1-1
                  do i=2,lx1-1
                    imor=idmo(i,j,nn1,nn2,iside,iel) 
                    dpcmor(imor) = 1.d0/(pcmor_nc1(i,j,nn1,nn2,sizei)+
     &                                pcmor_c(i,j,sizei+1))
                  end do
                end do
              end do
            end do

c...........for i,j=lx1 there are duplicated mortar points, so 
c           pcmor_c needs to be doubled or quadrupled
            i=lx1
            do j=2,lx1-1
              imor=idmo(i,j,1,1,iside,iel)            
              dpcmor(imor) = 1.d0/(pcmor_nc1(i,j,1,1,sizei)+
     &                          pcmor_c(i,j,sizei+1)*2.d0)
              imor=idmo(i,j,2,1,iside,iel)                
              dpcmor(imor) = 1.d0/(pcmor_nc1(i,j,2,1,sizei)+
     &                          pcmor_c(i,j,sizei+1)*2.d0)
            end do      

            j=lx1
            imor=idmo(i,j,1,1,iside,iel)                                         
            dpcmor(imor) = 1.d0/(pcmor_nc1(i,j,1,1,sizei)+
     &                        pcmor_c(i,j,sizei+1)*4.d0)
            do i=2,lx1-1
              imor=idmo(i,j,1,1,iside,iel)  
              dpcmor(imor) = 1.d0/(pcmor_nc1(i,j,1,1,sizei)+
     &                          pcmor_c(i,j,sizei+1)*2.d0)
              imor=idmo(i,j,1,2,iside,iel) 
              dpcmor(imor) = 1.d0/(pcmor_nc1(i,j,1,2,sizei)+
     &                          pcmor_c(i,j,sizei+1)*2.d0)
            end do

          end if 
        end do
      end do

      return
      end

c--------------------------------------------------------------------------
      subroutine pc_corner(imor)
c------------------------------------------------------------------------
c     calculate preconditioner value for vertex with mortar index imor
c------------------------------------------------------------------------

      include 'header.h'

      double precision tmortemp
      integer imor, inemo,ie, sizei,cornernumber,
     &        sface,sedge,iiface,iface,iiedge,iedge,n

      tmortemp=0.d0
c.....loop over all elements sharing this vertex
      do inemo=1,nemo(imor)
        ie=emo(1,inemo,imor)
        sizei=size_e(ie)
        cornernumber=emo(2,inemo,imor)
        sface=0
        sedge=0
        do iiface=1,3
          iface=f_c(iiface,cornernumber)
c.........sface sums the number of nonconforming faces sharing this vertex on
c         one element
          if(cbc(iface,ie).eq.3)then
            sface=sface+1
          end if
        end do
c.......sedge sums the number of nonconforming edges sharing this vertex on
c       one element
        do iiedge=1,3
          iedge=e_c(iiedge,cornernumber)
          if(ncon_edge(iedge,ie))sedge=sedge+1
        end do

c.......each n indicates how many nonconforming faces and nonconforming
c       edges share this vertex on an element, 

        if(sface.eq.0)then
          if(sedge.eq.0)then
             n=8
          elseif(sedge.eq.1)then
             n=1
          elseif(sedge.eq.2)then
             n=2
          elseif(sedge.eq.3)then
             n=3
          end if 
        elseif (sface.eq.1)then
          if (sedge.eq.1)then
           n=5
          else
           n=4
          end if
        else if (sface.eq.2)then
           n=6
        else if(sface.eq.3)then
           n=7
        end if
          
c.......sum the intermediate pre-computed preconditioner values for 
c       all elements
        tmortemp=tmortemp+pcmor_cor(n,sizei)

      end do

c.....dpcmor(imor) is the value of the preconditioner on mortar point imor
      dpcmor(imor)=1.d0/tmortemp

      return
      end 

c------------------------------------------------------------------------
      subroutine com_dpc(iside,iel,enumber,n,isize)
c------------------------------------------------------------------------
c     Compute preconditioner for local edge enumber of face iside 
c     on element iel.
c     isize is element size,
c     n is one of five different configurations
c     anc1, ac, anc2, anc0 are coefficients for different edges. 
c     nc0 refers to nonconforming edge shared by two conforming faces
c     nc1 refers to nonconforming edge shared by one nonconforming face
c     nc2 refers to nonconforming edges shared by two nonconforming faces
c     c refers to conforming edge
c------------------------------------------------------------------------

      include 'header.h'

      integer n, isize,iside,iel, enumber, nn1start, nn1end, nn2start, 
     &        nn2end, jstart, jend, istart, iend, i, j, nn1, nn2, imor
      double precision anc1,ac,anc2,anc0,temp

c.....different local edges have different loop ranges 
      if(enumber.eq.1)then
        nn1start=1
        nn1end=1
        nn2start=1
        nn2end=2
        jstart=1
        jend=1
        istart=2
        iend=lx1-1
      elseif (enumber.eq.2) then
        nn1start=1
        nn1end=2
        nn2start=2
        nn2end=2
        jstart=2
        jend=lx1-1
        istart=lx1
        iend=lx1
      elseif (enumber.eq.3) then
        nn1start=2
        nn1end=2
        nn2start=1
        nn2end=2
        jstart=lx1
        jend=lx1
        istart=2
        iend=lx1-1
      elseif (enumber.eq.4) then
        nn1start=1
        nn1end=2
        nn2start=1
        nn2end=1
        jstart=2
        jend=lx1-1
        istart=1
        iend=1
      end if

c.....among the four elements sharing this edge

c.....one has a smaller size
      if(n.eq.1)then
        anc1=2.d0
        ac=1.d0
        anc0=1.d0
        anc2=0.d0

c.....two (neighbored by a face) are of  smaller size
      else if (n.eq.2)then
        anc1=2.d0
        ac=2.d0
        anc0=0.d0
        anc2=0.d0

c.....two (neighbored by an edge) are of smaller size
      else if (n.eq.3)then
        anc2=2.d0
        ac=2.d0
        anc1=0.d0
        anc0=0.d0

c.....three are of smaller size
      else if (n.eq.4)then
        anc1=0.d0
        ac=3.d0
        anc2=1.d0
        anc0=0.d0

c.....on the boundary
      else if (n.eq.0)then
        anc1=1.d0
        ac=1.d0
        anc2=0.d0
        anc0=0.d0
      end if

c.....edge interior
      do nn2=nn2start,nn2end
        do nn1=nn1start,nn1end
          do j=jstart,jend
            do i=istart,iend
              imor=idmo(i,j,nn1,nn2,iside,iel)
              temp=anc1* pcmor_nc1(i,j,nn1,nn2,isize) +
     &             ac*  pcmor_c(i,j,isize+1)+
     &             anc0*  pcmor_nc0(i,j,nn1,nn2,isize)+
     &             anc2*pcmor_nc2(i,j,nn1,nn2,isize)
                dpcmor(imor)=1.d0/temp
              end do
            end do
          end do
        end do

c.......local edge 1
        if (enumber.eq.1) then
          imor=idmo(lx1,1,1,1,iside,iel)
          temp=anc1* pcmor_nc1(lx1,1,1,1,isize) +
     &         ac*  pcmor_c(lx1,1,isize+1)*2.d0+
     &         anc0*  pcmor_nc0(lx1,1,1,1,isize)+
     &         anc2*pcmor_nc2(lx1,1,1,1,isize)
c.......local edge 2
        elseif (enumber.eq.2) then
          imor=idmo(lx1,lx1,1,2,iside,iel)
          temp=anc1* pcmor_nc1(lx1,lx1,1,2,isize) +
     &         ac*  pcmor_c(lx1,lx1,isize+1)*2.d0+
     &         anc0*  pcmor_nc0(lx1,lx1,1,2,isize)+
     &         anc2*pcmor_nc2(lx1,lx1,1,2,isize)
c.......local edge 3
        elseif (enumber.eq.3) then
          imor=idmo(lx1,lx1,2,1,iside,iel)
          temp=anc1* pcmor_nc1(lx1,lx1,2,1,isize) +
     &         ac*  pcmor_c(lx1,lx1,isize+1)*2.d0+
     &         anc0*  pcmor_nc0(lx1,lx1,2,1,isize)+
     &         anc2*pcmor_nc2(lx1,lx1,2,1,isize)
c.......local edge 4
        elseif (enumber.eq.4) then
          imor=idmo(1,lx1,1,1,iside,iel)
          temp=anc1* pcmor_nc1(1,lx1,1,1,isize) +
     &         ac*  pcmor_c(1,lx1,isize+1)*2.d0+
     &         anc0*  pcmor_nc0(1,lx1,1,1,isize)+
     &         anc2*pcmor_nc2(1,lx1,1,1,isize)
        end if

        dpcmor(imor)=1.d0/temp

      return
      end 

