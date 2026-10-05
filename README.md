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
   alias mknixos="sudo nixos-rebuild -I nixos-config=$HOME/share/projects/nixos-configurations/hosts/$HOST/configuration.nix"


   mknixos switch  # Run `nixos-rebuild switch`.
   ```

## Host Configurations

To create a host configuration:

- Install NixOS on the host machine.
- Name the host e.g. `dell5450`. The default host name set by the installer is `nixos` this is changed in the `configuration.nix` files.
- Create a configuration directory for the host, see _Create a custom NixOS configuration for the target machine_ `/home/srackham/share/notes/nixos-notes.md`

[Modularize NixOS and Home Manager](https://www.youtube.com/watch?v=vYc6IzKvAJQ).
