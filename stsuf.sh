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

declare -A suffix_count

while IFS= read -r file; do
    name="$(basename "$file")"

    if [[ "$name" =~ ^\.[^.]+$ ]]; then
        suffix="no suffix"

    elif [[ "$name" =~ \.([^./]+)$ ]]; then
        suffix=".${BASH_REMATCH[1]}"

    else
        suffix="no suffix"
    fi

    ((suffix_count["$suffix"]++))

done < <(find "$DIR_PATH" -type f 2>/dev/null)

if [[ ${#suffix_count[@]} -eq 0 ]]; then
    echo "Нет файлов в каталоге '$DIR_PATH'."
    exit 0
fi

for key in "${!suffix_count[@]}"; do
    echo "$key: ${suffix_count[$key]}"
done | sort -t':' -k2 -nr
