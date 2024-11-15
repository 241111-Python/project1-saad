#!/bin/bash

./cleanup.sh && echo "Cleaning up"
./game_runner.sh "${1:-2}" && echo "Running ${1:-2} games"
cat game_stats.txt
cat game_record.txt