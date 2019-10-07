#!/bin/bash
#
declare -A matrix
num_row=10
num_col=5

#op_direct[]
#op_speed[]

max_circle=100000
max_speed=10

frog_x=0
frog_y=$[($num_row - 1) / 2]

MW=$(tput cols)
MH=$(tput lines)

buff_x=''
buff_y=''

screen_buff_x=''
screen_buff_y=''

TIMING=0.1
CIRCLE=0

HEALTH=10
LEVEL=1


#########
#DISPLAY#
#########

function printf_x_y() {
	printf "\e[${2};${1}f$3"
}

function printf_x_y_center() {
	if [ $MW -gt $[3 * $num_col] ]
	then
		buff_x=$[($MW - $[3 * $num_col]) / 2]
	else
		buff_x=0
	fi

	if [ $MH -gt $[1 * $num_row] ]
	then
		buff_y=$[($MH - $[1 * $num_row]) / 2]
	else
		buff_y=0
	fi

	printf_x_y $[$1 + $buff_x] $[$2 + $buff_y] $3
}

function printf_x_y_screen() {
	if [ $MW -gt '65' ]; then
		screen_buff_x=$[($MW - 65) / 2]
	else
		screen_buff_x=0
	fi
	screen_buff_y=1

	printf_x_y $[$1 + $screen_buff_x] $[$2 + $screen_buff_y] $3
}


########
#  OP  #
########

#arg: $1: x, $2: y
function op_appear() {
	printf_x_y_center $[3 * $1 + 1] $[$2 + 1] "\e[1;31m\u2588\e[0m"
	printf_x_y_center $[3 * $1 + 2] $[$2 + 1] "\e[1;31m\u2588\e[0m"
}

#arg: $1: x, $2: y
function op_disappear() {
	printf_x_y_center $[3 * $1 + 1] $[$2 + 1] "\u2588"
	printf_x_y_center $[3 * $1 + 2] $[$2 + 1] "\u2588"
}

#arg: $1: col_no
function op_moving_down() {
	flag_1=0
	flag_2=0
	for((y = 1; y < $num_row; y++))
		do
		if [[ ($flag_1 -eq 0) && ($[matrix[$1, $y]] -eq 1) && ($[matrix[$1, $[$y-1]]] -eq 0) ]]
		then
			matrix[$1, $y]=0
			op_disappear $1 $y
			flag_1=1
		fi
		if [[ ($flag_2 -eq 0) && ($[matrix[$1, $y]] -eq 0) && ($[matrix[$1, $[$y-1]]] -eq 1) ]]
		then
			matrix[$1, $y]=1
			op_appear $1 $y
			flag_2=1
		fi
	done
	if [[ flag_1 -eq 0 ]]
	then
		matrix[$1, 0]=0
		op_disappear $1 0
	fi
	if [[ flag_2 -eq 0 ]]
	then
		matrix[$1, 0]=1
		op_appear $1 0
	fi
}

#arg: $1: col_no
function op_moving_up() {
	flag_1=0
	flag_2=0
	for((y = 1; y < $num_row; y++))
	do
		if [[ ($flag_1 -eq 0) && ($[matrix[$1, $y]] -eq 1) && ($[matrix[$1, $[$y-1]]] -eq 0) ]]
		then
			matrix[$1, $[$y-1]]=1
			op_appear $1 $[$y-1]
			flag_1=1
		fi
		if [[ ($flag_2 -eq 0) && ($[matrix[$1, $y]] -eq 0) && ($[matrix[$1, $[$y-1]]] -eq 1) ]]
		then
			matrix[$1, $[$y-1]]=0
			op_disappear $1 $[$y-1]
			flag_2=1
		fi
	done
	if [[ flag_1 -eq 0 ]]
	then
		matrix[$1, $[$num_row-1]]=1
		op_appear $1 $[$num_row-1]
	fi
	if [[ flag_2 -eq 0 ]]
	then
		matrix[$1, $[$num_row-1]]=0
		op_disappear $1 $[$num_row-1]
	fi
}

function op_move() {
    for ((x = 1; x < $num_col; x++))
	do
		if [[ $[$CIRCLE % $[op_speed[$x]]] -eq 0 ]]
		then
			if [[ $[op_direct[$x]] -eq 0 ]]
			then
				op_moving_up $x
			else
				op_moving_down $x
			fi 
		fi
	done
}

function op_create() {
	for ((x = 0; x < $num_col; x++)); do
		for ((y = 0; y < $num_row; y++)); do
			matrix[$x, $y]=0
		done
	done
}

#arg: $1 col_no
function op_col_value_random() {
	num_op=$[$RANDOM % $[$num_row-6] +2]
	start_op=$[$RANDOM % $num_row]
	for((y = 0; y < $num_op; y++))
		do
		temp=$[($start_op + $y) % num_row]
		matrix[$1, $temp]=1;
	done
}

function op_value_random() {
	for ((x = 1; x < $num_col; x++))
	do
		op_col_value_random $x
	done
}

