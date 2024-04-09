#!/bin/bash

FILE="src/config.h"

# increament BUILD_NUMBER
CURRENT_VALUE=$(awk "/BUILD_NUMBER/{print \$3}" "$FILE")
NEW_VALUE=$((CURRENT_VALUE + 1))
sed -i "s/BUILD_NUMBER\s\+[0-9]\+/BUILD_NUMBER ${NEW_VALUE}/g" "$FILE"
