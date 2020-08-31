#!/bin/bash

# <bitbar.title>Automatic DNS over HTTPS</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Michael Roach</bitbar.author>
# <bitbar.author.github>mroach</bitbar.author.github>
# <bitbar.desc>Automatically sets DNS to a DNS over HTTPS server.</bitbar.desc>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>bash</bitbar.dependencies>
# <bitbar.abouturl></bitbar.abouturl>

# Pre-requisites
# --------------
#
# macOS can't use DNS over HTTPS natively, so a proxy is required.
# Cloudflare provides one and it's easy to setup:
#
#     brew cask install cloudflare/cloudflare/cloudflared
#     sudo cloudflared service install
#
# You should now have a DNS server listening locally. Check it with:
#
#     dig cloudflare.com @127.0.0.1
#
# One this is running, you're ready to start using this script.
#
# Features
# --------
# * If an `openvpn` process is running, don't modify DNS
# * If current Wi-Fi network is using a captive portal, don't modify DNS
#
#
# Current limitations
# -------------------
#
# * Only manages on device/service at a time, and only Wi-Fi
# * Doesn't refresh immediately when changing Wi-Fi networks

device=en0
doh_host=127.0.0.1
test_host=cloudflare.com
config_dir=$HOME/.config/auto_doh
trusted_file=$config_dir/trusted.csv
captive_test_url=http://captive.apple.com/hotspot-detect.html

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

maybe_remove_custom_dns() {
  if [ "$(current_dns_servers)" == "$doh_host" ]; then
    networksetup -setdnsservers $service empty
  fi
}

is_any_vpn_active() {
  answer="no"
  pgrep -q openvpn && answer="yes"
  # TODO: Add more VPN checks like native macOS VPN
  echo $answer
}

is_captive_state() {
  answer="no"
  status=$(curl -w '%{http_code}' -o /dev/null -s $captive_test_url)
  case $status in
    3??)
      answer="yes" ;;
    *)
      answer="no" ;;
  esac
  echo $answer
}

service=$(get_device_service "$device")
current_ssid=$(networksetup -getairportnetwork $device | awk -F": " '{print $2}')
is_trusted=false
colour=red
local_dns_alive=false
any_vpn=$(is_any_vpn_active)
captive=$(is_captive_state)

for ssid in "${trusted_networks[@]}"; do
  if [[ "$ssid" == "$current_ssid" ]]; then
    is_trusted=true
    colour=green
    break
  fi
done

echo -n "DoH"

if [ "$any_vpn" == "yes" ]; then
  echo " ⏸ "
else
  [ "$is_trusted" == true ] && echo " ⇢" || echo " ↩︎"
fi

echo "---"
echo "$current_ssid | color=$colour"

# Sub-menu for the current network
if [ "$is_trusted" == true ]; then
  echo "-- Untrust this network | bash='$0' param1=del-trusted param2='$current_ssid' terminal=false refresh=true"
else
  echo "-- Trust this network | bash='$0' param1=add-trusted param2='$current_ssid' terminal=false refresh=true"
fi

if [ "$any_vpn" == "yes" ]; then
  echo "VPN active. Not modifying DNS. | color=red"
  maybe_remove_custom_dns
elif [ "$captive" == "yes" ]; then
  echo "Captive network detected. Not modifying DNS. | color=red"
  maybe_remove_custom_dns
elif [ "$is_trusted" == false ]; then
  dig +short $test_host @$doh_host &>/dev/null
  if [ $? -eq 0 ]; then
    echo ":lock: Using DoH @$doh_host"
    networksetup -setdnsservers $service $doh_host
  else
    echo "DoH @$doh_host is down | color=red"
    echo "Won't use unresponsive $doh_host | color=red"
    maybe_remove_custom_dns
  fi
else
  echo "Using network-provided DNS"
  maybe_remove_custom_dns
fi

echo "DNS Servers"
for addr in $(current_dns_servers); do
  echo "$addr | color=blue"
done
