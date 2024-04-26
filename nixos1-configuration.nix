# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./nixos1-hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  # Global packages for all users.
  environment.systemPackages = with pkgs; [
    coreutils-full
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

  # Set the global environment variables in /etc/set-environment
  environment.variables.EDITOR = "vim";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.printers.ensureDefaultPrinter = "Brother_HL_2140_series_nuc1";
  # IPP Everywhere printer detection (see https://nixos.wiki/wiki/Printing).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable cron service.
  services.cron = {
    enable = true;
    mailto = "srackham@gmail.com";
    systemCronJobs = [
      # Run test job every 5 min.
      # "*/5 * * * *      srackham    date >> /tmp/cron.log"

      # Email test.
      # "*/5 * * * *      srackham    echo Test email from cron"

      # Copy local projects to/from server.
      # "20 8,14,18  * * * srackham /home/srackham/bin/copy-projects.sh > /dev/null"
    ];
  };

  users = {
    mutableUsers = false; # Restore users and groups on system activation.

    users.root.hashedPassword = "$6$jVrup09FS2JN4pvA$U1cKoXVRv78gzVS2vn8DJuE44aHkZ7IpVqsT/5N5TlkBoiLgbMvlDRKSeszYMtbURJrqQ5nOkCdnaEcoeqYlg1";

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
        brave
        chezmoi
        conda
        dart
        deno
        evince
        eza
        fd
        firefox
        fzf
        gnome.dconf-editor
        gnome.eog
        gnome.gnome-terminal
        gnome.gnome-tweaks
        gnucash
        gnumake
        go
        htop
        jq
        libreoffice
        menulibre
        nodejs
        nushell
        remmina
        ripgrep
        tesseract
        tree
        vlc
        vscode
        xclip
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
      extraGroups = ["users" "networkmanager" "wheel"];
      hashedPassword = "$6$SKQodRom5EDQwLBb$hKZKuTSlIC2vtNrBb89.b01bFh2lzXaUfrLmx7qos1WrEwZqhorX54jf.rLWbXF4pMtMf6BhBDXW19gbqlrnv/";
      packages = with pkgs; [
        firefox
      ];
    };
    groups.peggy = {
      gid = 1002;
      members = ["peggy"];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH server.
  # See https://nixos.wiki/wiki/SSH_public_key_authentication
  services.openssh = {
    enable = true;
    # settings.PasswordAuthentication = true; # Optional, consider key-based authentication instead.
    settings.PermitRootLogin = "yes";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # SJR: 7-Mar-2024
  # https://discourse.nixos.org/t/does-anybody-have-working-automatic-resizing-in-virtualbox/7391/13
  services.xserver.videoDrivers = lib.mkForce ["vmware" "virtualbox" "modesetting"];
  services.xserver.displayManager.gdm.wayland = false; # VBox requires X.
  systemd.user.services = let
    vbox-client = desc: flags: {
      description = "VirtualBox Guest: ${desc}";

      wantedBy = ["graphical-session.target"];
      requires = ["dev-vboxguest.device"];
      after = ["dev-vboxguest.device"];

      unitConfig.ConditionVirtualization = "oracle";

      serviceConfig.ExecStart = "${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv ${flags}";
    };
  in {
    virtualbox-resize = vbox-client "Resize" "--vmsvga";
    virtualbox-clipboard = vbox-client "Clipboard" "--clipboard";
  };

  virtualisation.virtualbox.guest = {
    enable = true;
  };

  # Mount NFS shares on server.
  fileSystems."/home/srackham/public" = {
    device = "nuc1:/public";
    fsType = "nfs";
  };
  fileSystems."/home/srackham/share" = {
    device = "nuc1:/srackham";
    fsType = "nfs";
  };
  systemd.tmpfiles.rules = [
    # Create the mount points and symlinks if they don't exist (see `man 5 tmpfiles.d`).
    "d /home/srackham/public 0755 srackham users"
    "d /home/srackham/share 0755 srackham users"
    "L /home/srackham/bin - srackham users - /home/srackham/share/bin"
    "L /home/srackham/doc - srackham users - /home/srackham/share/doc"
    "L /home/srackham/projects - srackham users - /home/srackham/share/projects"
    "L /home/srackham/tmp - srackham users - /home/srackham/share/tmp"
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  # From https://nixos-and-flakes.thiscute.world/nixos-with-flakes/other-useful-tips#managing-the-configuration-with-git
  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;
  # boot.loader.grub.configurationLimit = 10;

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

  # sudo rules.
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
}
