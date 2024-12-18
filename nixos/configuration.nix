# Note: the following configuration file is very messy
# - It contains much of the original initial configuration options/guidance
# - It's all in one large configuration file

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nix.settings.experimental-features =
    [
      "nix-command"
      "flakes"
    ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 2w";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  boot.tmp.cleanOnBoot = true;
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchDocked = "suspend";

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpak-repo
    '';
  };

  # services.printing.enable = true;
  #
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };

  services.kanata = {
    enable = true;
  };
    

  hardware.i2c.enable = true;
  hardware.keyboard.qmk.enable = true;

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "nixos-laptop"; # Define your hostname.

  # See if I can replace this with security.sudo.extraRules later
  # security.sudo.extraConfig = ''
  #   Defaults        env_reset,timestamp_timeout=15,fingerprint
  # '';
  
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "America/Los_Angeles";

  programs.nix-ld = {
    enable = true;
    # libraries = with pkgs; [
    #   dotnet-sdk_8
    #   wayland
    # ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  programs.hyprland = {
    enable = true;
  };

  programs.hyprlock.enable = true;
  services.hypridle.enable = true;

  programs.direnv.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; 
      [
        xdg-desktop-portal-gtk
      ];
    xdgOpenUsePortal = true;
  };

  programs.zsh.enable = true;
  programs.zsh.shellAliases = {
    nix-edit = "nvim -c \"lcd ~/.config/nixos\" -c NvimTreeToggle";
    rebuild = "sudo nixos-rebuild switch";
    nix-develop = "nix develop -c \"zsh\" -c \"export SHELL=zsh; zsh -i\"";
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # May be unnecessary if Hyprland is installed
  services.libinput.enable = true;

  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd = {
    enable = true;
  };

  services.upower.enable = true;
  
  users.users.jacksonb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "sudo" "docker" "dialout"]; 
    shell = pkgs.zsh;
  };
  nixpkgs.config.allowUnfree = true;

  services.syncthing = {
    enable = true;

    # TO-DO: Figure out how to prepend my username to these paths
    user = "jacksonb";
    configDir = "/home/jacksonb/.config/syncthing";
  };

  documentation.dev.enable = true; # Lets us use man 3

  qt.enable = true;
  # qt.platformTheme = "gtk2";
  # qt.style = "gtk2";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  virtualisation.docker.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search <package name> 
  environment.systemPackages = with pkgs; [

  # Shell Apps
    fish
    zsh
    unstable.oh-my-posh
    fzf
    wget
    tmux
    zoxide
    btop
    thefuck
    git
    gh
    unzip
    gcc
    gnumake
    gdb
    bind
    unstable.neovim
    unstable.neovide
    p7zip
    valgrind
    bat
    libqalculate
    man-pages
    man-pages-posix
    xdg-utils
    ffmpeg
    fprintd
    socat
    brightnessctl
    qmk
    playerctl
    gnuplot
    yt-dlp
    usbutils

  # Desktop Environment Apps
    wl-clipboard
    clipboard-jh
    rofi-wayland
    (rofi-calc.override {
      rofi-unwrapped = rofi-wayland-unwrapped;
    })
    unstable.bambu-studio
    libnotify
    glib
    unstable.moonlight-qt
    # gnome.adwaita-icon-theme
    adwaita-icon-theme
    zoom-us
    overskride
    thunderbird # When 24.11 launches, update this to use programs.thunderbird
    hyprpicker
    via
    wev
    jq
    syncthingtray
    vscodium # Only here for a slightly improved Markdown rendering/editing experience. And Git. 
    android-file-transfer
    freecad-wayland

    grim # https://sr.ht/~emersion/grim/
    slurp # https://github.com/emersion/slurp?tab=readme-ov-file
    wf-recorder # https://github.com/ammen99/wf-recorder

    inputs.ags.packages.${system}.default
    ddcutil # Needed by AGS config for now
    bun
    nordic

  # Graphical Apps
    brave
    firefox
    kitty
    networkmanagerapplet
    nwg-displays

    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.qtwayland

    pavucontrol
    gparted

    # Electron
    obsidian
    discord

  # Development
    nodejs
    python3
    go
    gopls
    smlnj # School
    dotnetCorePackages.dotnet_8.sdk #Not sure why I had to install this for Godot. 
    godot_4-mono

    wireshark

    meson
    cmake
    egl-wayland
    pkg-config
    wayland-scanner
    wayland
    
    mongodb-compass # Work

    
    # language servers
    lua-language-server
    clang-tools
    nil
    vscode-langservers-extracted
    pyright
    taplo
  # TODO - Figure out how to get these outta here. Since I can't use NPM to install globally,
  # these packages have to get pulled from that one gigantic Nixpkgs module, which as far as I can 
  # tell greatly increases my evaluation time since it's like 20k lines.
    nodePackages.typescript-language-server
    pkgs.nodePackages.bash-language-server
    millet # School
    csharp-ls
    swi-prolog

    arduino-cli
    arduino-language-server
    arduino-ide

  ];

  
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = [ "JetBrainsMono" "FiraCode"]; } )
  ];

  # Neither environment.variables or environment.sessionVariables can set these during a login session post-rebuild
  # or at least not that I've found. A relogin is required
  # We need rec to allow variables to be used in the block, apparently. See https://nix.dev/guides/best-practices#recursive-attribute-set-rec
  environment.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    EDITOR = "nvim";
    ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    COPY_UTIL = "wl-copy";
    NIXOS_OZONE_WL = "1";
    STEAM_FORCE_DESKTOPUI_SCALING = "1.6";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  environment.localBinInPath = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

