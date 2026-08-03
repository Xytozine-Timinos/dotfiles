#!/usr/bin/env bash

echo "Clear current cache..."
hyprpm purge-cache
echo "Update store cache..."
hyprpm update
echo "Adding https://github.com/hyprwm/hyprland-plugins..."
hyprpm -v add https://github.com/hyprwm/hyprland-plugins

echo "Enabling hyprbars"
hyprpm enable hyprbars
