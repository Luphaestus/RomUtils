#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <dir1> <dir2>"
    exit 1
fi

DIR1="$1"
DIR2="$2"

# Perform the diff operation
sudo diff -rqy "$DIR1" "$DIR2" 2>/dev/null | \
sed 's/: /\//g' | sed 's/Only in //g' | sed 's/ differ//g' \
| sed 's/Files //g' | sed 's/ and /\n/g'
