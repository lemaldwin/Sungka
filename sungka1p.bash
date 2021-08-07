#!/bin/bash
#Sungka Game

initializeGame(){
	HOUSES=(7 0 7 0 7 0 7 0 0 7 0 7 0 7 0 0)
	TURN=1
	NOMOVESYET=true
	echo "">sungka1p.log
	#0 to 6 - 7-1 P1 houses
	#7 - P1 base
	#8 to 14 - 7-1 P2 houses
	#15 - P2 base
}

getPlayerName() {
	echo -n "Enter Player's name: "
	read PLAYER1
	PLAYER2="Sungka-bot"
}
identifyBotMove() {
	INPUT=""
	#check if #piece = house#
	for ITEM in $(seq 1 7); do
		#start with lowest house#
		((VALUE=15-ITEM))
		if [ "${HOUSES[$VALUE]}" -eq "$ITEM" ]; then
			INPUT=$ITEM
			break
		fi
	done

	#get the most # of stones
	if [ "$INPUT" = "" ]; then
		HIGHEST=1
		for ITEM in $(seq 8 14); do
			if [ "${HOUSES[$ITEM]}" -ge "$HIGHEST" ]; then
				HIGHEST=${HOUSES[$ITEM]}
				(( INPUT=15-$ITEM ))
			fi
		done
	fi

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
	echo "         ---$PLAYER1's Side---"
	echo "Houses   | 1 2 3 4 5 6 7 |"
	echo "         -----------------"
	echo "Pieces   | ${HOUSES[6]} ${HOUSES[5]} ${HOUSES[4]} ${HOUSES[3]} ${HOUSES[2]} ${HOUSES[1]} ${HOUSES[0]} |"
	echo -n "Base:${HOUSES[7]}  "
	if [ "${HOUSES[7]}" -le 9 ]; then echo -n " ";fi 
	echo "-----------------"
	echo "         ----------------- Base:${HOUSES[15]}"
	echo "         | ${HOUSES[8]} ${HOUSES[9]} ${HOUSES[10]} ${HOUSES[11]} ${HOUSES[12]} ${HOUSES[13]} ${HOUSES[14]} | Pieces "
	echo "         ----------------- "
	echo "         | 7 6 5 4 3 2 1 | Houses"
	echo "         ---$PLAYER2's Side---"
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
	if $NOMOVESYET; then
		if [ "$INPUT" -eq 7 ]; then
			VALIDINPUT=true
			NOMOVESYET=false
		else
			VALIDINPUT=false
			echo "First move of first player should be house#7">>sungka2p.log
		fi
	fi
}

WINNER=""
getPlayerName
checkIfFirst

initializeGame
while [ "$WINNER" = "" ]; do
	clear
	displayRound
	displayBoard
	tail -n 12 sungka1p.log

	#Check which player will do the move
	(( WHOSETURN=TURN%2 ))
	if [ "$WHOSETURN" -eq 1 ]; then
		TURNPLAYER=$PLAYER1
		echo -n "$TURNPLAYER's turn: Enter the house to get pieces from(1-7): "
		read INPUT
		#Check input/move validity,(forfeit, house#, reset, exit/quit)
		checkInput $INPUT
		if $RESET; then
			initializeGame
			continue
		fi
		if !($VALIDINPUT); then
			echo "Invalid input. Try again.">>sungka1p.log
			continue
		fi
	else
		TURNPLAYER="Sungka-bot"
		identifyBotMove
	fi

##LOG##
	echo "$TURNPLAYER's turn: Enter the house to get pieces from(1-7): $INPUT" >>sungka1p.log

