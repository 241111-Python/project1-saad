#!/bin/bash

# Imports
source ./game_library.sh
data_file="tictactoe_data.csv"

# Setup game stats and records files
stats="game_stats.txt"
records="game_record.txt"

if [ ! -f "$stats" ]; then
  touch "$stats"
  echo "Created $stats"
fi

if [ ! -f "$records" ]; then
  touch "$records"
  {
    echo "Game Record"
    echo "=============================="
  } >> $records
  echo -e "Created $records\n"
fi

# Print overall game stats
num_games=0
games_won=0
avg_moves=0
win_rate=0
{
read -r
while IFS=, read -r date winner moves board
do
    (( num_games+=1 ))
    avg_moves=$(echo "scale=2; ($avg_moves*($num_games-1)+$moves) / $num_games" | bc) # Calculate moving average
    if [ "$winner" == 1 ]; then
        (( games_won+=1 ))
    fi
    win_rate=$(echo "scale=2; $games_won / $num_games" | bc) # using bc for floating point calculation
done
} < $data_file

{
echo "Aggregate Statistics for games"
echo "Last Ran: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================="
echo "Total Games Played: $num_games"
echo "Win percentage: $win_rate%"
echo "Average number of moves: $avg_moves"
echo
} > $stats

# Print games
{
read -r 
while IFS=, read -r date winner moves board
do
    {
    IFS=', ' read -r -a grid <<< "$board" # Convert board state into array
    print_grid "${grid[@]}"
    echo "$date"
    if [ "$winner" != 0 ]; then
        echo "Winner: Player $winner"
    else
        echo "Draw"
    fi
    echo "Number of Moves: $moves"
    } >> $records
done
} < $data_file