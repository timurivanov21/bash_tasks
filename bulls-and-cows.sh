#!/bin/bash


trap 'printf "\nЧтобы завершить игру, введите q или Q\n"; continue' SIGINT

generate_secret() {
    local digits=(0 1 2 3 4 5 6 7 8 9)
    local secret=""

    while [[ ${#secret} -lt 4 ]]; do
        local idx=$((RANDOM % ${#digits[@]}))
        secret+="${digits[$idx]}"

        digits=("${digits[@]:0:$idx}" "${digits[@]:$((idx+1))}")
    done

    echo "$secret"
}

is_valid_input() {
    local input="$1"
    [[ "$input" =~ ^[0-9]{4}$ ]] || return 1
    [[ "$(echo "$input" | grep -o . | sort | uniq | wc -l)" -eq 4 ]] || return 1
    return 0
}

count_bulls_cows() {
    local secret="$1"
    local guess="$2"
    local bulls=0
    local cows=0

    for ((i=0; i<4; i++)); do
        if [[ "${guess:$i:1}" == "${secret:$i:1}" ]]; then
            ((bulls++))
        elif [[ "$secret" == *"${guess:$i:1}"* ]]; then
            ((cows++))
        fi
    done

    echo "$cows $bulls"
}

cat <<'EOF'
********************************************************************************
* Я загадал 4-значное число с неповторяющимися цифрами. На каждом ходу делайте *
* попытку отгадать загаданное число. Попытка - это 4-значное число с           *
* неповторяющимися цифрами.                                                    *
********************************************************************************
EOF

secret=$(generate_secret)
echo "DEBUG: $secret"

declare -i attempt=0
declare -a history

while :
do
    ((attempt++))
    read -p "Попытка ${attempt}: " guess

    case "$guess" in
        q|Q)
            echo "Вы завершили игру. До встречи!"
            exit 1
        ;;
    esac

    if ! is_valid_input "$guess"; then
        echo "Ошибка: нужно ввести 4-значное число с неповторяющимися цифрами!"
        ((attempt--))
        continue
    fi

    read cows bulls <<< "$(count_bulls_cows "$secret" "$guess")"
    echo "Коров - $cows, Быков - $bulls"
    echo

    history+=("${attempt}. ${guess} (Коров - ${cows} Быков - ${bulls})")

    echo "История ходов:"
    for entry in "${history[@]}"; do
        echo "$entry"
    done
    echo

    if ((bulls == 4)); then
        echo "🎉 Поздравляю! Вы угадали число ${secret}!"
        exit 0
    fi
done
