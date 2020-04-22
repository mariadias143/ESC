BEGIN {FS="[ ]+";}
NR == 3 && NF == 8 {for(i=2; i <= NF; i++) {info[i-2] = $i;}}
NR > 3 && NF == 8 && ($2 != "kbmemfree"){
  stats[0]++;
  for(i=2; i <= NF; i++) {
    stats[i-1] += $i;
  }
}
END{
  for(i=0; i <=6; i++){
    printf "%s;",info[i];
  };
  print "";

  n_records = stats[0];
  for(i=1; i <= 7; i++){
    printf "%.3f;",(stats[i] / n_records);
  }
}
