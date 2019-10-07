#!/bin/bash

var="aaaatest"
function savetofile(){
	touch ${HOME}/shell/testfile.txt
	echo "$var" >> "${HOME}/shell/testfile.txt"
}
function readfromfile(){
	while IFS= read -r line
	do
  	echo "$line"
	done < testfile.txt
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
			savetofile
			#break;
			;;
		4)	echo "read"
			readfromfile
			break;
			;;
		*) 	echo " Sorry, I dont know what you want"
		esac
	done