#MOVE EXECUTION
	if [ "$WHOSETURN" -eq 1 ]; then
		(( HOUSENUM = 7-INPUT ))
	else
		(( HOUSENUM = 15 -INPUT))
	fi
	MOVE=${HOUSES[$HOUSENUM]} #number of pieces in the house
	HOUSES[$HOUSENUM]=0
	
	#move invalid if there are no pieces in the selected house
	if [ "$MOVE" -eq 0 ]; then
		echo "Invalid input. Try again.">>sungka1p.log 
		continue
	fi
	
	ITEMCTR=1 #reset counter variable
	until [ "$MOVE" -eq 0 ]; do
		
		(( ADDRESS=HOUSENUM+ITEMCTR ))
		
		while [ "$ADDRESS" -gt 15 ]; do
			((ADDRESS= ADDRESS-16))
		done
		
		((ITEMCTR+=1))
		if ( [ "$WHOSETURN" -eq 1 ] && [ "$ADDRESS" -eq 15 ] ); then
			continue #skip P2 base if its P1's turn
		elif ( [ "$WHOSETURN" -eq 0 ] && [ "$ADDRESS" -eq 7 ] ); then
			continue #skip P1 base if its P2's turn
		fi

		((MOVE=MOVE-1))
		
		#add value to the address
		(( HOUSES[$ADDRESS]+=1 ))
		
		#Rule 6A
		if (([ "${HOUSES[$ADDRESS]}" -gt 1 ] && [ "$MOVE" -eq 0 ]) && 				([ "$ADDRESS" -ne 7 ] && [ "$ADDRESS" -ne 15 ] )); then
			ITEMCTR=1
			MOVE=${HOUSES[$ADDRESS]}
			HOUSENUM=$ADDRESS
			HOUSES[$ADDRESS]=0
		fi
	done
		
	#check for winner
	if [ "${HOUSES[7]}" -gt 24 ]; then
		WINNER="$PLAYER1"
		break
	elif [ "${HOUSES[15]}" -gt 24 ]; then
		WINNER="$PLAYER2"
		break
	fi	

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
	else
		SKIPPER=$PLAYER2
		for ITM in $(seq 8 14); do
			if [ "${HOUSES[$ITM]}" -gt 0 ]; then
				SKIP=false
			fi
		done
	fi
	if $SKIP; then
		echo "$SKIPPER skipped, no available piece" >>sungka1p.log
		((TURN+=1))
	fi

	#RULE 7a
	#check if turn would repeat
	if ( [ "$WHOSETURN" -eq 1 ] && [ "$ADDRESS" -eq 7 ] ); then
		continue #repeat P1's turn if last placement is on P1 base
	elif ( [ "$WHOSETURN" -eq 0 ] && [ "$ADDRESS" -eq 15 ] ); then
		continue #repeat P2's turn if last placement is on P2 base
	fi	

	#check if last landing place is player's house
	#RULE 7b
	((OPPADDRESS=14-ADDRESS))
	if ([ "${HOUSES[$ADDRESS]}" -eq 1 ] && [ "${HOUSES[$OPPADDRESS]}" -gt 0 ]); then 
	#check if house is empty before 
		if ( [ "$WHOSETURN" -eq 1 ] && [ "$ADDRESS" -lt 7 ] ); then
			echo "${HOUSES[$OPPADDRESS]} pieces from enemy, CAPTURED!">>sungka2p.log
			((HOUSES[7]=${HOUSES[7]}+${HOUSES[$OPPADDRESS]}+1))
			HOUSES[$ADDRESS]=0
			HOUSES[$OPPADDRESS]=0
		elif ( [ "$WHOSETURN" -eq 0 ] && ([ "$ADDRESS" -gt 7 ] && 				[ "$ADDRESS" -lt 15 ])); then
			echo "${HOUSES[$OPPADDRESS]} pieces from enemy, CAPTURED!">>sungka2p.log
			((HOUSES[15]=${HOUSES[15]}+${HOUSES[$OPPADDRESS]}+1))
			HOUSES[$ADDRESS]=0
			HOUSES[$OPPADDRESS]=0
		fi	
	fi
	#next player's turn
	((TURN+=1)) 
done

toilet "$WINNER WINS! Congratulations"
read AGAIN
exit 0
