#!/bin/bash


DIR_PATH="."
MASK="*"
NUMBER=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --path)
            DIR_PATH="$2"
            shift 2
            ;;
        --mask)
            MASK="$2"
            shift 2
            ;;
        --number)
            NUMBER="$2"
            shift 2
            ;;
        *)
            COMMAND="$1"
            shift
            break
            ;;
    esac
done

if [[ -z "$COMMAND" ]]; then
    echo "Ошибка: не указана команда обработки файлов."
    echo "Пример: $0 --path /var/log --mask '*.log' --number 4 gzip"
    exit 1
fi

if [[ ! -d "$DIR_PATH" ]]; then
    echo "Ошибка: каталог '$DIR_PATH' не существует."
    exit 1
fi

if [[ -z "$MASK" ]]; then
    echo "Ошибка: маска не может быть пустой."
    exit 1
fi

if [[ ! -x "$COMMAND" && ! $(command -v "$COMMAND") ]]; then
    echo "Ошибка: команда '$COMMAND' не найдена или не имеет права на исполнение."
    exit 1
fi

if (( NUMBER <= 0 )); then
    if command -v nproc &>/dev/null; then
        NUMBER=$(nproc)
    else
        NUMBER=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
    fi
fi

FILES=()
while IFS= read -r file; do
    FILES+=("$file")
done < <(find "$DIR_PATH" -type f -name "$MASK" 2>/dev/null | sort)

if (( ${#FILES[@]} == 0 )); then
    echo "Нет файлов, удовлетворяющих шаблону '$MASK' в '$DIR_PATH'."
    exit 0
fi

echo "Найдено файлов: ${#FILES[@]}"
echo "Одновременно будет запущено процессов: $NUMBER"
echo "Команда обработки: $COMMAND"
echo

active_jobs=0
total_files=${#FILES[@]}
processed=0

for file in "${FILES[@]}"; do
    "$COMMAND" "$file" &
    ((active_jobs++))
    ((processed++))
    echo "Запущено: $COMMAND $file (процессов: $active_jobs)"

    if (( active_jobs >= NUMBER )); then
        wait -n 2>/dev/null || wait
        ((active_jobs--))
    fi
done

wait

echo
echo "Обработка завершена. Всего обработано файлов: $processed"
exit 0
