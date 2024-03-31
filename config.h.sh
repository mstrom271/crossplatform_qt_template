#!/bin/bash
# Reads variables from config.h in C format and adds it to the bash script environment

FILE="src/config.h"

while IFS= read -r line
do
    line=$(echo "$line" | tr -d '\r');      # windows end of line adaptation
    read -r prefix key value <<< "$line"
    if [[ $prefix == "#define" ]]; then
        value=${value//\"/}                 # delete ""
        export "$key"="$value"
    fi
done < "$FILE"
