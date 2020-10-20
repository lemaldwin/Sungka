#!/bin/bash
#Sungka Game

initializeGame(){
	HOUSES=(7 0 7 0 7 0 7 0 0 7 0 7 0 7 0 0)
	TURN=1
	echo "">sungka.log
	#0 to 6 - 7-1 P1 houses
	#7 - P1 base
	#8 to 14 - 7-1 P2 houses
	#15 - P2 base
}
getPlayerName() {
	echo -n "Enter Player1's name: "
	read PLAYER1
	echo -n "Enter Player2's name: "
	read PLAYER2
}
displayRound(){
	if [ "$TURN" -eq 1 ]; then
		echo "GAME START!!!"
	else
		echo "Turn #$TURN"
	fi
}
displayBoard(){
	#fix board display for every turn
	echo "         -----------------"
	echo "P1 Houses| 1 2 3 4 5 6 7 |"
	echo "$PLAYER1   -----------------"
	echo "Pieces   | ${HOUSES[6]} ${HOUSES[5]} ${HOUSES[4]} ${HOUSES[3]} ${HOUSES[2]} ${HOUSES[1]} ${HOUSES[0]} |"
	echo -n "P1Base:${HOUSES[7]}"
	if [ "${HOUSES[7]}" -le 9 ]; then echo -n " ";fi 
	echo "-----------------"
	echo "         ----------------- P2Base:${HOUSES[15]}"
	echo "         | ${HOUSES[8]} ${HOUSES[9]} ${HOUSES[10]} ${HOUSES[11]} ${HOUSES[12]} ${HOUSES[13]} ${HOUSES[14]} | Pieces "
	echo "         ----------------- $PLAYER2"
	echo "         | 7 6 5 4 3 2 1 | P2 Houses"
	echo "         -----------------"
}

checkInput(){		
	INPUT=$1
	VALIDINPUT=false
	RESET=false
	CHECKINPUT=$(echo $INPUT| tr -d [:digit:])
	if [ "$CHECKINPUT" = "" ]; then
		if ([ "$INPUT" -lt 8 ] && [ "$INPUT" -gt 0 ]); then
			VALIDINPUT=true
		else
			VALIDINPUT=false
		fi
	elif [ "$CHECKINPUT" = "quit" ]; then
		echo "You quit! LOSER!"
		exit 0;
	else
		case $INPUT in
			'forfeit')
				if [ "$WHOSETURN" -eq 1 ]; then
					WINNER=$PLAYER2
				elif [ "$WHOSETURN" -eq 0 ]; then
					WINNER=$PLAYER1
				fi;;
			'quit')
				exit 0;;
			'reset')
				RESET=true;;
			*)
				VALIDINPUT=false;;
		esac
	fi
}

PLAYER1="Chronix"
PLAYER2="Pancho"
WINNER=""
#getPlayerName
initializeGame
while [ "$WINNER" = "" ]; do
	clear
	displayRound
	displayBoard
	tail -n 6 sungka.log

	#Check which player will do the move
	(( WHOSETURN=TURN%2 ))
	if [ "$WHOSETURN" -eq 1 ]; then
		TURNPLAYER=$PLAYER1
	else
		TURNPLAYER=$PLAYER2
	fi

	echo -n "$TURNPLAYER's turn: Enter the house to get pieces from(1-7): "
	read INPUT
#Check input/move validity,(forfeit, house#, reset, exit/quit)
	checkInput $INPUT
	if $RESET; then
		initializeGame
		continue
	fi
	if !($VALIDINPUT); then
		echo "Invalid input. Try again.">>sungka.log
		continue
	fi
##LOG##
	echo "$TURNPLAYER's turn: Enter the house to get pieces from(1-7): $INPUT" >>sungka.log
	
