#!/bin/bash

var=aaaatest
number=20
declare -a arrRecord
function savetofile(){
  ghep="$1 $number"
  touch testfile.txt
  count=0
  	while IFS= read -r line
	do
    arrRecord[$count]=$line
    count=$[$count+1]
	done < testfile.txt

  if [ $count -le 10 ]; then
    echo "$ghep" >> "testfile.txt"
  elif [ $count -eq 10 ]; then
    echo -n " " > "testfile.txt"
    for ((i = 0; i <= $count; ++i))
  do
	  echo ${arrRecord[$i]} >> "testfile.txt"
  done
  fi

  sort -nrk 2,2 testfile.txt
}

function readfromfile(){
	while IFS= read -r line
	do
  	echo "$line"
	done < testfile.txt
}

	while :
	do
		#clear
		
		read -rsn1 MENU_KEY
		case "$MENU_KEY" in
		1)
			echo "new_game"
			break
			;;
		2)
			echo "Record"
			;;
		3)	echo "save"
      read name
			savetofile $name
			#break;
			;;
		4)	echo "read"
      
			readfromfile
			break;
			;;
		*) 	echo " Sorry, I dont know what you want"
		esac
	done
