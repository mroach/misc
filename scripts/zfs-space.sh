#!/usr/bin/env bash

set -euo pipefail

size_format=iec
bar_width=60
warn_free_pct=20
red="\e[1;31m"
green="\e[1;32m"
dim="\e[2m"
reset="\e[0m"
ds_char="■"
snap_char="◆"
other_char="▦"
free_char="□"

function format_bytes() {
  numfmt --to="${size_format}" --format="%.01f" "$1"
}

function pct() {
  awk -v n="$1" -v d="$2" 'BEGIN{ print int(n*100.0/d) }'
}

function bar() {
  ds_b="$1"
  snap_b="$2"
  other_b="$3"

  ds_width=$(( (ds_b * bar_width) / 100))
  snap_width=$(( (snap_b * bar_width) / 100))
  other_width=$(( (other_b * bar_width) / 100 ))
  rem=$(( bar_width - ds_width - snap_width - other_width ))

  pct_free=$(( 100 - ds_width - snap_width - other_width ))

  echo -ne "${dim}[${reset}"

  if [ "$pct_free" -lt "$warn_free_pct" ]; then
    echo -ne "$red"
  else
    echo -ne "$green"
  fi

  [ $ds_width -gt 0 ] && printf "${ds_char}%.0s" $(seq 1 $ds_width)
  [ $snap_width -gt 0 ] && printf "${snap_char}%.0s" $(seq 1 $snap_width)
  [ $other_width -gt 0 ] && printf "${other_char}%.0s" $(seq 1 $other_width)

  if [ $rem -gt 0 ]; then
    printf "${dim}${free_char}%.0s" $(seq 1 $rem)
    # To pad with spaces, do this instead:
    #printf "${dim}%*s" $rem
  fi

  echo -ne "${reset}${dim}]${reset}"
}

echo

while read -r line; do
  IFS=$'\t' read -r -a props <<< "$line"

  name="${props[0]}"
  avail="${props[1]}"
  used="${props[2]}"
  usedsnap="${props[3]}"
  usedds="${props[4]}"

  used_other=$(( used - usedsnap - usedds ))
  capacity=$(( used + avail ))

  ds_used_pct=$(pct "$usedds" "$capacity")
  snap_used_pct=$(pct "$usedsnap" "$capacity")
  other_used_pct=$(pct "$used_other" "$capacity")
  used_pct=$(pct "$used" "$capacity")

  #echo "$name avail=$avail used=$used usnap=$usedsnap uds=$usedds cap=$capacity dp=$ds_used_pct sp=$snap_used_pct"

  # For datasets, remove the pool name and indent
  local_name="${name#*/}"
  if [ "$local_name" = "$name" ]; then
    printf '%-12s' "$name"
  else
    printf '  %-10s' "$local_name"
    #echo "  $local_name"
  fi

  bar "$ds_used_pct" "$snap_used_pct" "$other_used_pct"

  # Style 1: compact
  printf "%5s%% used  %6s free\n" "$used_pct" "$(format_bytes $avail)"

  # Style 2: expanded
  #echo -n "   "
  #printf "Used %s of %s (%s free)\n\n" "$(format_bytes $used)" "$(format_bytes $capacity)" "$(format_bytes $avail)"
done < <(zfs list -Hp -t filesystem -o space -d1)
