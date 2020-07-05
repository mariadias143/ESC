sparseget*:::query_userentry
{
  self->t = timestamp;
}

sparseget*:::query_charge
/self->t != 0/
{
  @fds[execname] = lquantize(args[1], 0 , 8192 , 1)
}

sparseget*:::query_userexit
/self->t != 0/
{
  timenow = timestamp;
  printf("Time: %d\n",timestamp - self->t);
  exit(0);
}
