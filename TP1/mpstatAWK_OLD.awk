BEGIN {FS="[ ]+";}
NR == 3 && NF == 11 {for(i=2; i <= NF; i++) {info[i-2] = $i;}}
NR == 3 && NF == 12 {for(i=3; i <= NF; i++) {info[i-3] = $i;}}
NR > 3 && NF == 11 && ($2 != "CPU" && $2 != "all"){
  stats[$2, 0]++;
  I[$2];
  for(i=3; i <= NF; i++) {
    stats[$2, i-2] += $i;
  }
}
NR > 3 && NF == 12 && ($3 != "CPU" && $3 != "all"){
  stats[$3, 0]++;
  I[$3];
  for(i=4; i <= NF; i++) {
    stats[$3, i-3] += $i;
  }
}
END{
  for (key in info){
    printf "%s;",info[key];
  };
  print "";

  for (key in I){
    n_records = stats[key, 0];
    for(i=1; i < 10; i++){
      stats[key, i] = stats[key, i] / n_records;
    }
  };

  for (key in I){
    printf "%d;",key;
    for(i=1; i < 10; i++){
      printf "%f;",stats[key, i];
    }
    print "";
  }
}
