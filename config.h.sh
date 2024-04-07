#!/bin/bash

FILE="src/config.h"

# increament BUILD_NUMBER
CURRENT_VALUE=$(awk "/BUILD_NUMBER/{print \$3}" "$FILE")
NEW_VALUE=$((CURRENT_VALUE + 1))
sed -i "s/BUILD_NUMBER\s\+[0-9]\+/BUILD_NUMBER ${NEW_VALUE}/g" "$FILE"

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
