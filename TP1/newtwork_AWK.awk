BEGIN {FS="[ ]+";}
NR == 3 && NF == 9 {for(i=2; i <= NF; i++) {info[i-2] = $i;}}
NR > 3 && NF == 9 && ($2 != "IFACE"){
  stats[$2, 0]++;
  I[$2];
  for(i=3; i <= NF; i++) {
    stats[$2, i-2] += $i;
  }
}
END{
  for (key in info){
    printf "%s;",info[key];
  };
  print "";

  for (key in I){
    n_records = stats[key, 0];
    for(i=1; i <= 7; i++){
      stats[key, i] = stats[key, i] / n_records;
    }
  };



  for (key in I){
    printf "%s;",key;
    for(i=1; i <= 7; i++){
      printf "%f;",stats[key, i];
    }
    print "";
  }
}
