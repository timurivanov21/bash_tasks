#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Использование: $0 <каталог>"
    exit 1
fi

DIR_PATH="$1"

if [[ ! -d "$DIR_PATH" ]]; then
    echo "Ошибка: '$DIR_PATH' не является каталогом!"
    exit 1
fi

USER_NAME="$(whoami)"
DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cd "$DIR_PATH" || exit 1

for file in *.txt; do
    [[ "$file" == "*.txt" ]] && continue

    if [[ -f "$file" ]]; then
        tmp_file="$(mktemp)"
        echo "Approved $USER_NAME $DATE" > "$tmp_file"
        cat "$file" >> "$tmp_file"

        mv "$tmp_file" "$file"
        echo "Добавлена строка в: $file"
    fi
done

echo "Готово!"
exit 0
