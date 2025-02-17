#!/bin/bash

dir_a="$1"
dir_b="$2"

dirs_in_a=$(find "$dir_a" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

dirs_in_b=$(find "$dir_b" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")

common_dirs=$(comm -12 <(echo "$dirs_in_a" | sort) <(echo "$dirs_in_b" | sort))

if [ -z "$common_dirs" ]; then
    echo "No common directories found between $dir_a and $dir_b."
else
    echo "Common directories found: $common_dirs"
    for dir in $common_dirs; do
        read -p "Do you want to copy directory $dir from $dir_a to $dir_b? (y/n): " choice
        if [ "$choice" = "y" ]; then
            rm -rf "$dir_b/$dir"
            cp -a "$dir_a/$dir" "$dir_b/"
            echo "Directory $dir copied from $dir_a to $dir_b."
        else
            echo "Skipped copying directory $dir."
        fi
    done
fi
