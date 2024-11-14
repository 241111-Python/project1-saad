#!/bin/bash

# Imports
source ./game_library.sh

# Script options
player_1_human=true
while getopts 'a' flag; do
  case "${flag}" in
    a) # sets player 1 to ai/random selection
    player_1_human=false ;;
    *) # Invalid option
    printf "Option not recognized\n"
  esac
done

# Setup raw game data file
data="tictactoe_data.csv"

if [ ! -f "$data" ]; then
  touch "$data"
  echo "date", "winner", "num_moves", "board" > $data
  echo -e "Created $data\n"
fi

# Init tic-tac-toe array and stats
board=(0 0 0 0 0 0 0 0 0)
num_moves=0
game_date=$(date '+%Y-%m-%d %H:%M:%S')

# Function to declare victory and write out game stats
function game_end() {
    print_grid "${board[@]}"
    if [ "$1" != 0 ]; then
        echo -e "\nWINNER: PLAYER $1"
    else
        echo -e "\nDRAW"
    fi
    echo "$game_date,$1,$num_moves,${board[*]}" >> $data
    exit 0
}

# Function to check game end
function win_check() {
    # 3 or -3 indicates full row/col/diag
    if [ "$1" == -3 ]; then game_end 2 return; fi
    if [ "$1" == 3 ]; then game_end 1; fi
}

# Function to check board state
function check_board_state() {
    # Check draw status
    if [ $num_moves == 9 ]; then
        game_end 0
    fi

    # Check game end
    target=0
    target_row=0
    target_col=0

    # Rows and cols
    for ((i = 0 ; i < 3; i++));
        do for ((j = 0 ; j < 3 ; j++));
            do ((target_row+=board[i*3+j]))
            ((target_col+=board[j*3+i])) 
        done
        win_check $target_row
        win_check $target_col
        target_row=0 # reset
        target_col=0 # reset
    done

    # Diagonals
    ((target+=(board[0]+board[4]+board[8]))) 
    win_check $target
    target=0 # reset

    ((target+=(board[2]+board[4]+board[6]))) 
    win_check $target
}

# AI selects choice from board
function ai_move() {
    # Get available choices
    valid_choices=()
    n=0
    for i in "${board[@]}";
        do if [ "$i" -eq 0 ]; then
            valid_choices+=("$n")
        fi
        (( n++ ))
    done
    random_select=$(( RANDOM % ${#valid_choices[@]} )) # Randomly generates index from alid choices array
    ai_choice="${valid_choices[$random_select]}" # Selects valid square choice

    # Make choice and check board
    (( board[ai_choice]+=$1 ))
    (( num_moves+=1 ))
    check_board_state
}

# Run until game end
while true; do
    print_grid "${board[@]}"

    # Player 1 move
    if $player_1_human; then
        choice_invalid=true
        while [[ $choice_invalid == true ]];
            do read -rp "Select square (1-9): " selection
            if ((selection >= 1 && selection <= 9)) && \
            [[ board[$selection-1] -eq 0 ]]; then
                    (( board[selection-1]++ ))
                    (( num_moves+=1 ))
                    choice_invalid=false
                else
                    printf "Invalid input. Please select a different square.\n\n"
            fi
            check_board_state
        done
    else
        ai_move 1
    fi

    # Player 2 move
    ai_move -1

done