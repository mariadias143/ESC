provider sparseget
{
  probe query_userentry();
  probe query_charge( int, int );
  probe query_userexit();
};
