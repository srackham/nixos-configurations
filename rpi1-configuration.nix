{...}: {
  imports = [
    ./_rp4.nix
    ./_server.nix
  ];

  networking.hostName = "rpi1";

  # Samsung 2TB USB drive, partition 1 containing NAS data.
  fileSystems."/files".device = "/dev/disk/by-uuid/10fcd726-ccff-4cb6-8b34-21b3d7c554ce";
}
