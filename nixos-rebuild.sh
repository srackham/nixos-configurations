#!/usr/bin/env bash

# A rebuild script that commits on a successful build:
# https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5

# I added server backup using rsync.

CONF_DIR=$HOME/nixos/
SERVER_DIR=$HOME/share/backups/nixos/$CONF_DIR

set -e
pushd $CONF_DIR >/dev/null
if [ -z "$(git status --porcelain)" ]; then
    echo "There are no configuration changes."
    exit 1
fi
alejandra . &>/dev/null
git diff -U0 *.nix
echo "NixOS Rebuilding..."
#sudo nixos-rebuild switch &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
sudo nixos-rebuild switch
current=$(nixos-rebuild list-generations | grep current)
git commit -am "$current"
popd

# Backup ~/nixos/ to server.
rsync -avzH --delete --info=progress2 $CONF_DIR $SERVER_DIR
