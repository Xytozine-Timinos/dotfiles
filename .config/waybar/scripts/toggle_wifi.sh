#!/bin/bash

CURRENT_INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
INTERFACE_TYPE=$(nmcli device show "$CURRENT_INTERFACE" 2>/dev/null | sed -n 's/GENERAL.TYPE:*//p' | sed 's/[[:space:]]//g')

# Check if Wi-Fi radio is enabled and if Ethernet is connected
WIFI_ENABLED=$(nmcli radio wifi 2>/dev/null)
ETH_CONNECTED=$(nmcli -t -f TYPE,STATE device 2>/dev/null | grep -q '^ethernet:connected' && echo "true" || echo "false")

if [[ $INTERFACE_TYPE == "wifi" && $WIFI_ENABLED == "enabled" ]]; then
	nmcli radio all off
	notify-send "Wifi Disabled 󱛅 " -t 850
elif [[ $INTERFACE_TYPE == "ethernet" && $ETH_CONNECTED == "true" ]]; then
	# Detect active or available Ethernet interface name (e.g., eth0, enp3s0)
	eth_dev=$(nmcli -t -f DEVICE,TYPE device | grep ':ethernet' | cut -d: -f1 | head -n1)

	# Fallback in case no specific ethernet device is returned
	if [[ -z "$eth_dev" ]]; then
		eth_dev="eth0"
	fi
	nmcli device disconnect "$eth_dev"
	notify-send "Ethernet Disconnected 󰈂 " -t 850
else
	~/.config/rofi/modules/rofi-wifi-menu
fi
