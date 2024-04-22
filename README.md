# NixOS Configuration Files

NixOS configuration files and build helpers.

- NixOS build files named like `<hostname>-configuration.nix`, included files are named like `_*.nix`.

- This repo is installed on host machines with:
    ```sh
    cd ~
    git clone https://github.com/srackham/nixos-configurations.git
    ```

- The `mknixos` shell alias is used to invoke the `nixos-rebuild` command :
    ```sh
    alias mknixos="sudo nixos-rebuild -I nixos-config=$HOME/nixos-configurations/$HOST-configuration.nix"

    mknixos switch  # Run `nixos-rebuild switch`.
    ```
- `extra/post-install-config.sh` is a distribution agnostic shell script that installs configuration settings that are not managed by Nix (dotfiles and GNOME desktop shortcuts).


## Host Configurations
- `nixos1`: GNOME desktop VirtualBox guest.
- `rpi1`: Raspberry Pi 4 NAS server (CUPS, NFS, SMB).


## Included Files
These files are imported by host configuration files.

- `_rp4.nix`: Raspberry Pi 4 specific.
- `_server.nix`: services, packages and users.