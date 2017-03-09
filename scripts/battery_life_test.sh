#!/bin/bash

# this is a macOS-only script because it uses:
# pmset: for reading battery level
# ioreg: reading other power data
# system_profiler: amperage (ioreg value is wrong)
# osascript: running the power control event without requiring sudo for 'shutdown'

# example usage
# ./battery_life_test.sh | tee "battery-test-$(date +%Y%m%d%H%M).log"

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
# If the computer is plugged in and the battery is below this level, the event
# will NOT be executed.
# E.g. Battery is at 5% but laptop is plugged in, no event fired
EVENT_THRESHOLD=${THRESHOLD-20}

# valid options are: sleep, shut down, restart
EVENT_NAME="sleep"

# How long to wait between battery checks, in seconds
INTERVAL=60

# Default: 2017-02-24 14:32:01
DATE_FORMAT="%Y-%m-%d %H:%M:%S"

echo "📟  Starting battery life test at $(date)"
echo "⚙️  System will ${EVENT_NAME} at ${EVENT_THRESHOLD}% remaining"
if [ ! -z "$CSV" ]; then
  echo "✏️  Logging to $CSV"
fi
echo

LAST_MVOLTS=""
LAST_CHARGE=""

function _strip() {
  cat - | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+$//'
}

function _ioreg_batt_val() {
  echo $(ioreg -rn AppleSmartBattery | grep -E "^\s+\"$1\"" | cut -d= -f2 | _strip)
}

function _profiler_batt_val() {
  echo $(system_profiler SPPowerDataType | grep "$1:" | cut -d: -f2 | _strip)
}

function _colourise_change() {
  local var_name=$1
  eval "last_val=\$LAST_${var_name}"
  eval "curr_val=\$${var_name}"
  NOSTYLE="${NOSTYLE:=\e[39m}"
  UPSTYLE="${UPSTYLE:=\e[92m}"
  DOWNSTYLE="${DOWNSTYLE:=\e[91m}"
  if   [ -z $last_val ]; then echo $NOSTYLE
  elif [ $curr_val -gt $last_val ]; then echo $UPSTYLE
  elif [ $curr_val -lt $last_val ]; then echo $DOWNSTYLE
  else echo "\e[39m"; fi
}

while true; do
  BATTLEVEL=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)

  # Determine if the charger is connected.
  CHARGER_ID=$(pmset -g adapter | grep AdapterID | cut -d= -f2 | sed -E 's/ //')
  if [ -z "$CHARGER_ID" ]; then
    CHARGER_CONNECTED=0;
    POWER_ICON="🔋"
  else
    CHARGER_CONNECTED=1;
    POWER_ICON="🔌"
  fi

  # Get current amperage.
  # Positive value indicates charging, negative indicates discharging
  # The larger the negative rate, the more load that's on the battery
  CHARGE=$(_ioreg_batt_val CurrentCapacity)

  # Get battery capacity in mAh. This number varies based on the last charge
  MAX_CHARGE=$(_ioreg_batt_val MaxCapacity)

  # Get the design capacity for the battery. This should never change, but
  # given the oddities witnessed with batteries, best to check on every iteration
  DESIGN_CAPACITY=$(_ioreg_batt_val DesignCapacity)

  # The amperage is a negative number when running on battery and indicates the
  # load/draw. It's positive when charging and indicates charge rate. The number
  # gets smaller as the battery gets closer to being full. It does go negative
  # around 100% to prevent overcharging
  AMPERAGE_RATE=$(_profiler_batt_val 'Amperage (mA)')

  # Voltage, in mV. The lower the battery level gets, the lower this tends to get
  # A full battery delivers about 12.5 V and the system shuts itself off around 9.5 V
  MVOLTS=$(_ioreg_batt_val Voltage)

  # Converted to Volts as a decimal with a scale of 3. e.g.  12451 => 12.451
  VOLTS=$(echo "scale=3; $MVOLTS / 1000" | bc)

  # Time remaining. Either battery run time or time until fully charged
  REMAINING=$(pmset -g batt | egrep -o '\d+:\d+ remaining' | awk '{print $1}')

  # Calculate health as a whole-number percentage
  # This is what the system perceives as the maximum charge capacity of the battery
  # divided by the design capacity advertised by the battery.
  # On older systems and batteries, the max charge can jump around even during
  # the same charge or discharge cycle.
  HEALTH=$(echo "$MAX_CHARGE * 100 / $DESIGN_CAPACITY" | bc)

  # Colourise voltage and charge percentage.
  # If it went up: green, down: red, stayed same: no colour
  VOLTAGE_COLOR=$(_colourise_change MVOLTS)
  CHARGE_COLOR=$(_colourise_change CHARGE)
  MAX_CHARGE_COLOR=$(DOWNSTYLE="\e[101m" UPSTYLE="\e[42m" _colourise_change MAX_CHARGE)
  HEALTH_COLOR=$(DOWNSTYLE="\e[101m" UPSTYLE="\e[42m" _colourise_change HEALTH)
  TIMESTAMP=$(date +"$DATE_FORMAT")

  printf "[%s] %s%5s%% (${CHARGE_COLOR}%4s\e[0m/${MAX_CHARGE_COLOR}%4s\e[0m mAh 🏥 ${HEALTH_COLOR}%3s%%\e[0m) ⏳ %5s ⚡️  %5s mA ${VOLTAGE_COLOR}%6sV\e[0m\n" \
    "$TIMESTAMP" "$POWER_ICON" "$BATTLEVEL" "$CHARGE" "$MAX_CHARGE" "$HEALTH" "$REMAINING" "$AMPERAGE_RATE" "$VOLTS"

  if [ ! -z "$CSV" ]; then
    if [ $CHARGER_CONNECTED -eq 1 ]; then
      POWER_SOURCE="AC";
    else
      POWER_SOURCE="BATT";
    fi

    # Create CSV header if this is a new log file
    if [ ! -f "$CSV" ]; then
      echo "Timestamp,PowerSource,BatteryLevel,CurrentCharge,MaxCapacity,Health,TimeRemaining,Current,Volts" >> "$CSV"
    fi

    echo "$TIMESTAMP,$POWER_SOURCE,$BATTLEVEL,$CHARGE,$MAX_CHARGE,$HEALTH,$REMAINING,$AMPERAGE_RATE,$VOLTS" >> "$CSV"
  fi

  # If unplugged and current battery level is at or below the threshold, run the event
  if [ $CHARGER_CONNECTED -eq 0 ] && [ $BATTLEVEL -le $EVENT_THRESHOLD ]; then
    echo
    echo "🏁  Battery is at ${BATTLEVEL}%. Issuing ${EVENT_NAME} command."
    osascript -e "tell app \"System Events\" to ${EVENT_NAME}"
    exit 0
  fi

  if [ $MVOLTS -lt 10000 ]; then
    terminal-notifier -title "⚠️ Battery at $VOLTS volts" -message "Hard shutdown imminent!"
  fi

  LAST_CHARGE=$CHARGE
  LAST_MVOLTS=$MVOLTS
  LAST_MAX_CHARGE=$MAX_CHARGE
  LAST_HEALTH=$HEALTH

  sleep $INTERVAL
done
