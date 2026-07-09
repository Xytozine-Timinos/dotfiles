#!/bin/bash

# Taken from https://github.com/ray-pH/waybar-cava
# modified for better performace by geminiAI

# Array of bars for direct indexing (much faster than string slicing)
bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

# Write cava config
config_file="/tmp/polybar_cava_config"
cat <<EOF >"$config_file"
[general]
bars = 9

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# Read stdout from cava using a process substitution (< <(...))
# This keeps the while loop in the main shell process instead of splitting it into subshells.
while read -r line; do
	# Clear the previous output line
	output=""

	# Process the line character by character using internal Bash logic (no sed spawned)
	for ((i = 0; i < ${#line}; i++)); do
		char="${line:$i:1}"

		if [[ "$char" =~ [0-7] ]]; then
			output+="${bars[$char]}"
		elif [ "$char" != ";" ]; then
			output+="$char"
		fi
	done

	echo "$output"
done < <(exec cava -p "$config_file")
