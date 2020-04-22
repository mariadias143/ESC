BEGIN {FS="[ ]+";}
NR == 3 {
  for(i=2; i <= NF; i++){
    printf "%s;",$i;
  }
  print "";
}
NR > 3 && NF == 11 && ($2 == "all"){
  for(i=2; i <= NF; i++) {
    printf "%s;",$i;
  }
  print "";
}
END{
}
