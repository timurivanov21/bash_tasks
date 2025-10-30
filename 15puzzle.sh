#!/bin/bash

row_of() { echo $(( $1 / 4 )); }
col_of() { echo $(( $1 % 4 )); }

find_empty_idx() {
  for ((i=0;i<16;i++)); do
    [[ ${BOARD[i]} -eq 0 ]] && { echo "$i"; return; }
  done
}

possible_moves() {
  local e r c idxs=()
  e=$(find_empty_idx)
  r=$(row_of "$e"); c=$(col_of "$e")

  if (( r > 0 )); then idxs+=($(( e-4 ))); fi
  if (( r < 3 )); then idxs+=($(( e+4 ))); fi
  if (( c > 0 )); then idxs+=($(( e-1 ))); fi
  if (( c < 3 )); then idxs+=($(( e+1 ))); fi

  local out=()
  for id in "${idxs[@]}"; do
    out+=("${BOARD[id]}")
  done
  echo "${out[*]}"
}

print_board() {
  printf "\n+-------------------+\n"
  for ((i=0;i<16;i++)); do
    if (( i % 4 == 0 )); then
      printf "| "
    fi
    if [[ ${BOARD[i]} -eq 0 ]]; then
      printf "   | "
    else
      printf "%2d | " "${BOARD[i]}"
    fi
    if (( i % 4 == 3 )); then
      printf "\n|-------------------|\n"
    fi
  done
  printf "\r+-------------------+\n\n"
}

is_solved() {
  for ((i=0;i<15;i++)); do
    [[ ${BOARD[i]} -ne $((i+1)) ]] && return 1
  done
  [[ ${BOARD[15]} -eq 0 ]] || return 1
  return 0
}

count_inversions() {
  local inv=0
  for ((i=0;i<16;i++)); do
    (( BOARD[i] == 0 )) && continue
    for ((j=i+1;j<16;j++)); do
      (( BOARD[j] == 0 )) && continue
      (( BOARD[i] > BOARD[j] )) && ((inv++))
    done
  done
  echo "$inv"
}

blank_row_from_bottom() {
  local e=$(find_empty_idx)
  local rowTop=$(row_of "$e")
  echo $(( 4 - rowTop ))
}

is_solvable() {
  local inv=$(count_inversions)
  local rowB=$(blank_row_from_bottom)
  (( (inv + rowB) % 2 == 0 ))
}

shuffle_solvable_board() {
  local -a arr=()
  for ((i=1; i<=15; i++)); do arr+=("$i"); done
  arr+=(0)

  while :; do
    BOARD=("${arr[@]}")
    for ((i=15; i>0; i--)); do
      j=$((RANDOM % (i+1)))
      tmp=${BOARD[i]}
      BOARD[i]=${BOARD[j]}
      BOARD[j]=$tmp
    done
    is_solvable && return
  done
}

apply_move() {
  local tile="$1"
  local tile_idx empty tmp
  for ((i=0;i<16;i++)); do
    [[ ${BOARD[i]} -eq $tile ]] && tile_idx=$i
  done
  empty=$(find_empty_idx)
  tmp=${BOARD[tile_idx]}
  BOARD[tile_idx]=0
  BOARD[empty]=$tmp
}

is_legal_tile() {
  local tile="$1"
  local moves; moves="$(possible_moves)"
  for m in $moves; do
    [[ "$m" == "$tile" ]] && return 0
  done
  return 1
}

trap 'printf "\nЧтобы выйти, введите q\n";' SIGINT

shuffle_solvable_board

moves=0
while :; do
  printf "Ход № %d\n" "$((moves+1))"
  print_board

  read -p "Ваш ход (q - выход): " input

  case "$input" in
    q)
      echo "Вы вышли из игры."
      exit 1
    ;;
  esac

  if ! [[ "$input" =~ ^[0-9]{1,2}$ ]] || (( input < 1 || input > 15 )); then
    echo
    echo "Неверный ход!"
    echo "Нужно ввести число фишки (1..15), соприкасающейся с пустой."
    echo -n "Можно выбрать: "
    echo "$(possible_moves)" | sed 's/ /, /g'
    echo
    continue
  fi

  if ! is_legal_tile "$input"; then
    echo
    echo "Неверный ход!"
    echo "Невозможно костяшку $input передвинуть на пустую ячейку."
    echo -n "Можно выбрать: "
    echo "$(possible_moves)" | sed 's/ /, /g'
    echo
    continue
  fi

  apply_move "$input"
  ((moves++))

  if is_solved; then
    echo "Вы собрали головоломку за $moves ходов."
    print_board
    exit 0
  fi
done
