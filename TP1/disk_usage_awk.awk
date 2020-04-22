BEGIN {FS="[ ]+";}
NR == 3 && NF == 10 {for(i=3; i <= NF; i++) {info[i-3] = $i;}}
NR > 3 && NF == 10 && ($2 != "DEV"){
  stats[0]++;
  for(i=3; i <= NF; i++) {
    stats[i-2] += $i;
  }
}
END{
  for(i=0; i <=7; i++){
    printf "%s;",info[i];
  };
  print "";

  n_records = stats[0];
  for(i=1; i <= 8; i++){
    printf "%.3f;",(stats[i] / n_records);
  }
}
