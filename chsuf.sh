#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Использование: $0 <каталог> <старый_суффикс> <новый_суффикс>"
    exit 1
fi

DIR_PATH="$1"
OLD_SUFFIX="$2"
NEW_SUFFIX="$3"

if [[ ! -d "$DIR_PATH" ]]; then
    echo "Ошибка: '$DIR_PATH' не является каталогом!"
    exit 1
fi

if [[ ! "$OLD_SUFFIX" =~ ^\.[^.]+$ ]]; then
    echo "Ошибка: старый суффикс '$OLD_SUFFIX' некорректен!"
    echo "Суффикс должен начинаться с '.' и не содержать других '.'"
    exit 1
fi

if [[ ! "$NEW_SUFFIX" =~ ^\.[^.]+$ ]]; then
    echo "Ошибка: новый суффикс '$NEW_SUFFIX' некорректен!"
    echo "Суффикс должен начинаться с '.' и не содержать других '.'"
    exit 1
fi

find "$DIR_PATH" -type f -name "*$OLD_SUFFIX" | while IFS= read -r file; do
    new_name="${file/%$OLD_SUFFIX/$NEW_SUFFIX}"

    if [[ "$new_name" != "$file" ]]; then
        mv "$file" "$new_name"
        echo "Переименован: $file → $new_name"
    fi
done

echo "Все подходящие файлы переименованы."
exit 0
