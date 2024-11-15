#!/bin/bash

# Imports
source ./game_library.sh

# Checks if data exists
data_file="tictactoe_data.csv"

if [ ! -f "$data_file" ]; then
  echo "No data available"
  exit 0
fi

# Setup game stats and records files
stats="game_stats.txt"
records="game_record.txt"
records_tmp="game_record_tmp.txt"
touch "$records_tmp"

if [ ! -f "$stats" ]; then
  touch "$stats"
  echo "Created $stats"
fi

if [ ! -f "$records" ]; then
  touch "$records"
  echo -e "Created $records\n"
fi

# Print overall game stats
num_games=0
games_won=0
games_drawn=0
avg_moves=0
win_rate=0
draw_rate=0
declare -A first_move_win_count
{
read -r
while IFS=, read -r date winner moves first_move board
do
    (( num_games+=1 ))
    avg_moves=$(echo "scale=2; ($avg_moves*($num_games-1)+$moves) / $num_games" | bc) # Calculate moving average
    if [ "$winner" == 1 ]; then
        (( games_won+=1 ))
    elif [ "$winner" == 0 ]; then
        (( games_drawn+=1 ))
    fi
    win_rate=$(echo "scale=2; ($games_won / $num_games)*100" | bc) # using bc for floating point calculation
    draw_rate=$(echo "scale=2; ($games_drawn / $num_games)*100" | bc)
    if [ "$winner" != 0 ]; then
        (( first_move_win_count[$first_move]+=1 ))
    fi
done
} < $data_file

# Find best first move
max_wins=0
best_move=0
for k in "${!first_move_win_count[@]}"; do # iterate over keys with !
  if [ "${first_move_win_count[$k]}" -gt "$max_wins" ]; then
    best_move=$k
    max_wins=${first_move_win_count[$k]}
  fi
done

grid=(0 0 0 0 0 0 0 0 0 0)
grid[best_move]="!"
{
echo "Aggregate Statistics for Games"
echo "Last Ran: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================="
echo "Total Games Played: $num_games"
echo "Win percentage: $win_rate%"
echo "Draw percentage: $draw_rate%"
echo "Average number of moves: $avg_moves"
echo "Best first move: Square $((best_move+1))"
print_grid "${grid[@]}"
echo
} > $stats

# Print games
{
read -r 
while IFS=, read -r date winner moves first_move board
do
    {
    IFS=' ' read -r -a grid <<< "$board" # Convert board state into array
    print_grid "${grid[@]}"
    echo "$date"
    if [ "$winner" != 0 ]; then
        echo "Winner: Player $winner"
    else
        echo "Draw"
    fi
    echo "Number of Moves: $moves"
    } >> $records_tmp
done
} < $data_file

# Display the records in a grid format
column_count=4
while (( (num_games % column_count) != 0 )); do
  ((column_count--)) # Attempt to find an appropriate number of columns
done

# Remove whitespace and pipe into pr to transform data into grid format
tail -n +2 "$records_tmp" | pr -t -$column_count > $records
rm $records_tmp