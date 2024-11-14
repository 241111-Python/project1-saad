#!/bin/bash

# Function to print game grid
function print_grid() {
    printf "\n"
    for row in {0..2}; do
        for col in {0..2}; do
            n=$(( 1+row*3+col ))
            if [ "${!n}" == 0 ]; then
                printf "* "
            elif [ "${!n}" == 1 ]; then
                printf "X "
            else
                printf "0 "
            fi
        done
        printf "\n"
    done
}