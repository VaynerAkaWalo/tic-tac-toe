#!/bin/bash

board=("​" "​" "​" "​" "​" "​" "​" "​" "​")
currentRound=1

function printBoard() {
  echo "|-----------------|"
  printf "|  %-1s  |  %-1s  |  %-1s  |\n" ${board[0]} ${board[1]} ${board[2]}
  echo "|-----------------|"
  printf "|  %-1s  |  %-1s  |  %-1s  |\n" ${board[3]} ${board[4]} ${board[5]}
  echo "|-----------------|"
  printf "|  %-1s  |  %-1s  |  %-1s  |\n" ${board[6]} ${board[7]} ${board[8]}
  echo "|-----------------|"
}

function tryMove() {
  if [[ ${board[$1]} == "​" ]]; then
    if (( currentRound % 2 == 1 )); then
        board[$1]="X"
    else
        board[$1]="O"
    fi
    currentRound=$((currentRound + 1))
  fi
}

function getCurrentPlayer() {
  if (( currentRound % 2 == 1 )); then
    echo "X"
  else
    echo "O"
  fi
}

function printCurrentPlayer() {
  echo "-------------------"
  echo "| Current  Player |"
  printf '|        %s        |\n' `getCurrentPlayer`
  echo "-------------------"
}

function printScreen() {
  printf '\033[1J'
  printCurrentPlayer
  printBoard
}

function checkGameOver() {
    for i in 0 3 6 ; do
      if [[ ${board[$i]} != "​" && ${board[$i]} == ${board[$i+1]} && ${board[$i]} == ${board[$i+2]} ]]; then
        return 0
      fi
    done

    for i in 0 1 2 ; do
      if [[ ${board[$i]} != "​" && ${board[$i]} == ${board[$i+3]} && ${board[$i]} == ${board[$i+6]} ]]; then
        return 0
      fi
    done

    if [[ ${board[0]} != "​" && ${board[0]} == ${board[4]} && ${board[0]} == ${board[8]} ]]; then
      return 0
    fi

    if [[ ${board[2]} != "​" && ${board[2]} == ${board[4]} && ${board[2]} == ${board[6]} ]]; then
      return 0
    fi

    return 1
}

function checkIfDraw() {
  for i in {0..8} ; do
    if [[ ${board[$i]} == "​" ]]; then
      return 1
    fi
  done
  return 0
}

function SaveGame() {
  echo "Enter name for save"
  read file
  mkdir -p "saves"

  echo "$currentRound" > saves/$file
  for element in "${board[@]}"; do
    echo $element >> saves/$file
  done
  echo "Successfully saved $file game"
  exit
}

function LoadGame() {
  echo "Enter name for save you would like to load"
  read file

  local savePath=saves/$file

  if [ -f $savePath ]; then
    echo "Found saved game"
  else
    echo "Failed to found saved game"
    exit
  fi

  read -r currentRound < $savePath
  board=()
  while IFS= read -r line; do
    board+=("$line")
  done < <(tail -n +2 $savePath)
}

while [ true ]; do
  printScreen
  echo "Select your move"
  select selected in TopLeft Top TopRight Left Middle Right DownLeft Down DownRight SaveGame LoadGame Quit; do
    case $selected in
    "TopLeft") tryMove 0 ;;
    "Top") tryMove 1 ;;
    "TopRight") tryMove 2 ;;
    "Left") tryMove 3 ;;
    "Middle") tryMove 4 ;;
    "Right") tryMove 5 ;;
    "DownLeft") tryMove 6 ;;
    "Down") tryMove 7 ;;
    "DownRight") tryMove 8 ;;
    "SaveGame") SaveGame ;;
    "LoadGame") LoadGame ;;
    "Quit") exit ;;
    esac
    break
  done

  if checkGameOver; then
    printScreen
    currentRound=$((currentRound + 1))
    echo "Player `getCurrentPlayer` has won"
    exit
  fi

  if checkIfDraw; then
    printScreen
    echo "It's a draws because the board is full"
    exit
  fi
done
