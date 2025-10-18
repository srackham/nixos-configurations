# NixOS Configuration Files

A set of NixOS configuration files and build helpers.

- NixOS build files named like `./hosts/<hostname>/configuration.nix`, included modules are named like in the `./modules` directory.
- Use the `exported/post-install-config.sh` script in the chezmoi repo to install distro agnostic configuration options not managed by the NixOS configuration.

## TODO

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
   alias mknixos="sudo nixos-rebuild -I nixos-config=$HOME/nixos-configurations/hosts/$HOST/configuration.nix"


   mknixos switch  # Run `nixos-rebuild switch`.
   ```

## Host Configurations

- `nixos1`: GNOME desktop VirtualBox guest.
- `dell7090`: Dell Optiplex 7090 SFF desktop PC.
- `rpi1`: Raspberry Pi 4 NAS server (CUPS, NFS, SMB).

Nix modules imported by host configuration files:

- `./modules/rp4.nix`: Raspberry Pi 4 specific.
- `./modules/server.nix`: services, packages and users.

A comprehensive look at NixOS configuration modularity can be found here:
[Modularize NixOS and Home Manager](https://www.youtube.com/watch?v=vYc6IzKvAJQ).
