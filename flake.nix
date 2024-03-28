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
    # The host name is the configuration name.
    nixosConfigurations.nixos1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
