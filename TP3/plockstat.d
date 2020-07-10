plockstat$target:::mutex-block
{
  self->ts = timestamp;
}
plockstat$target:::mutex-acquire
/self->ts != 0/
{
  @wait = quantize(timestamp - self->ts);
  self->ts = 0;
  self->acquired = timestamp;
}
plockstat$target:::mutex-release
/self->ts == 0 && self->acquired != 0/
{
  @hold = quantize(timestamp - self->acquired);
  self->acquired = 0;
}
END
{
  printf("\n-----TIME WAITING FOR LOCK-----------");
  printa(@wait);
  printf("\n-----TIME WITH LOCK------------");
  printa(@hold);
}
