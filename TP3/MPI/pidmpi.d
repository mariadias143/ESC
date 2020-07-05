pid$target:$1::entry
{
  time[probefunc] = timestamp;
}
pid$target:$1::return
{
  @totaltime[probefunc] = sum(timestamp - time[probefunc]);
}
pid$target:libmpi:MPI_*:entry
{
printf("Entered %s...", probefunc);
}
pid$target:libmpi:MPI_*:return
{
printf("exiting, return value = %d\n", arg1);
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
  trunc(@mem,20);
  printf("\n---------------Memory Allocated--------------\n");
  printa("probemod = %s,\tprobefunc = %s\tsize = %d,\tcount = %@d \n",@mem);
}