function op_direct_random() {
	for ((i = 1; i < $num_col; i++))
	do
		op_direct[$i]=$[$RANDOM % 2]
	done
}

function op_speed_random() {
	for ((i = 1; i < $num_col; i++))
	do
		op_speed[$i]=$[$RANDOM % $max_speed + 1]
	done
}

function op_display() {
	for ((x = 0; x < $num_col; x++)); do
		for ((y = 0; y < $num_row; y++)); do
			if [ $[matrix[$x, $y]] == '1' ]; then
				op_appear $x $y
			else
				op_disappear $x $y
			fi
			printf_x_y_center $[3 * $x + 3] $[$y + 1] "\u0020"
		done
	done
}

function op_init() {
	op_create
	op_value_random
	op_direct_random
	op_speed_random
}

#do not use
function op_test_value() {
	for ((y = 0; y < $num_row; y++))
	do
		for ((x = 0; x < $num_col; x++))
		do
			echo -ne $[matrix[$x, $y]]
		done
		echo -ne "\n"
	done
}

#do not use
function op_test_direct() {
	for ((x = 0; x < $num_col; x++))
	do
		echo -ne $[op_direct[$x]]
		echo -ne "\n"
	done
}

#do not use
function op_test_speed() {
	for ((x = 0; x < $num_col; x++))
	do
		echo -ne $[op_speed[$x]]
		echo -ne "\n"
	done
}

#do not use
function op_test_row() {
	for ((y = 0; y < $num_row; y++))
	do
        echo -ne $[matrix[$1, $y]]
	done
    echo -ne "\n"
}

########
# FROG #
########

function frog_appear() {
	printf_x_y_center $[3 * $frog_x + 1] $[$frog_y + 1] "\e[1;32m\u2588\e[0m"
	printf_x_y_center $[3 * $frog_x + 2] $[$frog_y + 1] "\e[1;32m\u2588\e[0m"
}

function frog_disappear() {
	if [[ $[matrix[$frog_x, $frog_y]] -eq 0 ]]
	then
		op_disappear frog_x frog_y
	else
		op_appear frog_x frog_y
	fi
}

function frog_check() {
	if [[ $HEALTH -le 0 ]]
	then
		printf_x_y 1 3 "LOSE"
		game_over
	else
		if [[ $[matrix[$frog_x, $frog_y]] -eq 1 ]]
		then
			HEALTH=$[$HEALTH - 1]
			( mplayer frog_kick.mp3 </dev/null >/dev/null 2>&1 )&
		fi
	fi
}

function frog_move() {
	if [ $frog_x -le 0 ]
	then
		frog_x=0
	elif [ $frog_x -ge $num_col ]
	then
		printf_x_y 1 3 "WIN "
		next_level
	fi

	if [ $frog_y -le 0 ]
	then
		frog_y=0
	elif [ $frog_y -ge $num_row ]
	then
		frog_y=$[$num_row - 1]
	fi
}

function frog_control() {
	frog_check
	case "$KEY" in
	A) # Up
		frog_disappear
		frog_y=$[$frog_y - 1]
		frog_move
		;;
	B) # Down
		frog_disappear
		frog_y=$[$frog_y + 1]
		frog_move
		;;
	C) # Right
		frog_disappear
		frog_x=$[$frog_x + 1]
		frog_move
		;;
	D) # Left
		frog_disappear
		frog_x=$[$frog_x - 1]
		frog_move
		;;
	esac
	KEY=''
	frog_appear
}

function frog_init() {
	frog_x=0
	frog_y=$[($num_row - 1) / 2]
}

###########
#processor#
###########

function processor() {
	(
		sleep $TIMING
		kill -ALRM $$
	) &
	CIRCLE=$[($CIRCLE + 1)%max_circle]
	printf_x_y 1 1
	printf "HEALTH: %5d\n" $HEALTH
	printf_x_y 1 2
	printf "LEVEL : %5d\n" $LEVEL
	frog_control
	op_move
}

########
# INIT #
########

function title_screen() {
	( mplayer -loop 0 frog_main_theme.mp3 </dev/null >/dev/null 2>&1 ) &
	clear
	printf_x_y 1 1 "\e[1;32m _____ _          _____                _____     _             \e[0m"
	printf_x_y 1 2 "\e[1;32m|_   _| |_ ___   |   __|___ ___ ___   |  _  |___|_|___ ___ ___ \e[0m"
	printf_x_y 1 3 "\e[1;32m  | | |   | -_|  |   __|  _| . | . |  |   __|  _| |   |  _| -_|\e[0m"
	printf_x_y 1 4 "\e[1;32m  |_| |_|_|___|  |__|  |_| |___|_  |  |__|  |_| |_|_|_|___|___|\e[0m"
	printf_x_y 1 5 "\e[1;32m                               |___|                           \e[0m"
	printf_x_y 1 6 "\e[1;36m                    Choose one below:                       \e[0m"
	printf_x_y 1 8 "\e[1;36m                    1. New Game                       \e[0m"
	printf_x_y 1 9 "\e[1;36m                    2. Record                       \e[0m"
}

