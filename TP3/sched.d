BEGIN
{
  start = timestamp;
}
sched:::on-cpu
/pid == $target/
{
  self->ts = timestamp;
}
sched:::off-cpu
/self->ts/
{
  @oncpuT[tid,cpu] = sum(timestamp - self->ts);
  self->ts = 0;
}
END
{
  totaltime = timestamp - start;
  printf("\n Total time: %d us",totaltime/1000);
  printf("\n CPU\tTime with work in us\n");
  normalize(@oncpuT, 1000);
  printa("Thread = %d, CPU = %d\tTime = %@d\n",@oncpuT);
}
