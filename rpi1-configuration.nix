{...}: {
  imports = [
    ./_rp4.nix
    ./_server.nix
  ];
  networking.hostName = "rpi1";
}
