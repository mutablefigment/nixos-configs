{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/desktop.nix
      ../../modules/firejail.nix
      ../../modules/tmux.nix
      #../../modules/yubikey-remove.nix
    ];

  # Bootloader.
   #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.fwupd.enable = true;

  boot.initrd.luks.devices."luks-3b7c710c-de60-4bf8-821f-5b35abaca637".device = "/dev/disk/by-uuid/3b7c710c-de60-4bf8-821f-5b35abaca637";

  systemd.tpm2.enable = false;
  boot.initrd.systemd.tpm2.enable = false;

  networking.hostName = "gumshoe"; # Define your hostname.

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  home-manager.backupFileExtension = "backup-home";

  environment.systemPackages = with pkgs; [
     mullvad-browser
     signal-desktop
     chromium
     colmena
     yt-dlp
     mpv
     surface-control
     rnote
     obsidian

     dracula-theme
     gnomeExtensions.tailscale-qs

     ecryptfs
     spotify
     quasselClient

     keepassxc
     ghostty
     sbctl

     anytype
     tor-browser-bundle-bin
     krita
     deskflow
  ];

    # Enable the unfree 1Password packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-gui"
    "1password"
    "code"
    "vscode"
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

  # hardware.keyboard.zsa.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services = {
    pcscd.enable = true;
    udev.packages = [
      pkgs.yubikey-personalization
      pkgs.android-udev-rules
      pkgs.zsa-udev-rules
    ];
  };

  services.tailscale = {
    enable = true;
    # this is needed for tailscale exit node functions to work
    useRoutingFeatures = "client";
  };

  # we need this option for tailscale exit node connection to work
  networking.firewall.checkReversePath = "loose";
  networking.firewall.enable = true;

  services.syncthing = {
    enable = false;
    user = "anon";
    dataDir = "/home/anon/";
  };  

  services.i2p.enable = true;

  system.stateVersion = "24.05";
}
