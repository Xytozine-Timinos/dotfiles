#!/bin/bash

# Define paths
BAT_PATH="/sys/class/power_supply/BAT0"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT1"

# Detect Controller, Mode, and Turbo
TURBO_INFO=""
GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A")

if hash powerprofilesctl 2>/dev/null; then
	CONTROLLER="power-profiles-daemon"
	MODE=$(powerprofilesctl get)
elif hash auto-cpufreq 2>/dev/null; then
	CONTROLLER="auto-cpufreq"
	MODE=$(auto-cpufreq --get-state)
	# Kernel Turbo Check
	if [ -f "/sys/devices/system/cpu/intel_pstate/no_turbo" ]; then
		[[ $(cat /sys/devices/system/cpu/intel_pstate/no_turbo) == "0" ]] && T_STAT="on" || T_STAT="off"
	elif [ -f "/sys/devices/system/cpu/cpufreq/boost" ]; then
		[[ $(cat /sys/devices/system/cpu/cpufreq/boost) == "1" ]] && T_STAT="on" || T_STAT="off"
	else
		T_STAT="N/A"
	fi
	TURBO_INFO="\n󰶼  Turbo: $T_STAT"
else
	CONTROLLER="Kernel ($(uname -r))"
	MODE="$GOVERNOR"
fi

