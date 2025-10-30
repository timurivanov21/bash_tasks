#!/usr/bin/env bash


A=(8 7 6 5 4 3 2 1)
B=()
C=()
move_count=1

trap 'echo -e "\nЧтобы завершить игру, введите q или Q"' SIGINT

print_stacks() {
  echo
  local max_height=8
  for ((i=max_height-1; i>=0; i--)); do
    local a=${A[i]:- }
    local b=${B[i]:- }
    local c=${C[i]:- }
    printf "|%s|  |%s|  |%s|\n" "$a" "$b" "$c"
  done
  echo "+-+  +-+  +-+"
  echo " A    B    C"
}

check_victory() {
  local goal=(8 7 6 5 4 3 2 1)
  [[ ${B[*]} == "${goal[*]}" || ${C[*]} == "${goal[*]}" ]]
}

move_disk() {
  local from=$1
  local to=$2

  from=${from^^}
  to=${to^^}

  declare -n src=$from
  declare -n dst=$to

  if [[ ${#src[@]} -eq 0 ]]; then
    echo "Стек $from пуст!"
    return 1
  fi

  local disk=${src[-1]}
  unset 'src[-1]'

  if [[ ${#dst[@]} -gt 0 && $disk -gt ${dst[-1]} ]]; then
    echo "Такое перемещение запрещено!"
    src+=("$disk")
    return 1
  fi

  dst+=("$disk")
  return 0
}

while true; do
  print_stacks
  echo -n "Ход № $move_count (откуда, куда): "
  read -r input

  case "$input" in
    q|Q)
      echo "Выход из игры."
      exit 1
      ;;
  esac

  input=$(echo "$input" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

  if [[ ! $input =~ ^[abc]{2}$ ]]; then
    echo "Ошибка ввода! Введите, например, 'ab', 'a c' или 'q/Q' для выхода."
    continue
  fi

  from=${input:0:1}
  to=${input:1:1}

  if [[ $from == $to ]]; then
    echo "Нельзя перемещать в тот же стек!"
    continue
  fi

  if move_disk "$from" "$to"; then
    ((move_count++))
  fi

  if check_victory; then
    print_stacks
    echo "Поздравляем! Вы выиграли!"
    exit 0
  fi
done
