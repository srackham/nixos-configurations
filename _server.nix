# Server services, packages and users.
{
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "24.05";
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  # NAS data.
  fileSystems."/files" = {
    fsType = "ext4";
    options = ["noatime"];
  };

  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  # Perform garbage collection weekly.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 4w";
  };

  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

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
      passwd program =
    '';
    shares = {
      public = {
        path = "/files/public";
        "writable" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force create mode" = "0664";
        "force directory mode" = "0775";
        "ea support" = "no";
        "hide dot files" = "no";
        "hide special files" = "yes";
        "store dos attributes" = "no";
        "guest ok" = "yes";
      };
      srackham = {
        path = "/files/users/srackham";
        "writable" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force create mode" = "0664";
        "force directory mode" = "0775";
        "ea support" = "no";
        "hide dot files" = "no";
        "hide special files" = "yes";
        "store dos attributes" = "no";
      };
      peggy = {
        path = "/files/users/peggy";
        "writable" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force create mode" = "0664";
        "force directory mode" = "0775";
        "ea support" = "no";
        "hide dot files" = "no";
        "hide special files" = "yes";
        "store dos attributes" = "no";
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
    /export           192.168.1.0/24(rw,fsid=root,no_subtree_check,no_root_squash)
    /export/public    192.168.1.0/24(rw,nohide,insecure,no_subtree_check,no_root_squash)
    /export/srackham  192.168.1.0/24(rw,nohide,insecure,no_subtree_check,no_root_squash)
  '';

  networking.firewall.allowedTCPPorts = [2049];

  # Setup necessary directories and files.
  systemd.tmpfiles.rules = [
    # See `man 5 tmpfiles.d`.
    # Create NFS bind mount points.
    "d /export 0755 root root"
    "d /export/public 0777 root root"
    "d /export/srackham 0755 srackham users"
    # Create Samba share paths.
    "d /files 0755 root root"
    "d /files/backups 0755 root root"
    "d /files/public 0777 root root"
    "d /files/users 0755 root root"
    "d /files/users/peggy 0755 peggy users"
    "d /files/users/srackham 0755 srackham users"
  ];

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
        tree
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
