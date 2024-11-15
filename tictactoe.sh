#!/bin/bash

# Imports
source ./game_library.sh

# Script options
function usage () {
    echo "Usage: $0 [ -ah ]"
    echo "  -a          Simulates a game between two computer opponents"
    echo "  -h          Show help message"
    exit 1
}

player_1_human=true
while getopts 'ah' flag; do
  case "${flag}" in
    a) # sets player 1 to ai/random selection
    player_1_human=false ;;
    h) #
    usage ;;
    *) # Invalid option
    printf "Option not recognized\n"
    usage
  esac
done

# Setup raw game data file
data="tictactoe_data.csv"

if [ ! -f "$data" ]; then
  touch "$data"
  echo "date", "winner", "num_moves", "first_move", "board" > $data
  echo -e "Created $data\n"
fi

# Init tic-tac-toe array and stats
board=(0 0 0 0 0 0 0 0 0)
num_moves=0
game_date=$(date '+%Y-%m-%d %H:%M:%S')
first_move=0
first_move_recorded=false

# Function to record first game move
function capture_first_move() {
    if [ $first_move_recorded == false ]; then
        first_move=$1
        first_move_recorded=true
    fi
}

# Function to declare victory and write out game stats
function game_end() {
    print_grid "${board[@]}"
    if [ "$1" != 0 ]; then
        echo -e "\nWINNER: PLAYER $1"
    else
        echo -e "\nDRAW"
    fi
    echo "$game_date,$1,$num_moves,$first_move,${board[*]}" >> $data
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

    # Check draw status
    if [ $num_moves == 9 ]; then
        game_end 0
    fi
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
    random_select=$(( RANDOM % ${#valid_choices[@]} )) # Randomly generates index from valid choices array
    ai_choice="${valid_choices[$random_select]}" # Selects valid square choice

    # Make choice and check board
    capture_first_move "$ai_choice"
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
            do read -rp "Select square (1-9): " player_choice
            if ((player_choice >= 1 && player_choice <= 9)) && \
            [[ board[$player_choice-1] -eq 0 ]]; then
                    capture_first_move "$player_choice"
                    (( board[player_choice-1]++ ))
                    (( num_moves+=1 ))
                    choice_invalid=false
                else
                    printf "Invalid input. Please select a different square.\n\n"
            fi
            check_board_state
        done
    else
        ai_move 1
        print_grid "${board[@]}"
    fi

    # Player 2 move
    ai_move -1

done