#!/usr/bin/env bash
#
# Distrubution agnostic script that installs configuration settings
# not managed by configuration.nix
#

# Create local chezmoi repo, pull from Github, then update dotfiles.
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    chezmoi init --apply https://github.com/srackham/dotfiles.git
fi

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