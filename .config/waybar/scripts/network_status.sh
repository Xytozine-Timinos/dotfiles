#!/usr/bin/env bash

# Wi-Fi signal icons
icons=("󰤯 " "󰤯 " "󰤟 " "󰤟 " "󰤢 " "󰤢 " "󰤢 " "󰤨 " "󰤨 " "󰤨 ")
classes=("strength-0" "strength-1" "strength-2" "strength-3" "strength-4" "strength-5" "strength-6" "strength-7" "strength-8" "strength-9")

prev_rx=0
prev_tx=0
prev_time=0

# Helper to convert speed to human readable format
hr_speed() {
	if (($1 > 1048576)); then
		printf "%.1f MB/s" "$(echo "$1/1048576" | bc -l)"
	elif (($1 > 1024)); then
		printf "%.0f KB/s" "$(echo "$1/1024" | bc -l)"
	else
		printf "%d B/s" "$1"
	fi
}

# Accurate DNS detection function (handles VPNs & resolvectl)
get_dns() {
	local dev="$1"
	local dns=""

	if command -v resolvectl &>/dev/null; then
		dns=$(resolvectl status 2>/dev/null | awk '/Current DNS Server:/ {print $4; exit}')
		if [[ -z "$dns" ]]; then
			dns=$(resolvectl status "$dev" 2>/dev/null | awk '/DNS Servers:/ {print $3; exit}')
		fi
	fi

	if [[ -z "$dns" ]] && command -v nmcli &>/dev/null; then
		dns=$(nmcli -g IP4.DNS device show "$dev" 2>/dev/null | awk '{print $1}')
	fi

	if [[ -z "$dns" ]]; then
		dns=$(awk '/^nameserver/ && $2 !~ /^127\./ {print $2; exit}' /etc/resolv.conf)
	fi

	echo "${dns:-N/A}"
}

