BEGIN {FS="[ ]+";}
NR == 3 {for(i=2; i <= NF; i++) {info[i-2] = $i;}}
NR > 3 && NF == 11 && ($2 != "CPU" && $2 != "all"){
  stats[$2][0]++;
  for(i=3; i <= NF; i++) {
    stats[$2][i-2] += $i;
  }
}
END{
  for (key in info){
    printf "%s;",info[key];
  };
  print "";
  for (key in stats){
    n_records = stats[key][0];
    for(i=1; i < 10; i++){
      stats[key][i] = stats[key][i] / n_records;
    }
  };

  for (key in stats){
    printf "%d;",key;
    for(i=1; i < 10; i++){
      printf "%f;",stats[key][i];
    }
    print "";
  }
}
