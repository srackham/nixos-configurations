#!/usr/bin/env bash
#
# Distrubution agnostic script that installs configuration settings
# for srackham that are not managed by configuration.nix
#

script_dir=$(dirname "${0}")

# Create local chezmoi repo, pull from Github, then update dotfiles.
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    echo installing dotfiles...
    chezmoi init --apply https://github.com/srackham/dotfiles.git
fi

if command -v dconf >/dev/null 2>&1; then
    echo installing GNOME configuration settings...

    # Load GNOME desktop window manager custom key bindings. Created with:
    #
    #   dconf dump /org/gnome/desktop/wm/keybindings/ > extra/keybindings.dconf
    #
    dconf load /org/gnome/desktop/wm/keybindings/ < $script_dir/keybindings.dconf

    # Load GNOME desktop media custom key bindings. Created with:
    #
    #   dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > extra/media-keys.dconf
    #
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < $script_dir/media-keys.dconf

    # Load GNOME Terminal profiles. Created with:
    #
    #   dconf dump /org/gnome/terminal/legacy/profiles:/ > extra/gnome-terminal-profiles.dconf
    #
    dconf load /org/gnome/terminal/legacy/profiles:/ < $script_dir/gnome-terminal-profiles.dconf
fi