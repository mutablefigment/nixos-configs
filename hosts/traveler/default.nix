# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  amdgpu-stability-patch,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/desktop.nix
    ../../modules/firejail.nix
    ../../modules/tmux.nix
    ./hardware-configuration.nix

    # ./docker-compose.nix
  ];

  # Bootloader.

  boot.tmp.cleanOnBoot = true;
  #boot.plymouth.enable = true;
  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = true;

  boot.lanzaboote = {
    enable = false;
    pkiBundle = "/var/lib/sbctl";
  };

  #boot.initrd = {
  #  luks.devices."crypt-root" = {
  #    device = "/dev/disk/by-uuid/044db8a5-9b65-4350-8751-46b9e7b43b7f";
  #    crypttabExtraOpts = [ "fido2-device=auto" ];
  #  };
  #};

  boot.plymouth.enable = true;

  hardware.firmware = [ pkgs.linux-firmware ];
  services.fwupd.enable = true;

  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "quiet"
    "loglevel=3"
    "mem_encryption=on"
  ];

  systemd.services.plasma-waitforname = {
    serviceConfig.TimeoutStartSec = "10s";
    unitConfig.DefaultDependencies = false;
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."sddm".wants = [ "graphical.target" ];

  services.yggdrasil = {
    enable = true;
    group = "users";
  };

  # AMD GPU configuration without ROCm
  hardware.graphics = {
    enable = true;
  };

  # Address entropy issues for faster KDE startup
  services.haveged.enable = true;

  # Bluetooth configuration to prevent waiting
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Prevent startup delays
  };

  # Network optimization
  systemd.services.NetworkManager-wait-online.enable = false;

  # Disable splash screen for faster startup
  services.displayManager.sddm.settings = {
    Theme = {
      Current = "breeze";
    };
  };

  # Cross compilation for arm devices
  # nixpkgs.buildPlatform.system = "aarch64-linux";
  # nixpkgs.hostPlatform.system = "x86_64-linux";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Power management for laptops
  services.power-profiles-daemon.enable = true;

  networking.hostName = "traveler"; # Define your hostname.
  networking.hostId = "53cbda52";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager = {
    enable = true;
    #enableStrongSwan = true;
    plugins = with pkgs; [
      networkmanager-l2tp
      networkmanager-strongswan
    ];
  };

  services.strongswan = {
    enable = true;
    secrets = [
      "ipsec.d/ipsec.nm-l2tp.secrets"
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  home-manager.backupFileExtension = "backup-home";

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.anon = {
    isNormalUser = true;
    description = "anon";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      _1password-gui
      _1password-cli
      thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    mullvad-browser
    signal-desktop
    chromium
    colmena
    yt-dlp
    mpv
    surface-control
    rnote
    obsidian
    sbctl

    ecryptfs
    spotify
    deskflow
    quasselClient

    keepassxc
    ghostty
    sbctl

    anytype
    tor-browser-bundle-bin

    lact
    element-desktop
    corectrl
    iamb
    discord
    wasistlos

    # Gnome stuff
    tokyonight-gtk-theme

    gnomeExtensions.tailscale-qs
    gnomeExtensions.user-themes
    gnome-tweaks

    pulseview
    arion

    nil
    nixd
  ];

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = false;
  virtualisation.podman.dockerSocket.enable = true;

  # King logic analysis toolsudev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a1", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a2", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a3", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a4", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="02a1", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="02a2", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="02a3", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="03a1", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="03a2", MODE="0666"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="03a3", MODE="0666"
  '';

  # Enable the unfree 1Password packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-gui"
      "1password"
    ];
  # Alternatively, you could also just allow all unfree packages
  # nixpkgs.config.allowUnfree = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "anon" ];
  };

  environment.variables = {
    SSH_AUTH_SOCK = "/home/anon/.1password/agent.sock";
    SSH_AUTH_SOCKET = "/home/anon/.1password/agent.sock";
  };

  services.tailscale = {
    enable = true;
    # this is needed for tailscale exit node functions to work
    useRoutingFeatures = "client";
  };

  # we need this option for tailscale exit node connection to work
  networking.firewall.checkReversePath = "loose";
  networking.firewall.enable = true;

  system.stateVersion = "25.05";
}
