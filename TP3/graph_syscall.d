BEGIN
{
  totalcalls = 0;
}
sysinfo:::nthreads
/pid == $target/
{
  printf("\n New Thread Created\n");
}
syscall::read:entry
/pid == $target/
{
  @readBytes = quantize(arg0);
}
syscall:::entry
/pid == $target/
{
  @syscalls[probefunc] = count();
  totalcalls += 1;
}
syscall:::entry
/pid == $target/
{
  @syscalls[probefunc] = count();
  totalcalls += 1;
}
END
{
  trunc(@syscalls,10);
  printf("\nNúmero de invocações de cada syscall\n");
  printa(@syscalls);
  printf("\n---------Bytes lidos---------");
  printa(@readBytes);
  printf("\n%d Syscalls traced",totalcalls);
}
