# NixOS Configuration Files

NixOS configuration files and build helpers.

- Build files named like `<hostname>-*.nix`, the root configuration file is named `<hostname>-configuration.nix` e.g. `nixos1-configuration.nix`, `nixos1-hardware-configuration.nix`.

- This repo is installed locally in `$HOME/nixos-configurations`.

- The `mknixos` shell alias is used to invoke `nixos-rebuild` e.g. `mknixos switch`:
```
alias mknixos="sudo nixos-rebuild -I nixos-config=$HOME/nixos-configurations/$HOST-configuration.nix"
```

## Configurations
Listed by host name:

- `nixos1`: GNOME desktop.
- `rpi1`: Raspberry Pi 4 NAS server (CUPS, NFS, SMB).


## TODO
- Refactor `rpi1` config files, separating hardwware and host related stuff into separate files.



