#!/bin/bash
function menu-select {
  # Initial Setup
  local downkey=$'\x1b[B'
  local upkey=$'\x1b[A'
  local enter=""
  n=$[$#-1]
  idx=0
 
  # Helper Functions
  cursor_blink_on()  { printf "\033[?25h"; }
  cursor_blink_off() { printf "\033[?25l"; }
  cursor_down() { if [ $1 -gt 0 ]; then echo -en "\033[$1B"; fi }
  cursor_up()   { if [ $1 -gt 0 ]; then echo -en "\033[$1A"; fi }
  cleanup() { cursor_down $[$n-$idx]; cursor_blink_on; stty echo; printf '\n'; }

  trap "cleanup;" EXIT
  cursor_blink_off

  # Main Loop
  while true; do
    
    # Draw Opts
    cursor_up $idx
    i=0
    for opt in $@; do
      if [[ "${options[$idx]}" = $opt ]]; then
        echo -e "  \033[7m $opt \033[27m"; 
      else
        echo -e "   $opt "
      fi
      ((i++))
    done

    # Reset Cursor
    cursor_up $[$#-$idx]
 
    # Read User Input
    read -sn3 input_key
    case $input_key in
      $downkey)
        if [ $idx -lt $n ]; then
          ((idx++)); cursor_down 1
        else
          idx=0; cursor_up $n
        fi ;;
      $upkey)
        if [ $idx -gt 0 ]; then
          ((idx--)); cursor_up 1;
        else 
          idx=$n; cursor_down $n
        fi ;;
      $enter)
        break ;;
    esac
  done

  cleanup
  return $idx
}


function git-branch-select {
  options=( $(git for-each-ref refs/heads/ --format='%(refname:short)' --sort=-committerdate | head -10) )

  menu-select "${options[@]}"
  choice=$?
  echo "${options[$choice]}"
}

