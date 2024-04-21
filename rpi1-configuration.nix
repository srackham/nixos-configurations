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

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = ["noatime"];
  };
  fileSystems."/files" = {
    # Samsung 2TB USB drive, partition 1 containing NAS data.
    device = "/dev/disk/by-uuid/10fcd726-ccff-4cb6-8b34-21b3d7c554ce";
    fsType = "ext4";
    options = ["noatime"];
  };

  # Hardware independent options.
  system.stateVersion = "24.05";
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  # Perform garbage collection weekly.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 4w";
  };

  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

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
    rsnapshot
    vim
    wget
    zsh
  ];

  security.sudo.extraRules = [
    {
      users = ["srackham"]; # Users that don't require sudo password.
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Windows file sharing.
  # https://nixos.wiki/wiki/Samba
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = NUCLEUS
      server string = %h server
    '';
    shares = {
      public = {
        path = "/files/public";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force create mode" = "0664";
        "force directory mode" = "0775";
        "ea support" = "no";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # NFS server.
  # https://nixos.wiki/wiki/NFS
  fileSystems."/export/public" = {
    device = "/files/public";
    options = ["bind"];
  };

  fileSystems."/export/srackham" = {
    device = "/files/users/srackham";
    options = ["bind"];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export           192.168.1.0/24(rw,fsid=0,no_subtree_check,no_root_squash)
    /export/public    192.168.1.0/24(rw,nohide,insecure,no_subtree_check,no_root_squash)
    /export/srackham  192.168.1.0/24(rw,nohide,insecure,no_subtree_check,no_root_squash)
  '';

  systemd.tmpfiles.rules = [
    # See `man 5 tmpfiles.d`.
    # Create NFS bind mount points.
    "d /export 0755 root root"
    "d /export/public 0755 root root"
    "d /export/srackham 0755 root root"
  ];

  networking.firewall.allowedTCPPorts = [2049];

  #
  # Users
  #
  programs.zsh.enable = true;

  users = {
    # Restore users and groups on system activation.
    mutableUsers = false;

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
