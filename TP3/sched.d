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
/self->ts && pid == $target/
{
  @oncpuT[cpu] = sum(timestamp - self->ts);
  self->ts = 0;
}
END
{
  totaltime = timestamp - start;
  printf("\n CPU\tTime with work");
  printa(@oncpuT);
}