dynamic_sep_line=$(
	for item in $(seq 1 $((${#CONTROLLER} + 15))); do
		echo -n "─"
	done
	echo ""
)

# Desktop Handling
if [ ! -d "$BAT_PATH" ]; then
	TOOLTIP="  Controller: ${CONTROLLER}\n󰓅  Mode: ${MODE}${TURBO_INFO}\n󱐋  Governor: ${GOVERNOR}\n  Status: Plugged In\n  Time left: INF\n$dynamic_sep_line\n󰠠  Electrical\n├─ Wattage: --W\n├─ Voltage: --V\n└─ Amps: --A"
	echo "{\"text\": \"󰚥 AC\", \"percentage\": 100, \"class\": \"desktop-ac\", \"tooltip\": \"$TOOLTIP\"}"
	exit 0
fi

# Read Battery Data
# Read the output lines directly into an array
mapfile -t BAT_DATA < <(cat "$BAT_PATH/capacity" "$BAT_PATH/status" "$BAT_PATH/voltage_now" "$BAT_PATH/power_now" "$BAT_PATH/energy_now" "$BAT_PATH/energy_full" "$BAT_PATH/cycle_count" 2>/dev/null)

# Assign variables from the array indices
CAPACITY="${BAT_DATA[0]}"
STATUS="${BAT_DATA[1]}"
V_RAW="${BAT_DATA[2]}"
P_RAW="${BAT_DATA[3]}"
# If power_now wasn't found, compute it from current_now * voltage_now
if [[ -z "$P_RAW" ]]; then
	I_RAW=$(cat "$BAT_PATH/current_now" 2>/dev/null)
	if [[ -n "$I_RAW" && -n "$V_RAW" ]]; then
		P_RAW=$((I_RAW * V_RAW / 1000000))
	fi
fi
E_NOW="${BAT_DATA[4]}"
E_FULL="${BAT_DATA[5]}"
CYCLE_COUNT="${BAT_DATA[6]}"
# Fallback for E_NOW / E_FULL (Energy in microwatt-hours)
# If missing, read charge_now/charge_full and convert to energy: (charge * voltage) / 1,000,000
if [[ -z "$E_NOW" ]]; then
	C_NOW=$(cat "$BAT_PATH/charge_now" 2>/dev/null)
	if [[ -n "$C_NOW" && -n "$V_RAW" ]]; then
		E_NOW=$((C_NOW * V_RAW / 1000000))
	fi
fi

if [[ -z "$E_FULL" ]]; then
	C_FULL=$(cat "$BAT_PATH/charge_full" 2>/dev/null)
	if [[ -n "$C_FULL" && -n "$V_RAW" ]]; then
		E_FULL=$((C_FULL * V_RAW / 1000000))
	fi
fi

# Time Calculation
TIME_INFO="  Time left: N/A"
if [[ "$P_RAW" -gt 0 ]]; then
	if [[ "$STATUS" == "Discharging" ]]; then
		HOURS=$(echo "scale=2; $E_NOW / $P_RAW" | bc)
		TIME_MIN=$(printf "%.0f" "$(echo "$HOURS * 60" | bc)")
		TIME_INFO="  Time left: $((TIME_MIN / 60))h $((TIME_MIN % 60))m"
	elif [[ "$STATUS" == "Charging" ]]; then
		E_DIFF=$((E_FULL - E_NOW))
		HOURS=$(echo "scale=2; $E_DIFF / $P_RAW" | bc)
		TIME_MIN=$(printf "%.0f" "$(echo "$HOURS * 60" | bc)")
		TIME_INFO="  Time till full: $((TIME_MIN / 60))h $((TIME_MIN % 60))m"
	fi
elif [[ "$STATUS" == "Full" ]]; then
	TIME_INFO="  Time left: --"
fi

# Electricals with leading zero fix
VOLT=$(printf "%.2f" "$(echo "scale=2; ${V_RAW:-0} / 1000000" | bc)")
WATT=$(printf "%.2f" "$(echo "scale=2; ${P_RAW:-0} / 1000000" | bc)")
if (($(echo "$VOLT > 0" | bc -l))); then
	AMPS=$(printf "%.2f" "$(echo "scale=2; $WATT / $VOLT" | bc)")
else
	AMPS="0.00"
fi

# Icons and Classes
VALS=(100 85 65 45 25 0)
ICONS=(" " " " " " " " " " " ")
LVLS=("LVL0" "LVL1" "LVL2" "LVL3" "LVL4" "LVL5")

for i in "${!VALS[@]}"; do
	if [ "$CAPACITY" -ge "${VALS[$i]}" ]; then
		ICON="${ICONS[$i]}"
		CLASS="${LVLS[$i]}"
		break
	fi
done

# Text and Status Overrides
DISPLAY_TEXT="$ICON $CAPACITY%"

if [[ "$STATUS" == "Charging" ]]; then
	ICON="󰔵 "
	DISPLAY_TEXT="$ICON $CAPACITY%"
elif [[ "$STATUS" == "Full" ]] || [[ "$CAPACITY" == 100 ]]; then
	ICON="󰁹󱐋"
	DISPLAY_TEXT="$ICON Full"
fi

# Final Output
TOOLTIP="  Controller: ${CONTROLLER}\n󰓅  Mode: ${MODE}${TURBO_INFO}\n󱐋  Governor: ${GOVERNOR}\n  Status: $STATUS\n  Cycle Count: $CYCLE_COUNT\n$TIME_INFO\n$dynamic_sep_line\n󰠠  Electrical\n├─ Wattage: ${WATT}W\n├─ Voltage: ${VOLT}V\n└─ Amps: ${AMPS}A"
echo "{\"text\": \"$DISPLAY_TEXT\", \"percentage\": $CAPACITY, \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"

# LOW BATTERY PERCENTAGE CHECK
source ~/.config/dtf-config/config
battery_warning_notification=${battery_warning_notification:-false}

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$STATE_DIR/battery_notif_state"

if [[ "$battery_warning_notification" == "true" ]]; then
	# Load last-notified level (0 if none)
	LAST_NOTIFIED=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

	if [[ "$STATUS" == "Discharging" ]] && [[ "$CAPACITY" -le 20 ]]; then
		THRESHOLD=$([[ "$CAPACITY" -le 10 ]] && echo 10 || echo 20)
		if [[ "$THRESHOLD" != "$LAST_NOTIFIED" ]]; then
			notify-send "Low Battery  " "Please Charge Your Device!"
			paplay "$CUSTOM_SOUND_PATH/battery-low.oga"
			echo "$THRESHOLD" >"$STATE_FILE"
		fi
	elif [[ "$CAPACITY" -gt 20 ]]; then
		# Reset once battery recovers past both thresholds
		echo 0 >"$STATE_FILE"
	fi
fi

# # BATTERY CHARGE/DISCHARGE NOTIFICATION
# battery_status_notification=${battery_status_notification:-false}
# STATUS_STATE_FILE="$STATE_DIR/battery_status_notif_state"
# # CHARGE / DISCHARGE STATUS CHANGE NOTIFICATION
# if [[ "$battery_status_notification" == "true" ]]; then
# 	# Normalize the "effective" state we care about: Charging, Discharging, or Full
# 	if [[ "$STATUS" == "Full" ]] || [[ "$CAPACITY" == 100 ]]; then
# 		CURRENT_STATE="Full"
# 	else
# 		CURRENT_STATE="$STATUS"
# 	fi
#
# 	LAST_STATE=$(cat "$STATUS_STATE_FILE" 2>/dev/null || echo "")
#
# 	if [[ "$CURRENT_STATE" != "$LAST_STATE" ]]; then
# 		case "$CURRENT_STATE" in
# 		Charging)
# 			notify-send "Charger Connected 󰚥 " "Battery is now charging ($CAPACITY%)."
# 			paplay "$CUSTOM_SOUND_PATH/power-plug.oga" 2>/dev/null
# 			;;
# 		Discharging)
# 			# Only announce "unplugged" if we were previously charging/full,
# 			# so we don't spam a notification on every single script run.
# 			if [[ "$LAST_STATE" == "Charging" || "$LAST_STATE" == "Full" ]]; then
# 				notify-send "Charger Disconnected 󰂑 " "Battery is now discharging ($CAPACITY%)."
# 				paplay "$CUSTOM_SOUND_PATH/power-unplug.oga" 2>/dev/null
# 			fi
# 			;;
# 		Full)
# 			notify-send "Battery Fully Charged 󰁹 " "You can unplug your charger."
# 			paplay "$CUSTOM_SOUND_PATH/bell.oga" 2>/dev/null
# 			;;
# 		esac
# 		echo "$CURRENT_STATE" >"$STATUS_STATE_FILE"
# 	fi
# fi
