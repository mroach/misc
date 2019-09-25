#!/bin/bash

# Logs the battery status of the Magic Trackpad to a file.
# Only works with connected via Bluetooth, not via USB
# Notifies via terminal-notifier when the battery is at 20% or less

device="Magic Trackpad 2"
warn_at=20
tmpfile="${TMPDIR}sys_bluetooth_$(date +%s).plist"

/usr/sbin/system_profiler -xml SPBluetoothDataType > "$tmpfile"

batt=`/usr/libexec/PlistBuddy "$tmpfile" -c "Print 0:_items:0:device_title:0:'$device':device_batteryPercent"`
status=$?

rm $tmpfile

if [ $status -ne 0 ]; then
  echo "Could not find battery status for $device. Is it connected?"
  exit 1
fi

batt=$(echo $batt | tr -d '%')
ts=$(date +"%F %T")

echo "$ts,$batt" >> ~/mtp.log

if [ $batt -le $warn_at ]; then
  /usr/local/bin/terminal-notifier \
      -title "${device}" \
      -message "Battery at ${batt}%" \
      -appIcon "/Library/Application Support/Apple/BezelServices/AppleTopCaseHIDEventDriver.plugin/Contents/Resources/MagicTrackpad.icns"
fi
