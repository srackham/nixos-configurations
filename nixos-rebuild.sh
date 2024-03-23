#!/usr/bin/env bash

# A rebuild script that commits on a successful build:
# https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5

# I added server backup using rsync.

CONF_DIR=$HOME/nixos-configuration/
# SERVER_DIR=$HOME/share/backups/nixos/$CONF_DIR

set -e

pushd $CONF_DIR >/dev/null
alejandra . &>/dev/null
git diff
echo "Rebuilding NixOS..."
sudo nixos-rebuild switch
msg=$(nixos-rebuild list-generations --json | jq -r '.[] | select(.current == true) | "gen=\(.generation)   date=\(.date)   nixos=\(.nixosVersion)   kernel=\(.kernelVersion)"')
set +e  # Don't exit if there's nothing to commit i.e. it was done manually).
git commit -am "$msg"
set -e
git push
popd

# Backup ~/nixos/ to server.
# rsync -azH --delete --info=progress2 $CONF_DIR $SERVER_DIR
