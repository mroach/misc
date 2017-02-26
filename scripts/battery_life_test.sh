#!/bin/zsh

# this is a macOS-only script because it uses:
# pmset: for reading battery level
# system_profiler: reading battery load
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
EVENT_THRESHOLD=20

# valid options are: sleep, shut down, restart
EVENT_NAME="sleep"

echo "📟  Starting battery life test at $(date)"
echo -e "⚙️  System will \e[4m${EVENT_NAME}\e[0m at \e[4m${EVENT_THRESHOLD}%\e[0m remaining"
echo

while true; do
  BATTLEVEL=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)

  # Get current amperage.
  # Positive value indicates charging, negative indicates discharging
  # The larger the negative rate, the more load that's on the battery
  AMPERAGE=$(system_profiler SPPowerDataType | grep Amperage | awk '{print $3}')
  VOLTAGE=$(system_profiler SPPowerDataType | grep Voltage | awk '{print $3}')

  echo "🔋  $(date): Battery at ${BATTLEVEL}%, load at ${AMPERAGE} mA, ${VOLTAGE} mV"

  # If the current battery level is at or below the threshold, run the event
  if [ $BATTLEVEL -le $EVENT_THRESHOLD ]; then
    echo "🏁  Battery is at ${BATTLEVEL}%. Issuing ${EVENT_NAME} command."
    osascript -e "tell app \"System Events\" to ${EVENT_NAME}"
    exit 0
  fi

  sleep 60
done
