# NixOS Configuration Files

A set of NixOS configuration files and build helpers.

- NixOS build files named like `<hostname>-configuration.nix`, included files are named like `_*.nix`.
- `extra/post-install-config.sh` is a distribution agnostic shell script that installs configuration settings that are not managed by Nix (dotfiles and GNOME desktop shortcuts).


## Usage
1. If you haven't already done so, you will need to install and log in to NixOS on the target machine.

2. Download this repo.
    ```sh
    cd ~
    git clone https://github.com/srackham/nixos-configurations.git
    ```
3. Optionally edit configuration files.
4. Rebuild NixOS using the `mknixos` alias:
    ```sh
    alias mknixos="sudo nixos-rebuild -I nixos-config=$HOME/nixos-configurations/$HOST-configuration.nix"

    mknixos switch  # Run `nixos-rebuild switch`.
    ```


## Host Configurations
- `nixos1`: GNOME desktop VirtualBox guest.
- `rpi1`: Raspberry Pi 4 NAS server (CUPS, NFS, SMB).

Files imported by host configuration files:

- `_rp4.nix`: Raspberry Pi 4 specific.
- `_server.nix`: services, packages and users.