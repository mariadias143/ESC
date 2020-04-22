BEGIN {FS="[ ]+";}
NR == 3 && NF == 9 {
  printf "%s;",$5;
  printf "%s;\n",$6;
}
NR == 3 && NF == 10 {
  printf "%s;",$6;
  printf "%s;\n",$7;
}
NR > 3 && NF == 9 && ($2 == "eth1"){
  printf "%s;",$5;
  printf "%s;\n",$6;
}

NR > 3 && NF == 10 && ($3 == "eth1"){
  printf "%s;",$6;
  printf "%s;\n",$7;
}
END{

}
