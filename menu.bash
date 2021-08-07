#!/bin/bash
#Game Menu

clear
while true ;do
        echo "Menu:"
        echo "1. Single Player"
        echo "2. 2-Player Mode"
        echo "3. Rules and Regulations"
        echo "4. Quit"
        echo -n "Enter the number of your choice: "
        read INPUT

        case $INPUT in
                1) echo "Single player mode: "
						./sungka1p.bash
						;;
                2) echo "2-player mode"
                        ./sungka2p.bash
                        ;;
                3)
                        clear
                        cat Rules\ and\ Regulations.txt;;
                4) echo "Goodbye."
                        break;;
                *) echo "Invalid choice" ;;
        esac
done
exit 0
