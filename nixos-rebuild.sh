#!/usr/bin/env bash

# A rebuild script that commits on a successful build:
# https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5

# I added server backup using rsync.

CONF_DIR=$HOME/nixos/
SERVER_DIR=$HOME/share/backups/nixos/$CONF_DIR

set -e

pushd $CONF_DIR >/dev/null
alejandra . &>/dev/null
git diff
echo "Rebuilding NixOS..."
sudo nixos-rebuild switch
msg=$(nixos-rebuild list-generations --json | jq -r '.[] | select(.current == true) | "generation: \(.generation), date: \(.date), nixosVersion: \(.nixosVersion), kernelVersion: \(.kernelVersion)"')
git commit -am "$msg"
popd

# Backup ~/nixos/ to server.
rsync -azH --delete --info=progress2 $CONF_DIR $SERVER_DIR