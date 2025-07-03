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
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.plymouth.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd = {
    luks.devices."root" = {
      device = "/dev/disk/by-uuid/29525d36-20a5-4c0a-bcc1-5561385c2936";
      crypttabExtraOpts = [ "fido2-device=auto" ];
    };
  };
  networking.hostName = "describe"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.hostId = "5c00c7a2";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git

    nixd
    nil

    mullvad-browser
    tor-browser-bundle-bin
  ];

  # Enable the unfree 1Password packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-gui"
      "1password"
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

  environment.variables = {
    SSH_AUTH_SOCK = "/home/anon/.1password/agent.sock";
    SSH_AUTH_SOCKET = "/home/anon/.1password/agent.sock";
  };

  services.tailscale = {
    enable = true;
    # this is needed for tailscale exit node functions to work
    useRoutingFeatures = "client";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
