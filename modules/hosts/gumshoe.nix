# Gumshoe host configuration
{ config, inputs, ... }:
{
  configurations.nixos.gumshoe.module =
    { pkgs, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.lanzaboote.nixosModules.lanzaboote
      ] ++ (with config.flake.modules.nixos; [
        base
        desktop
      ]);

      # Hardware configuration
      boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/de08ccae-9a54-4b63-8d0d-030f8cb90e26";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-a98b4aa5-a27a-496f-bc03-aad8842f5a66".device = "/dev/disk/by-uuid/a98b4aa5-a27a-496f-bc03-aad8842f5a66";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/347E-03FF";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/8b436cee-2e59-4280-85e3-3112814a8416"; }
      ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

      # Bootloader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      services.fwupd.enable = true;

      boot.initrd.luks.devices."luks-3b7c710c-de60-4bf8-821f-5b35abaca637".device =
        "/dev/disk/by-uuid/3b7c710c-de60-4bf8-821f-5b35abaca637";

      systemd.tpm2.enable = false;
      boot.initrd.systemd.tpm2.enable = false;

      networking.hostName = "gumshoe";

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
        tor-browser
        krita
        deskflow
      ];

      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "1password-gui"
          "1password"
          "code"
          "vscode"
        ];

      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "anon" ];
      };

      environment.variables = {
        SSH_AUTH_SOCK = "/home/anon/.1password/agent.sock";
        SSH_AUTH_SOCKET = "/home/anon/.1password/agent.sock";
      };

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
        useRoutingFeatures = "client";
      };

      networking.firewall.checkReversePath = "loose";
      networking.firewall.enable = true;

      services.syncthing = {
        enable = false;
        user = "anon";
        dataDir = "/home/anon/";
      };

      services.i2p.enable = true;

      system.stateVersion = "24.05";
    };
}
