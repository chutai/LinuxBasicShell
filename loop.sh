#!/bin/bash

var="aaaatest"
num=15

function savetofile(){
  ghep="$1 $num"
	touch testfile.txt
	echo "$ghep" >> "testfile.txt"
  sort -nrk 2,2 testfile.txt
}
function readfromfile(){
  sort -nrk 2,2 testfile.txt
	#while IFS= read -r line
	#do
  #	echo "$line"
	#done < testfile.txt
}
	while :
	do
		clear
		
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
      if [$name eq '']; then
      name=noname
      fi
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
