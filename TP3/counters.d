BEGIN
{
 total_inst = 0;
 total_cycles = 0;
 total_fp_inst = 0;
}
/**
cpc:::PAPI_tot_ins-user-5000
/pid == $target/
{
  total_inst += 1;
}
cpc:::PAPI_tot_cyc-user-5000
/pid == $target/
{
  total_cycles += 1;
}*/
cpc:::PAPI_fp_ins-user-5000
/pid == $target/
{
  total_fp_inst += 1;
}
END
{
  printf("\nTotal instructions: %d\n",total_inst*5000);
  printf("Total cycles: %d\n",total_cycles*5000);
  printf("Total floating point insts: %d\n",total_fp_inst*5000);
}
