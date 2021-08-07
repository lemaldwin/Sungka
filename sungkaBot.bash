#!/bin/bash

#check if #piece = house#
for ITEM in $(seq 1 7); do
	#start with lowest house#
	((VALUE=7-ITEM))
	if [ "${HOUSE[$VALUE]}" -eq "$ITEM" ]; then
		INPUT=$ITEM
		break
	fi
done

#get the most # of stones
for ITEM in $(seq 8 14); do
	HIGHEST=0
	if [ "${HOUSE[$ITEM]}" -gt "$HIGHEST" ]; then
		INPUT=${HOUSE[$ITEM]}
	fi
done

#Random INPUT generator
until $VALIDINPUT; do
	RNDINPUT=$(echo $RANDOM)
	(( INPUT=(RNDMINPUT%7) +1))
	checkInput $INPUT
done
