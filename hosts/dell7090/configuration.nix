# NixOS configuration for Dell Optiplex 7090 SFF host.

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/desktop-pc.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dell7090"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # # Samsung 2TB USB SSD drive.
  # fileSystems."/data" = {
  #   device = "/dev/disk/by-uuid/407fa118-0264-43f0-a265-146bb4f0dadc";
  #   fsType = "ext4";
  #   options = [
  #     "defaults"
  #     # This option prevents the boot from failing if the drive is not present.
  #     "nofail"
  #   ];
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # VirtualBox host configuration.
  virtualisation.virtualbox.host.enable = true; # Install and configure VirtualBox host.

  # virt-manager QEMU  host configuration.
  virtualisation.libvirtd.enable = true; # Enable the libvirt daemon
  programs.virt-manager.enable = true; # Enable the virt-manager program

  # Machine specific programs and user configuration.
  environment.systemPackages = with pkgs; [
    qemu
    virt-manager # Necessary for CLI apps when programs.virt-manager is not enabled.
    virt-viewer
    wl-clipboard
    # xclip
  ];

  users.users.srackham.extraGroups = [
    "vboxusers"
    "libvirtd"
  ];
}
