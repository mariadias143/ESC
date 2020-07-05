pid$target:$1::entry
/tid == 1/
{
  time[probefunc] = timestamp;
}
pid$target:$1::return
/tid == 1/
{
  @totaltime[probefunc] = sum(timestamp - time[probefunc]);
}
pid$target:$1:main:entry
{
  self->trace = 1;
}
pid$target:$1:main:return
/self->trace && tid == 1/
{
  self->trace = 0;
}
pid$target:$1::entry,
pid$target:$1::return
/self->trace && tid == 1/
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
  printf("\n---------------Memory Allocated--------------\n");
  printa("probemod = %s,\tprobefunc = %s\tsize = %d,\tcount = %@d \n",@mem);
}
