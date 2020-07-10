BEGIN
{
 total_inst = 0;
 total_cycles = 0;
 total_fp_inst = 0;
 total_l1_dcm = 0;
 total_l1_dca = 0;
 total_l2_dcm = 0;
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
}
cpc:::PAPI_fp_ins-user-5000
/pid == $target/
{
  total_fp_inst += 1;
}
cpc:::PAPI_l1_dcm-user-5000
/pid == $target/
{
  total_l1_dcm += 1;
}
cpc:::PAPI_l1_dca-user-5000
/pid == $target/
{
  total_l1_dca += 1;
}*/
cpc:::PAPI_l2_dcm-user-5000
/pid == $target/
{
  total_l2_dcm += 1;
}
END
{
  printf("\nTotal instructions: %d\n",total_inst*5000);
  printf("Total cycles: %d\n",total_cycles*5000);
  printf("Total floating point insts: %d\n",total_fp_inst*5000);
  printf("Total L1 DCM: %d\n",total_l1_dcm*5000);
  printf("Total L1 DCA: %d\n",total_l1_dca*5000);
  printf("Total L2 DCM: %d\n",total_l2_dcm*5000);
}
