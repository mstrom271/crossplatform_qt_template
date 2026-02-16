#!/usr/bin/bash
set -euox pipefail

# root dir of the project
PROJECT_DIR=$(realpath "$(dirname "$0")/..")

# Translations
while IFS= read -r lang
do
    lang=$(echo "$lang" | tr -d '\r')
    $QT_HOST_PATH/bin/lupdate $PROJECT_DIR/src/ -ts $PROJECT_DIR/translations/translation_$lang.ts #-no-obsolete
    $QT_HOST_PATH/bin/lrelease $PROJECT_DIR/translations/*.ts
done < "$PROJECT_DIR/translations/list.txt"
mkdir -p $PROJECT_DIR/rcc/rcc
mv $PROJECT_DIR/translations/*.qm $PROJECT_DIR/rcc/rcc
