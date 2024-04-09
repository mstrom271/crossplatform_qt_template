#!/bin/bash

FILE="src/config.h"

# Reads variables from config.h in C format and adds it to the bash script environment
while IFS= read -r line
do
    line=$(echo "$line" | tr -d '\r');      # windows end of line adaptation
    read -r prefix key value <<< "$line"
    if [[ $prefix == "#define" ]]; then
        value=${value//\"/}                 # delete ""
        export "$key"="$value"
    fi
done < "$FILE"
