#!/bin/bash


RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'

declare -i step=0
declare -i hit=0
declare -i miss=0

declare -a last_numbers=()

while :
do
    ((step++))

    echo "Step: $step"

    secret=${RANDOM: -1}

    read -p "Please enter number from 0 to 9 (q - quit): " input

    case "$input" in
        q)
            echo "Bye!"
            exit 0
        ;;
    esac

    case "$input" in
        [0-9])
        ;;
        *)
            echo "Not valid input — try again!"
            ((step--))
            continue
        ;;
    esac

    if [[ "$input" == "$secret" ]]; then
        echo "Hit! My number: $secret"
        ((hit++))
        last_numbers+=("${GREEN}${secret}${RESET}")
    else
        echo "Miss! My number: $secret"
        ((miss++))
        last_numbers+=("${RED}${secret}${RESET}")
    fi

    if (( ${#last_numbers[@]} > 10 )); then
        last_numbers=("${last_numbers[@]: -10}")
    fi

    total=$((hit + miss))
    let hit_percent=hit*100/total
    let miss_percent=100-hit_percent

    echo "Hit: ${hit_percent}%  Miss: ${miss_percent}%"
    # shellcheck disable=SC2145
    echo -e "Numbers: ${last_numbers[@]}"
    echo
done
