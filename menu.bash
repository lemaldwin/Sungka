#!/bin/bash

echo "Game Menu"
echo "1. Single Player"
echo "2. Two-Player"
echo "3. Help"
echo "4. Exit"

read -p "Choice: " selection

case $selection in
	1) echo "Starting Game in Single Player Mode"
		;;
	2) echo "Starting Game in Two-Player Mode"
		;;
	3) echo "Help"
		;;
	4) echo "Bye"
		exit 0
		;;
	*) echo "Invalid choice. Exiting..."
		;;
esac
exit 0
