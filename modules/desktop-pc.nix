# Common GNOME Desktop configuration across desktop PCs.

{ config, pkgs, ... }:
{
  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # Enable Nix flakes.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unpatched dynamic binaries.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs.
  ];

  # Limit the number of generations to keep.
  boot.loader.systemd-boot.configurationLimit = 10;

  # Manage disk usage.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;
  systemd.settings.Manager = {
    SystemMaxUse = "2G";
  };

  #
  # Services
  #

  # Set a global default timeout for stopping services (the default is 90s).
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "srackham";

  # Unlock GNOME Keyring to suppress Brave "Choose a password for a new keyring" message.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Configure keyboard (X11, Wayland and TTY compatible)
  services.keyd = {
    enable = true;
    keyboards.default.settings = {
      # Written to /etc/keyd/<keyboard>.conf
      main = {
        capslock = "overload(control, esc)"; # Caps Lock as Control when held, Escape when tapped
        pause = "esc";
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [
      pkgs.cnijfilter2 # For Canon TR4500 printer
    ];
  };
  hardware.printers.ensureDefaultPrinter = "Brother_HL_2140_series_nuc1";
  # IPP Everywhere printer detection (see https://nixos.wiki/wiki/Printing).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enables support for SANE scanners
  hardware.sane.enable = true;

  # Add udev rules to allow Ledger access.
  hardware.ledger.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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

  # Enable the OpenSSH server.
  # See https://nixos.wiki/wiki/SSH_public_key_authentication
  services.openssh = {
    enable = true;
    # settings.PasswordAuthentication = true; # Optional, consider key-based authentication instead.
    settings.PermitRootLogin = "yes";
    extraConfig = ''
      # Allow WezTerm to set associated environment variables
      AcceptEnv TERM TERM_PROGRAM TERM_PROGRAM_VERSION COLORTERM WEZTERM_*
    '';
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
    "d /media 0755 root root"
    "d /media/backups 0755 root root"
    "d /home/srackham/public 0755 srackham users"
    "d /home/srackham/share 0755 srackham users"
    "L /home/srackham/bin - srackham users - /home/srackham/share/bin"
    "L /home/srackham/doc - srackham users - /home/srackham/share/doc"
    "L /home/srackham/doc - srackham users - /home/srackham/share/notes"
    "L /home/srackham/projects - srackham users - /home/srackham/share/projects"
    "L /home/srackham/tmp - srackham users - /home/srackham/share/tmp"
    "L /home/srackham/.local/share/backgrounds - srackham users - /home/srackham/share/doc/backgrounds"
  ];

  # Stop the GDM from hibernating the host machine.
  services.displayManager.gdm.autoSuspend = false;

  #
  # Programs
  #

  # Install firefox.
  programs.firefox.enable = true;

  # Configure zsh as an interactive shell
  programs.zsh.enable = true;

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Set the global environment variables in /etc/set-environment
  environment.variables.EDITOR = "vim";

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-color-emoji
  ];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    btop
    coreutils-full
    file
    git
    iotop
    iperf
    killall
    lsb-release
    lsof
    neofetch
    nerd-fonts.jetbrains-mono
    nfs-utils
    nethogs
    libnotify
    rclone
    sane-backends
    sshpass
    unzip
    usbutils
    vim
    wget
    zip
  ];

  # msmtp SMTP mail client.
  # NOTE: Manually copy the /secrets/gmail (it's not in the repository).
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  #
  # Users
  #

  users = {
    mutableUsers = false; # Restore users and groups on system activation.

    users.root.hashedPassword = "$6$jVrup09FS2JN4pvA$U1cKoXVRv78gzVS2vn8DJuE44aHkZ7IpVqsT/5N5TlkBoiLgbMvlDRKSeszYMtbURJrqQ5nOkCdnaEcoeqYlg1";

    # Default installer user account.
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.guest = {
      uid = 1000;
      isNormalUser = true;
      description = "Guest User";
      group = "users";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      hashedPassword = "$6$bMI72/K0Wr0suily$mi53iPUZe5Pq7sAK84JHNPlFbOBsCNaXRCx8UAoen44EZ9wxcMKggJyRURcXlnrxxCf4Wqlzt0imIoSyEf6VL0";
      packages = with pkgs; [
        #  thunderbird
      ];
    };

    users.srackham = {
      uid = 1001;
      isNormalUser = true;
      description = "Stuart Rackham";
      group = "srackham";
      extraGroups = [
        "users"
        "networkmanager"
        "systemd-journal"
        "wheel"
        "video"
      ];
      hashedPassword = "$6$./rhdw/.5ZMU8j29$SZz6SnmsBoTDAAt2gdiRpvoNgpbuKK53IgQj7R3goQTqrrISKdvwwpLkd9qEIMXD1unaSux3VziGUTcHJpDro1";
      shell = pkgs.zsh;
      packages = with pkgs; [
        alacritty
        alsa-utils
        argc # Required for AIChat functions (https://github.com/sigoden/llm-functions)
        bat
        brave
        cheese
        chezmoi
        conda
        dart
        delta
        delve
        deno
        dig
        evince
        exercism
        eza
        fd
        # firefox
        fzf
        gleam
        erlang
        rebar3
        dconf-editor
        eog
        ffmpeg
        gh
        gimp
        gnome-terminal
        gnome-tweaks
        google-chrome
        gnucash
        gnumake
        gnuplot_qt
        go
        gotests
        golangci-lint
        golangci-lint-langserver
        gopls
        gotools
        gpick
        helix
        htop
        jq
        jujutsu
        lazygit
        gcc
        ledger-live-desktop
        libreoffice
        lua
        luaPackages.ldoc
        stylua
        marksman
        menulibre
        neovim
        nil
        nixd
        nixfmt-rfc-style
        nodejs
        npm-check-updates
        nushell
        obsidian
        obsidian-export
        poppler-utils
        prettierd
        python3
        pulseaudio
        recoll
        remmina
        rustdesk-flutter
        ripgrep
        rustup
        sd
        shellcheck
        shfmt
        telegram-desktop
        tesseract
        tmux
        tree
        uv
        v4l-utils
        viu
        vlc
        vscode
        vscode-js-debug
        wezterm
        zoxide
      ];
    };
    groups.srackham = {
      gid = 1001;
      members = [ "srackham" ];
    };

    users.peggy = {
      uid = 1002;
      isNormalUser = true;
      description = "Peggy Lee";
      group = "peggy";
      extraGroups = [
        "users"
        "networkmanager"
        "wheel"
      ];
      hashedPassword = "$6$SKQodRom5EDQwLBb$hKZKuTSlIC2vtNrBb89.b01bFh2lzXaUfrLmx7qos1WrEwZqhorX54jf.rLWbXF4pMtMf6BhBDXW19gbqlrnv/";
      packages = with pkgs; [
        # firefox
      ];
    };
    groups.peggy = {
      gid = 1002;
      members = [ "peggy" ];
    };
  };

  # Users that don't require a sudo password.
  security.sudo.extraRules = [
    {
      users = [ "srackham" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

}
