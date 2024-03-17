# See https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled
{
  description = "NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # See `sudo nix-channel --list`
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # Host name is `nixos`.
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
