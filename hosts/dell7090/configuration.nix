# NixOS configuration for Dell Optiplex 7090 SFF host.

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
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
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  users.users.srackham.extraGroups = [ "vboxusers" ];

  # Machine specific programs.
  environment.systemPackages = with pkgs; [
    wl-clipboard
    # xclip
  ];

  # Enable cron service.
  services.cron = {
    enable = true;
    mailto = "srackham@gmail.com";
    systemCronJobs = [

      # NOTE: Don't add cron jobs here, put them in the machine's configuration.nix file.
      # Verify system cron job installation with `sudo cat /etc/crontab`

      # # Run test job every 5 minutes
      # "*/5 * * * *      srackham    date >> /tmp/cron.log"
      #
      # # Email test
      # "*/5 * * * *      srackham    echo Test email from cron"
      #
      # # Mirror local projects to server
      # "30 * * * * srackham /home/srackham/bin/sync-local.sh >/dev/null"

      # Update recoll document index
      "35 * * * * srackham /home/srackham/bin/recollindex.sh >/dev/null"

      # Commit today's notes
      "55 17 * * * srackham /home/srackham/bin/commit-notes"

      # Ping Healthchecks.io
      "0 */4 * * * root curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/1f4df795-b3a7-4e69-9a02-dbf138bfcce9"
    ];
  };

}
