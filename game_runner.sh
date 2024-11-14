#!/bin/bash

for i in $(seq "$1"); do
	./tictactoe.sh -a > /dev/null
done
./game_analyzer.sh