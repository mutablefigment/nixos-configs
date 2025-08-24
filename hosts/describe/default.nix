# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/desktop.nix
    ../../modules/firejail.nix
    ../../modules/tmux.nix
  ];

  boot.tmp.cleanOnBoot = true;
  boot.loader.systemd-boot.enable = true; #lib.mkForce false;

  boot.lanzaboote = {
    enable = false;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.plymouth.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  #boot.initrd = {
  #  luks.devices."root" = {
  #    device = "/dev/disk/by-uuid/29525d36-20a5-4c0a-bcc1-5561385c2936";
  #    crypttabExtraOpts = [ "fido2-device=auto" ];
  #  };
  #};
  networking.hostName = "describe"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostId = "5c00c7a2";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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

  environment.systemPackages = with pkgs; [
    vim
    wget
    git

    nixd
    nil

    mullvad-browser
    tor-browser-bundle-bin

    numix-solarized-gtk-theme
    solarc-gtk-theme
    tokyonight-gtk-theme
    zuki-themes
    gnome-tweaks
    gnome-extension-manager

    gnomeExtensions.zen
    gnomeExtensions.user-themes

    docker-compose

    spotify
    anytype

    bazel
    zig
    go
    keymapp
  ];

  programs.dconf.profiles.user.databases = [
    { 
      settings = { 
        "org/gnome/mutter" = {
          experimental-features = [
            "scale-monitor-framebuffer"
            "variable-refresh-rate"
            "xwayland-native-scaling"
          ];
        };
      };
    }
  ];

  services = {
    udev.packages = [
      pkgs.zsa-udev-rules
    ];
  };


  # Enable the unfree 1Password packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-gui"
      "1password"
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];
  # Alternatively, you could also just allow all unfree packages
  nixpkgs.config.allowUnfree = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "anon" ];
  };

  home-manager.backupFileExtension = "backup-home";

  environment.variables = {
    SSH_AUTH_SOCK = "/home/anon/.1password/agent.sock";
    SSH_AUTH_SOCKET = "/home/anon/.1password/agent.sock";
  };

  services.tailscale = {
    enable = true;
    # this is needed for tailscale exit node functions to work
    useRoutingFeatures = "client";
  };

  # virtualisation.podman = {
  #   enable = true;
  #   autoPrune.enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enable = true;
  # };
  virtualisation.docker = {
    enable = true;
    # Set up resource limits
    daemon.settings = {
      experimental = true;
      iptables = true;
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # NixOS firewall + forwarding settings commonly needed for Docker
  networking.firewall.enable = true;
  # Docker often needs reverse path filtering relaxed for container NAT
  networking.firewall.checkReversePath = "loose";

  # If you use nftables (default on recent NixOS), this is fine with Docker
  networking.nftables.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


  services.i2p.enable = true;

    # Enable networking
  networking.networkmanager = {
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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.ollama = {
    enable = true;
    #acceleration = "rocm";
    loadModels = [
      "qwen3-coder:latest"
      "gpt-oss:latest"
    ];
  };

  system.stateVersion = "25.05";
}