#MOVE EXECUTION
	if [ "$WHOSETURN" -eq 1 ]; then
		(( HOUSENUM = 7-INPUT ))
	else
		(( HOUSENUM = 15 -INPUT))
	fi
	MOVE=${HOUSES[$HOUSENUM]} #number of pieces in the house
	HOUSES[$HOUSENUM]=0
	
	ITEMCTR=1 #reset counter variable
	until [ "$MOVE" -eq 0 ]; do
		
		(( ADDRESS=HOUSENUM+ITEMCTR ))
		
		while [ "$ADDRESS" -gt 15 ]; do
			((ADDRESS= ADDRESS-16))
		done
		
		((MOVE=MOVE-1))
		((ITEMCTR+=1))
		if ( [ "$WHOSETURN" -eq 1 ] && [ "$ADDRESS" -eq 15 ] ); then
			continue #skip P2 base if its P1's turn
		elif ( [ "$WHOSETURN" -eq 0 ] && [ "$ADDRESS" -eq 7 ] ); then
			continue #skip P1 base if its P2's turn
		fi
		
		#DEBUG#####------------------------------
		#echo "add value at: $ADDRESS">>sungka.log #DEBUG
		#echo "Moves left: $MOVE" >>sungka.log #DEBUG
		#----------------------------------------------

		#add value to the address
		(( HOUSES[$ADDRESS]+=1 ))
		
		#Rule 6A
		if (([ "${HOUSES[$ADDRESS]}" -gt 1 ] && [ "$MOVE" -eq 0 ]) && ([ "$ADDRESS" -ne 7 ] || [ "$$ADDRESS" -ne 15 ] )); then
			echo "Enter REPEAT STATEMENT" >>sungka.log #DEBUG
			ITEMCTR=0
			MOVE=${HOUSES[$ADDRESS]}
			HOUSES[$ADDRESS]=0
		fi
	done
	
	#DEBUG------------------------------------
	TOTAL=0
	for VALUE in ${HOUSES[*]}; do
		((TOTAL=TOTAL+VALUE))
	done

	FILENAME=echo "sungka.log$(date +%Y +%M +%D +%H %m)"
	echo "Turn: $TURN Last Drop at: $ADDRESS TotalValue: $TOTAL">>$FILENAME #DEBUG
	#---------------------------------------------

	#check if last landing place is player's house
	#RULE 7b
	((OPPADDRESS=14-ADDRESS))
	if ([ "${HOUSES[$ADDRESS]}" -eq 1 ] && [ "${HOUSES[$OPPADDRESS]}" -gt 0 ]); then #check if house is empty before 
		#echo "HOUSE is EMPTY before">>sungka.log #DEBUG		
		if ( [ "$WHOSETURN" -eq 1 ] && [ "$ADDRESS" -lt 7 ] ); then
			#echo "ENEMY CAPTURED!">>sungka.log #DEBUG
			((HOUSES[7]=${HOUSES[7]}+${HOUSES[$OPPADDRESS]}+1))
			HOUSES[$ADDRESS]=0
			HOUSES[$OPPADDRESS]=0
		elif ( [ "$WHOSETURN" -eq 0 ] && ([ "$ADDRESS" -gt 7 ] && [ "$ADDRESS" -lt 15 ])); then
			((OPPADDRESS=14-ADDRESS))
			((HOUSES[15]=${HOUSES[15]}+${HOUSES[$OPPADDRESS]}+1))
			HOUSES[$ADDRESS]=0
			HOUSES[$OPPADDRESS]=0
		fi	
	fi
	
	#RULE 7a
	#check if turn would repeat
	if ( [ "$WHOSETURN" -eq 1 ] && [ "$ADDRESS" -eq 7 ] ); then
		continue #repeat P1's turn if last placement is on P1 base
	elif ( [ "$WHOSETURN" -eq 0 ] && [ "$ADDRESS" -eq 15 ] ); then
		continue #repeat P2's turn if last placement is on P2 base
	fi

	#check for winner
	if [ "${HOUSES[7]}" -gt 24 ]; then
		WINNER="$PLAYER1"
		break
	elif [ "${HOUSES[15]}" -gt 24 ]; then
		WINNER="$PLAYER2"
		break
	fi

	((TURN+=1)) #next players turn

	#RULE 8A - Skip if all houses have 0 piece
	SKIP=true
	(( WHOSETURN=TURN%2 ))
	if [ "$WHOSETURN" -eq 1 ]; then
		SKIPPER=$PLAYER1
		for ITM in $(seq 0 6); do
			if [ "${HOUSES[$ITM]}" -gt 0 ]; then
				SKIP=false
			fi
		done
	elif [ "$WHOSETURN" -eq 0 ]; then
		SKIPPER=$PLAYER2
		for ITM in $(seq 8 14); do
			if [ "${HOUSES[$ITM]}" -gt 0 ]; then
				SKIP=false
			fi
		done
	fi
	if $SKIP; then
		echo "$SKIPPER skipped, no available piece" >>sungka.log
		((TURN+=1))
	fi
done
toilet "$WINNER WINS!! Congratulations"
exit 0
