# Server services, packages and users.
{
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "24.05";
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Pacific/Auckland";
  i18n.defaultLocale = "en_NZ.UTF-8";

  # NAS data.
  fileSystems."/files" = {
    # Samsung 2TB USB drive containing NAS files.
    device = "/dev/disk/by-label/NAS_DATA";
    fsType = "ext4";
    options = ["noatime"];
  };

  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

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

  # Manage disk usage.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 4w";
  };

  nix.settings.auto-optimise-store = true;

  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';

  # rsnapshot backups.
  services.rsnapshot = {
    enable = true;
    enableManualRsnapshot = true;
    # NOTE: Tabs must separate all config elements, and that there must be a trailing slash on the end of every directory.
    extraConfig = ''
      snapshot_root	/files/backups
      no_create_root	1

      verbose	2
      loglevel	3

      retain	hourly	6
      retain	daily	7
      retain	weekly	4
      retain	monthly	6
      backup	/files/	./	exclude=/aquota.*,exclude=/backups/
      backup	/home/	./
      backup	/etc/	./
    '';
  };

  # msmtp SMTP mail client.
  programs.msmtp = {
    enable = true;
    defaults = {
      port = 587;
      tls = true;
      auth = true;
    };
    accounts = {
      default = {
        host = "smtp.gmail.com";
        passwordeval = "cat /secrets/gmail";
        user = "srackham";
        from = "srackham@gmail.com";
      };
    };
  };

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

  programs.zsh.enable = true;

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
    # Create removable media mount points.
    "d /media 0755 root root"
    "d /media/backups 0755 root root"
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
    # Create symlinks to shared user data.
    "L /home/srackham/bin - srackham users - /files/users/srackham/bin"
    "L /home/srackham/doc - srackham users - /files/users/srackham/doc"
    "L /home/srackham/projects - srackham users - /files/users/srackham/projects"
    "L /home/srackham/tmp - srackham users - /files/users/srackham/tmp"
  ];

  #
  # Users
  #
  users = {
    # Restore users and groups on system activation.
    mutableUsers = false;

    users.root.hashedPassword = "$6$.fFbfmrL8YBmPkGo$JMSFT9XK.1CcY7vzfvuTMs9L1eiJPpT/EtFuJDKZhPdpKpIjAX7qYLD2AF4.8LMTRaNaP4fH8C52A4lhU9SQ1.";

    users.srackham = {
      uid = 1001;
      isNormalUser = true;
      description = "Stuart Rackham";
      group = "srackham";
      extraGroups = ["users" "networkmanager" "wheel" "systemd-journal"];
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