while sleep 3; do
	# Detect Ethernet interface and check if it actually has an active IPv4 address
	eth_iface=$(ip -o link show | awk -F': ' '/^[0-9]+: (en|eth)/ {print $2; exit}')
	eth_up=$(ip link show "$eth_iface" 2>/dev/null | awk '/state/ {print $9}')
	eth_ip=""

	if [[ -n "$eth_iface" ]]; then
		eth_ip=$(ip addr show dev "$eth_iface" 2>/dev/null | awk '/inet / {print $2; exit}' | cut -d'/' -f1)
	fi

	# --- ETHERNET BLOCK (Only active if interface is UP AND has an assigned IP address) ---
	if [[ -n "$eth_iface" && "$eth_up" == "UP" && -n "$eth_ip" ]]; then
		ipaddr="$eth_ip"
		gateway_address=$(ip route show default dev "$eth_iface" 2>/dev/null | awk '{print $3}')
		gateway_address=${gateway_address:-"N/A"}
		dns_address=$(get_dns "$eth_iface")

		# Fast 3-packet probe for loss
		target_host="${gateway_address}"
		[[ "$target_host" == "N/A" || -z "$target_host" ]] && target_host="1.1.1.1"
		pkt_loss=$(ping -c 3 -i 0.2 -W 1 "$target_host" 2>/dev/null | grep -oP '\d+(?=% packet loss)')
		pkt_loss="${pkt_loss:-100}%"

		rx_bytes=$(</sys/class/net/$eth_iface/statistics/rx_bytes)
		tx_bytes=$(</sys/class/net/$eth_iface/statistics/tx_bytes)
		cur_time=$(date +%s)

		if ((prev_time > 0)); then
			interval=$((cur_time - prev_time))
			if ((interval > 0)); then
				dl_speed=$(hr_speed $(((rx_bytes - prev_rx) / interval)))
				ul_speed=$(hr_speed $(((tx_bytes - prev_tx) / interval)))
				net_speed=$(hr_speed $(((rx_bytes - prev_rx + tx_bytes - prev_tx) / interval)))

				# Exact line length calculations for Ethernet
				wc_eth=10                           # "󰈀  Ethernet"
				wc_ip=$((${#ipaddr} + 7))           # "  IP: "
				wc_dns=$((${#dns_address} + 8))     # "󰒍  DNS: "
				wc_gw=$((${#gateway_address} + 12)) # "󰩩  Gateway: "
				wc_loss=$((${#pkt_loss} + 10))      # "󰤢  Loss: "

				max_len=$wc_eth
				for val in $wc_ip $wc_dns $wc_gw $wc_loss; do
					if ((val > max_len)); then
						max_len=$val
					fi
				done

				printf -v dynamic_sep_line '%.0s─' $(seq 1 $max_len)

				tooltip="󰈀  Ethernet\n  IP: $ipaddr\n󰒍  DNS: $dns_address\n󰩩  Gateway: $gateway_address\n󰤢  Loss: $pkt_loss\n$dynamic_sep_line\n  Network stats\n├ ↓ Download: $dl_speed\n├ ↑ Upload:   $ul_speed\n└ 󰹹 Netspeed: $net_speed"
			fi
		fi

		prev_rx=$rx_bytes
		prev_tx=$tx_bytes
		prev_time=$cur_time
		echo "{\"text\":\"󰈀 \",\"class\":\"ethernet\",\"tooltip\":\"${tooltip}\"}"
		continue
	fi

	# --- WI-FI FALLBACK BLOCK ---
	iface=$(iw dev | awk '$1=="Interface"{print $2; exit}')

	if [[ -n "$iface" && -d "/sys/class/net/$iface" ]]; then
		gateway_address=$(ip route show default dev "$iface" 2>/dev/null | awk '{print $3}')
		gateway_address=${gateway_address:-"N/A"}

		strength=$(awk -v iface="$iface" '$1==iface ":" {print int($3*100/70)}' /proc/net/wireless)
		strength=${strength:-0}
		[[ $strength -gt 100 ]] && strength=100

		ssid=$(iw dev "$iface" link | grep 'SSID' | awk -F': ' '{print $2}')
		ssid=${ssid:-"Unknown"}

		ipaddr=$(ip addr show dev "$iface" | awk '/inet / {print $2; exit}' | cut -d'/' -f1)
		ipaddr=${ipaddr:-"N/A"}
		dns_address=$(get_dns "$iface")

		case $strength in
		100 | 9[0-9]) strength_stat="Excellent" ;;
		[7-8][0-9]) strength_stat="Good" ;;
		[5-6][0-9]) strength_stat="Medium" ;;
		[3-4][0-9] | 2[6-9]) strength_stat="Low" ;;
		[0-1][0-9] | 2[0-5]) strength_stat="Very Bad" ;;
		*) strength_stat="Offline" ;;
		esac

		# Fast 3-packet probe for loss
		target_host="${gateway_address}"
		[[ "$target_host" == "N/A" || -z "$target_host" ]] && target_host="1.1.1.1"
		pkt_loss=$(ping -c 3 -i 0.2 -W 1 "$target_host" 2>/dev/null | grep -oP '\d+(?=% packet loss)')
		pkt_loss="${pkt_loss:-100}%"

		tooltip="󱈤  SSID: $ssid\n  IP: $ipaddr\n󰒍  DNS: $dns_address\n󰩩  Gateway: $gateway_address\n󰓅  Network Strength: $strength_stat\n󰤢  Loss: $pkt_loss"

		# Exact line length calculations for Wi-Fi
		wc_ssid=$((${#ssid} + 9))
		wc_ipaddr=$((${#ipaddr} + 7))
		wc_dns=$((${#dns_address} + 8))
		wc_gateway=$((${#gateway_address} + 12))
		wc_strength_stat=$((${#strength_stat} + 21))
		wc_loss=$((${#pkt_loss} + 10))

		max_len=$wc_ssid
		for val in $wc_ipaddr $wc_dns $wc_gateway $wc_strength_stat $wc_loss; do
			if ((val > max_len)); then
				max_len=$val
			fi
		done

		printf -v dynamic_sep_line '%.0s─' $(seq 1 $max_len)

		rx_bytes=$(</sys/class/net/$iface/statistics/rx_bytes)
		tx_bytes=$(</sys/class/net/$iface/statistics/tx_bytes)
		cur_time=$(date +%s)

		if ((prev_time > 0)); then
			interval=$((cur_time - prev_time))
			if ((interval > 0)); then
				dl_speed=$(hr_speed $(((rx_bytes - prev_rx) / interval)))
				ul_speed=$(hr_speed $(((tx_bytes - prev_tx) / interval)))
				net_speed=$(hr_speed $(((rx_bytes - prev_rx + tx_bytes - prev_tx) / interval)))
				tooltip="$tooltip\n$dynamic_sep_line\n  Network stats\n├ ↓ Download: $dl_speed\n├ ↑ Upload:   $ul_speed\n└ 󰹹 Netspeed: $net_speed"
			fi
		fi

		prev_rx=$rx_bytes
		prev_tx=$tx_bytes
		prev_time=$cur_time

		if ((strength == 0)); then
			icon=" "
			class="disconnected"
		else
			index=$((strength * 9 / 100))
			icon="${icons[index]}"
			class="${classes[index]}"
		fi

		echo "{\"text\":\"$icon\",\"tooltip\":\"$tooltip\",\"class\":\"$class\"}"
	else
		echo '{"text":"󰤭 ","class":"disconnected","tooltip":"No interface"}'
	fi
done
