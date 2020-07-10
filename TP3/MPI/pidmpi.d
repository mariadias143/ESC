BEGIN
{
  mpi_waiting = 0;
}
pid$target:$1::entry
{
  time[probefunc] = timestamp;
}
pid$target:$1::return
{
  @totaltime[probefunc] = sum(timestamp - time[probefunc]);
}
pid$target:libmpi:MPI_P*:entry
{
  self->ts = timestamp;
}
pid$target:libmpi:MPI_P*:return
/self->ts != 0/
{
  mpi_waiting += (timestamp - self->ts);
  @mpi_calls[probefunc] = avg(timestamp - self->ts);
  self->ts = 0;
}
pid$target:libmpi:MPI_[!WP]*:entry
{
  self->tcall = timestamp;
}
pid$target:libmpi:MPI_[!WP]*:return
/self->tcall != 0/
{
  @mpi_calls[probefunc] = avg(timestamp - self->tcall);
  self->tcall = 0;
}
pid$target:$1:main:entry
{
  self->trace = 1;
}
pid$target:$1:main:return
/self->trace/
{
  self->trace = 0;
}
pid$target:$1::entry,
pid$target:$1::return
/self->trace/
{
}
pid$target:libmpi:MPI_[!W]*:entry,
pid$target:libmpi:MPI_[!W]*:return
/self->trace/
{
}
pid$target:*:*malloc*:entry,
pid$target:*:*memalign*:entry,
pid$target:*:*valloc*:entry
{
  @mem[probemod,probefunc,arg0]= count();
}
pid$target:*:*realloc*:entry
{
  @mem[probemod,probefunc,arg1]= count();
}
END
{
  printf("\n---------------TIME SPENT--------------\n");
  printa(@totaltime);
  printf("\nWaiting time: %d\n",mpi_waiting);
  printf("\n---------------MPI TIME SPENT--------------\n");
  printa(@mpi_calls);
  trunc(@mem,5);
  printf("\n---------------Memory Allocated--------------\n");
  printa("probemod = %s,\tprobefunc = %s\tsize = %d,\tcount = %@d \n",@mem);
}
