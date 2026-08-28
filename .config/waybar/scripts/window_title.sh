#!/usr/bin/env bash

# Recursively print all descendant PIDs of a given PID
get_descendants() {
	local pid="$1"
	local children
	children=$(pgrep -P "$pid" 2>/dev/null)
	for child in $children; do
		echo "$child"
		get_descendants "$child"
	done
}

# Walk up to the top-level parent, then sum RSS (KB) across the whole tree
get_tree_ram_kb() {
	local target_pid="$1"
	local snapshot
	snapshot=$(ps -eo pid=,ppid=,rss=)

	awk -v root="$target_pid" '
		{ ppid[$1]=$2; rss[$1]=$3 }
		END {
			marked[root]=1
			total = rss[root]
			queue[root]=1
			while (length(queue) > 0) {
				for (q in queue) {
					for (p in ppid) {
						if (ppid[p] == q && !(p in marked)) {
							marked[p]=1
							total += rss[p]
							newqueue[p]=1
						}
					}
					delete queue[q]
				}
				for (nq in newqueue) { queue[nq]=1; delete newqueue[nq] }
			}
			print total
		}
	' <<<"$snapshot"
}

handle_title() {
	# Get JSON data for the active window
	data=$(hyprctl activewindow -j)
	class=$(echo "$data" | jq -r '.class')
	full_title=$(echo "$data" | jq -r '.title' | sed -e 's/&/and/g' -e 's/</[/g' -e 's/>/]/g')
	pid=$(echo "$data" | jq -r '.pid')

	if [ -z "$class" ] || [ "$class" = "null" ]; then
		echo "{\"text\": \"󰖲\", \"tooltip\": \"  No active window\"}"
		return
	fi

	ram_display="Null B"
	if [ -n "$pid" ] && [ "$pid" != "null" ]; then
		ram_kb=$(get_tree_ram_kb "$pid")
		if [ -n "$ram_kb" ] && [ "$ram_kb" -gt 0 ]; then
			ram_mb=$((ram_kb / 1024))
			if [ "$ram_mb" -ge 1024 ]; then
				ram_gb=$(awk "BEGIN {printf \"%.1f\", $ram_kb / 1048576}")
				ram_display="$ram_gb GB"
			else
				ram_display="$ram_mb MB"
			fi
		fi
	fi

	short_label="${class:0:15}"
	window_tooltip="  $full_title\n  RAM Usage: $ram_display"
	echo "{\"text\": \"󰖯 $short_label\", \"tooltip\": \"$window_tooltip\"}"
}

handle_title

# Listen for window changes
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
	if [[ "$line" == activewindowv2* ]] || [[ "$line" == windowtitlev2* ]]; then
		handle_title
	fi
done
