#!/bin/bash

FILE="src/config.h"

while IFS=' ' read -r prefix key value
do
    if [[ $prefix == "#define" ]]; then
        value=${value//\"/}
        export "$key"="$value"
    fi
done < "$FILE"
