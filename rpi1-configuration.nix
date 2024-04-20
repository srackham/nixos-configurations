{
  config,
  pkgs,
  lib,
  ...
}: {
  # Raspberry Pi 4 specific options.
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  # Hardware independent options.
  # TODO: move these to included `server-configuration.nix` file.
  system.stateVersion = "24.05";
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  networking = {
    networkmanager.enable = true;
    hostName = "rpi1";
  };

  services.openssh.enable = true;

  # CUPS print server.
  # See https://nixos.wiki/wiki/Printing
  services.printing = {
    enable = true;
    drivers = [
      pkgs.brlaser # Includes Brother HL-2140 driver.
    ];
    listenAddresses = ["*:631"];
    allowFrom = ["all"];
    browsing = true;
    defaultShared = true;
    openFirewall = true;
    # "Upgrade Required" issue, see https://nixos.wiki/wiki/Printing
    extraConf = ''
      DefaultEncryption Never
    '';
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  environment.systemPackages = with pkgs; [
    coreutils-full
    cron
    git
    killall
    lsb-release
    neofetch
    nfs-utils
    rclone
    vim
    wget
    zsh
  ];

  programs.zsh.enable = true;

  users = {
    # Restore users and groups on system activation.
    mutableUsers = false;

    # Server admin account.
    users.super = {
      uid = 1000;
      isNormalUser = true;
      description = "System Administrator";
      group = "users";
      extraGroups = ["users" "networkmanager" "wheel"];
      hashedPassword = "$6$U1c5Q14zg8w2z4zX$E1RJgFUZ67Ls1AQqarR.ZRI31I1kx/tlQCe92aUzkNVp5tu30EJTNfWrIFF0iUcM3aQG/3o77y1YozoLIqTDS/";
      shell = pkgs.zsh;
      packages = with pkgs; [
        alejandra
        bat
        chezmoi
        eza
        fd
        fzf
        gnumake
        htop
        ripgrep
      ];
    };

    users.srackham = {
      uid = 1001;
      isNormalUser = true;
      description = "Stuart Rackham";
      group = "srackham";
      extraGroups = ["users" "networkmanager" "wheel"];
      hashedPassword = "$6$./rhdw/.5ZMU8j29$SZz6SnmsBoTDAAt2gdiRpvoNgpbuKK53IgQj7R3goQTqrrISKdvwwpLkd9qEIMXD1unaSux3VziGUTcHJpDro1";
      shell = pkgs.zsh;
      packages = with pkgs; [
        alejandra
        bat
        chezmoi
        eza
        fd
        fzf
        gnumake
        htop
        ripgrep
      ];
    };
    groups.srackham = {
      gid = 1001;
      members = ["srackham"];
    };

    users.peggy = {
      uid = 1002;
      isNormalUser = true;
      description = "Peggy Lee";
      group = "peggy";
      extraGroups = ["users" "wheel"];
      hashedPassword = "$6$SKQodRom5EDQwLBb$hKZKuTSlIC2vtNrBb89.b01bFh2lzXaUfrLmx7qos1WrEwZqhorX54jf.rLWbXF4pMtMf6BhBDXW19gbqlrnv/";
      packages = with pkgs; [
      ];
    };
    groups.peggy = {
      gid = 1002;
      members = ["peggy"];
    };
  };
}
