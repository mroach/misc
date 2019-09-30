#!/bin/bash

# <bitbar.title>Automatic DNS over HTTPS</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Michael Roach</bitbar.author>
# <bitbar.author.github>mroach</bitbar.author.github>
# <bitbar.desc>Automatically sets DNS to a DNS over HTTPS server.</bitbar.desc>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>bash</bitbar.dependencies>
# <bitbar.abouturl></bitbar.abouturl>

device=en0
doh_host=127.0.0.1
test_host=cloudflare.com
config_dir=$HOME/.config/auto_doh
trusted_file=$config_dir/trusted.csv

test -d $config_dir || mkdir -p $config_dir
test -f $trusted_file || touch $trusted_file

case "$1" in
  add-trusted)
    echo "$2" >> $trusted_file
    exit 0 ;;
  del-trusted)
    sed -i '' "/^$2\$/d" $trusted_file
    exit 0 ;;
  *)
    ;;
esac

IFS=$'\n' read -d '' -r -a trusted_networks < $trusted_file

# get the service name associated with the device. e.g. "Wi-Fi" for en0
get_device_service() {
   networksetup -listallhardwareports \
   | grep -B1 "Device: $1" | head -n1 | awk -F": " '{print $2}'
}

current_dns_servers() {
  scutil --dns | grep nameserver | awk -F" : " '{print $2}' | sort | uniq
}

reset_dns() {
  networksetup -setdnsservers $service empty
}

service=$(get_device_service "$device")
current_ssid=$(networksetup -getairportnetwork $device | awk -F": " '{print $2}')
is_trusted=false
colour=red
local_dns_alive=false

for ssid in "${trusted_networks[@]}"; do
  if [[ "$ssid" == "$current_ssid" ]]; then
    is_trusted=true
    colour=green
    break
  fi
done

echo -n "DoH "
[ "$is_trusted" == true ] && echo " ⇢" || echo " ↩︎"

echo "---"
echo "$current_ssid | color=$colour"

if [ "$is_trusted" == true ]; then
  echo "-- Untrust this network | bash='$0' param1=del-trusted param2='$current_ssid' terminal=false refresh=true"
else
  echo "-- Trust this network | bash='$0' param1=add-trusted param2='$current_ssid' terminal=false refresh=true"
fi

dig +short $test_host @$doh_host &>/dev/null
if [ $? -eq 0 ]; then
  local_dns_alive=true
else
  echo "DoH @$doh_host is DOWN | color=red"
  reset_dns
fi

if [ "$is_trusted" == false ]; then
  if [ "$local_dns_alive" == true ]; then
    echo ":lock: Using DoH @$doh_host"
    networksetup -setdnsservers $service $doh_host
  else
    echo "Won't use unresponsive $doh_host | color=red"
  fi
else
  echo "Using network-provided DNS"
  reset_dns
fi

echo
echo "DNS Servers"
for addr in $(current_dns_servers); do
  echo "$addr | color=blue"
done
