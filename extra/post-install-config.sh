#!/usr/bin/env bash
#
# Distrubution agnostic script that installs configuration settings
# for srackham that are not managed by configuration.nix
#

# Create local chezmoi repo, pull from Github, then update dotfiles.
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    chezmoi init --apply https://github.com/srackham/dotfiles.git
fi

if $(which dconf); then
    # Load GNOME desktop window manager custom key bindings. Created with:
    #
    #   dconf dump /org/gnome/desktop/wm/keybindings/ >keybindings.dconf
    #
    dconf load /org/gnome/desktop/wm/keybindings/ <keybindings.dconf

    # Load GNOME desktop media custom key bindings. Created with:
    #
    #   dconf dump /org/gnome/settings-daemon/plugins/media-keys/ >media-keys.dconf
    #
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ <media-keys.dconf

    # Load GNOME Terminal profiles. Created with:
    #
    #   dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome-terminal-profiles.dconf
    #
    dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf
fi