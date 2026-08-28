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

# Sum RSS (KB) for target PID + all its descendants, using one process snapshot
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

# Available (free-ish) system RAM in KB, from /proc/meminfo
get_free_ram_kb() {
	awk '/MemAvailable/ {print $2}' /proc/meminfo
}

# Format a KB value as "123MB" or "1.2GB"
format_kb() {
	local kb="$1"
	local mb=$((kb / 1024))
	if [ "$mb" -ge 1024 ]; then
		awk "BEGIN {printf \"%.1fGB\", $kb / 1048576}"
	else
		echo "${mb}MB"
	fi
}

handle_title() {
	data=$(hyprctl activewindow -j)
	class=$(echo "$data" | jq -r '.class')
	full_title=$(echo "$data" | jq -r '.title' | sed -e 's/&/and/g' -e 's/</[/g' -e 's/>/]/g')
	pid=$(echo "$data" | jq -r '.pid')

	if [ -z "$class" ] || [ "$class" = "null" ]; then
		free_kb=$(get_free_ram_kb)
		echo "{\"text\": \"󰖲\", \"tooltip\": \"  No active window\n  Available RAM: $(format_kb "$free_kb")\"}"
		return
	fi

	ram_display="Null B"
	if [ -n "$pid" ] && [ "$pid" != "null" ]; then
		ram_kb=$(get_tree_ram_kb "$pid")
		free_kb=$(get_free_ram_kb)
		if [ -n "$ram_kb" ] && [ "$ram_kb" -gt 0 ]; then
			ram_display="$(format_kb "$ram_kb")/$(format_kb "$free_kb")"
		fi
	fi

	short_label="${class:0:15}"
	window_tooltip="  $full_title\n  RAM Usage/Free: $ram_display"
	echo "{\"text\": \"󰖯 $short_label\", \"tooltip\": \"$window_tooltip\"}"
}

handle_title

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
	if [[ "$line" == activewindowv2* ]] || [[ "$line" == windowtitlev2* ]]; then
		handle_title
	fi
done
