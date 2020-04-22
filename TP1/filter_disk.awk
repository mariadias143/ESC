BEGIN {FS="[ ]+";}
NR > 3 && NF == 10 && ($2 == "dev8-0"){
  printf "%f;\n",$10;
}
END{
}
