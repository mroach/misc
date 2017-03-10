#!/bin/bash

# Example usages

## Test battery life down to 20%, prevent idle sleep
# THRESHOLD=20 CAFFEINATE=1 CSV=battlog.csv ./battery_life_test.sh
#
## Prevent idle sleep, run down to 20%, then shutdown
# THRESHOLD=20 CAFFEINATE=1 CMD="shut down" CSV=battlog.csv ./battery_life_test.sh
#
## Run batteryt o death, prevent idle sleep along the way
# CMD=nothing CAFFEINATE=1 CSV=battlog.csv ./battery_life_test.sh
#
## Just log battery life, don't do anything
# CMD=nothing CSV=battlog.csv ./battery_life_test.sh

# Currently a macOS-only script due to dependencies on:
# pmset: for reading most power information
# ioreg: reading voltage
# osascript: running the power control event without requiring sudo for 'shutdown'

# Run this script to automatically sleep or shutdown your system at a defined battery level
# For example if you want to see how long your system lasts playing a video
# on repeat with the screen on, run this, go to bed, wake up and your computer
# will have put itself to sleep and you'll have a log of when that happened!
# This is much better than running the computer until it's dead as that's not
# good for the life of lithium-ion batteries

# At what battery percentage level to trigger an event
# It's advised not to use a value lower than 20 as this stresses lithium-ion
# batteries. Repeatedly running li-ion battery below 20% charge will permanently
# affect their charge capacity
#
# If the computer is plugged in and the battery is below this level, the event
# will NOT be executed.
# E.g. Battery is at 5% but laptop is plugged in, no event fired
#
# Set to -1 to let the system run itself to death. 0 won't necessarily work
# since on old batteries and fouled-up systems, the system can read 0 then jump
# back up
EVENT_THRESHOLD=${THRESHOLD:-20}

# valid options are: sleep, shut down, restart, and nothing
CMD=${CMD:-sleep}

# How long to wait between battery checks, in seconds
INTERVAL=60

# Default: 2017-02-24 14:32:01
DATE_FORMAT="%Y-%m-%d %H:%M:%S"

# When set to 1, this script will use caffeinate to prevent the system from
# going to sleep. This is a good alternative to playing a video on a loop
CAFFEINATE=${CAFFEINATE-0}

function _strip() {
  cat - | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+$//'
}

function _ioreg_batt_val() {
  echo $(ioreg -rn AppleSmartBattery | grep -E "^\s+\"$1\"" | cut -d= -f2 | _strip)
}

function _colourise_change() {
  local var_name=$1
  eval "last_val=\$last_${var_name}"
  eval "curr_val=\$${var_name}"
  nostyle="${NOSTYLE:=\e[39m}"
  upstyle="${UPSTYLE:=\e[92m}"
  downstyle="${DOWNSTYLE:=\e[91m}"
  if   [ -z $last_val ]; then echo $nostyle
  elif [ $curr_val -gt $last_val ]; then echo $upstyle
  elif [ $curr_val -lt $last_val ]; then echo $downstyle
  else echo "\e[39m"; fi
}

echo "📟  Starting battery life test at $(date)"

if [ "$CMD" == "nothing" ]; then
  echo "⚙️  No action will be taken by this script at any charge level"
else
  echo "⚙️  System will ${CMD} at ${EVENT_THRESHOLD}% remaining"
fi

if [ $CAFFEINATE -eq 1 ]; then
  echo "☕️  Caffeinating to prevent system sleep due to idle"
  # -d  Prevent display from sleeping
  # -i  Prevent system from idle sleeping (default anyway)
  caffeinate -di -w $$ &
fi

if [ ! -z "$CSV" ]; then
  echo "✏️  Logging to $CSV"
fi

echo

