#!/usr/bin/env bash

# Configuration settings not managed by configuration.nix
#
# - Configures GNOME and applications.
# - Can be run on non-NixOS distributions.
#

# Load GNOME desktop window manager custom key bindings. Created with:
#
#   dconf dump /org/gnome/desktop/wm/keybindings/ >keybindings.txt
#
dconf load /org/gnome/desktop/wm/keybindings/ <keybindings.txt

# Load GNOME desktop media custom key bindings. Created with:
#
#   dconf dump /org/gnome/settings-daemon/plugins/media-keys/ >media-keys.txt
#
dconf load /org/gnome/settings-daemon/plugins/media-keys/ <media-keys.txt