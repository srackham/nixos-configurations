{...}: {
  imports = [
    ./_rp4.nix
    ./_server.nix
  ];
  # Host dependent configuration.
  networking.hostName = "rpi1";
}