while true; do
  # reads in a line of data looking like:
  # AC; Charging; 98%; Cap=5596: FCC=5689; Design=6900; Time=0:16; 433mA; Cycles=6/1000; Location=0;
  i=0
  while read -r line; do
    val=$(echo "$line" | _strip)
    case "$i" in
      "0")
        # Either AC or No AC
        power_source=$val;;
      "2")
        battlevel=$(echo $val | sed 's/%//');;
      "3")
        # Get current amperage.
        # Positive value indicates charging, negative indicates discharging
        # The larger the negative rate, the more load that's on the battery
        charge=$(echo $val | cut -d= -f2);;
      "4")
        # Battery capacity in mAh. This number varies based on the last charge
        max_charge=$(echo $val | cut -d= -f2);;
      "5")
        # Get the design capacity for the battery. This should never change, but
        # given the oddities witnessed with batteries, best to check on every iteration
        design_capacity=$(echo $val | cut -d= -f2);;
      "6")
        # Time remaining. Either battery run time or time until fully charged
        remaining=$(echo $val | cut -d= -f2);;
      "7")
        # The amperage is a negative number when running on battery and indicates the
        # load/draw. It's positive when charging and indicates charge rate. The number
        # gets smaller as the battery gets closer to being full. It does go negative
        # around 100% to prevent overcharging
        amperage_rate=$(echo $val | grep -Eo '^-?\d+')
    esac
    (( i++ ))
  done < <(pmset -g rawbatt | sed -n 2p | sed $'s/[;:] /\\\n/g')

  # Determine if the charger is connected.
  if [ "$power_source" == "AC" ]; then
    charger_connected=1;
    power_icon="🔌"
  else
    charger_connected=0;
    power_icon="🔋"
  fi

  # Voltage, in mV. The lower the battery level gets, the lower this tends to get
  # A full battery delivers about 12.5 V and the system shuts itself off around 9.5 V
  mvolts=$(_ioreg_batt_val Voltage)

  # Converted to Volts as a decimal with a scale of 3. e.g.  12451 => 12.451
  volts=$(echo "scale=3; $mvolts / 1000" | bc)

  # Calculate health as a whole-number percentage
  # This is what the system perceives as the maximum charge capacity of the battery
  # divided by the design capacity advertised by the battery.
  # On older systems and batteries, the max charge can jump around even during
  # the same charge or discharge cycle.
  health=$(echo "$max_charge * 100 / $design_capacity" | bc)

  # Colourise voltage and charge percentage.
  # If it went up: green, down: red, stayed same: no colour
  voltage_color=$(_colourise_change mvolts)
  charge_color=$(_colourise_change charge)
  max_charge_color=$(DOWNSTYLE="\e[101m" UPSTYLE="\e[30;42m" _colourise_change max_charge)
  health_color=$(DOWNSTYLE="\e[101m" UPSTYLE="\e[30;42m" _colourise_change health)
  timestamp=$(date +"$DATE_FORMAT")

  printf "[%s] %s%5s%% (${charge_color}%4s\e[0m/${max_charge_color}%4s\e[0m mAh 🏥  ${health_color}%s%%\e[0m) ⏳ %5s ⚡️  %5s mA ${voltage_color}%6sV\e[0m\n" \
    "$timestamp" "$power_icon" "$battlevel" "$charge" "$max_charge" "$health" "$remaining" "$amperage_rate" "$volts"

  if [ ! -z "$CSV" ]; then
    if [ $charger_connected -eq 1 ]; then
      power_source="AC";
    else
      power_source="BATT";
    fi

    # Create CSV header if this is a new log file
    if [ ! -f "$CSV" ]; then
      echo "Timestamp,PowerSource,BatteryLevel,CurrentCharge,MaxCapacity,Health,TimeRemaining,Current,Volts" >> "$CSV"
    fi

    echo "$timestamp,$power_source,$battlevel,$charge,$max_charge,$health,$remaining,$amperage_rate,$volts" >> "$CSV"
  fi

  # If unplugged and current battery level is at or below the threshold, run the event
  if [ "$CMD" != "nothing" ]  && [ $charger_connected -eq 0 ] && [ $battlevel -le $EVENT_THRESHOLD ]; then
    echo
    echo "🏁  Battery is at ${battlevel}%. Issuing ${CMD} command."
    osascript -e "tell app \"System Events\" to ${CMD}"
    exit 0
  fi

  if [ $mvolts -lt 10000 ]; then
    terminal-notifier -title "⚠️ Battery at $VOLTS volts" -message "Hard shutdown imminent!"
  fi

  last_charge=$charge
  last_mvolts=$mvolts
  last_max_charge=$max_charge
  last_health=$health

  sleep $INTERVAL
done