function next_level_screen() {
	( mplayer frog_next_level.mp3 </dev/null >/dev/null 2>&1 ) &
	clear
	printf_x_y 1 1 "\e[0;31m _____ _____ __ __ _____    __    _____ _____ _____ __    \e[0m"
	printf_x_y 1 2 "\e[1;31m|   | |   __|  |  |_   _|  |  |  |   __|  |  |   __|  |   \e[0m"
	printf_x_y 1 3 "\e[0;32m| | | |   __|-   -| | |    |  |__|   __|  |  |   __|  |__ \e[0m"
	printf_x_y 1 4 "\e[1;32m|_|___|_____|__|__| |_|    |_____|_____|\___/|_____|_____|\e[0m"
	printf_x_y 1 6 "\e[1;36m              Press enter to next level                   \e[0m"
	read
}

function game_over_screen() {
	( mplayer frog_game_over.mp3 </dev/null >/dev/null 2>&1 ) &
	clear
	printf_x_y 1 1 "\e[0;31m _____ _____ _____ _____    _____ _____ _____ _____ \e[0m"
	printf_x_y 1 2 "\e[1;31m|   __|  _  |     |   __|  |     |  |  |   __| __  |\e[0m"
	printf_x_y 1 3 "\e[0;32m|  |  |     | | | |   __|  |  |  |  |  |   __|    -|\e[0m"
	printf_x_y 1 4 "\e[1;32m|_____|__|__|_|_|_|_____|  |_____|\___/|_____|__|__|\e[0m"
	printf_x_y 1 6 "\e[1;36m              Press enter to continue               \e[0m"
	printf_x_y 1 8 "─────────▄██████▀▀▀▀▀▀▄"
	printf_x_y 1 9 "─────▄█████████▄───────▀▀▄▄"
	printf_x_y 1 10 "──▄█████████████───────────▀▀▄"
	printf_x_y 1 11 "▄██████████████─▄▀───▀▄─▀▄▄▄──▀▄"
	printf_x_y 1 12 "███████████████──▄▀─▀▄▄▄▄▄▄────█"
	printf_x_y 1 13 "█████████████████▀█──▄█▄▄▄──────█"
	printf_x_y 1 14 "███████████──█▀█──▀▄─█─█─█───────█"
	printf_x_y 1 15 "████████████████───▀█─▀██▄▄──────█"
	printf_x_y 1 16 "█████████████████──▄─▀█▄─────▄───█"
	printf_x_y 1 17 "█████████████████▀███▀▀─▀▄────█──█"
	printf_x_y 1 18 "████████████████──────────█──▄▀──█"
	printf_x_y 1 19 "████████████████▄▀▀▀▀▀▀▄──█──────█"
	printf_x_y 1 20 "████████████████▀▀▀▀▀▀▀▄──█──────█"
	printf_x_y 1 21 "▀████████████████▀▀▀▀▀▀──────────█"
	printf_x_y 1 22 "──███████████████▀▀─────█──────▄▀"
	printf_x_y 1 23 "──▀█████████████────────█────▄▀"
	printf_x_y 1 24 "────▀████████████▄───▄▄█▀─▄█▀"
	printf_x_y 1 25 "──────▀████████████▀▀▀──▄███"
	printf_x_y 1 26 "──────████████████████████─█"
	printf_x_y 1 27 "─────████████████████████──█"
	printf_x_y 1 28 "────████████████████████───█"
	printf_x_y 1 29 "────██████████████████─────█"
	printf_x_y 1 30 "────██████████████████─────█"
	printf_x_y 1 31 "────██████████████████─────█"
	printf_x_y 1 32 "────██████████████████─────█"
	printf_x_y 1 33 "────██████████████████▄▄▄▄▄█"
	read
}

function new_game() {
	clear
	KEY=''
	op_init
	op_display
	frog_init
	frog_appear	
	trap processor ALRM
	processor
}

function next_level() {
	trap : ALRM # disable interupt
	next_level_screen
	num_col=$[$num_col + 1]
	HEALTH=$[$HEALTH + 2]
	LEVEL=$[$LEVEL + 1]
	new_game
}

function game_over() {
	trap : ALRM # disable interupt
	game_over_screen
	num_col=5
	HEALTH=10
	LEVEL=1
	new_game
}
function Record(){
	
}
function game_init() {
	printf "\e[?25l" # Turn off cursor
	trap game_exit ERR EXIT
	while :
	do
		clear
		title_screen
		read -rsn1 MENU_KEY
		case "$MENU_KEY" in
		1) 
			new_game
			break
			;;
		2) 	
			Record
			;;
		*) 	echo " Sorry, I dont know what you want"
		esac
	done
}

function game_exit() {
	printf "\e[?9l"         # Turn off mouse reading
	printf "\e[?12l\e[?25h" # Turn on cursor
	# kill $(ps aux | grep "frog.sh" | awk '{print $2}')
	clear
}

########
# MAIN #
########

# kill $(ps aux | grep "KICK.mp3" | awk '{print $2}')
game_init
#while :
#do

#done

while :
	do
	read -rsn1 KEY
done


