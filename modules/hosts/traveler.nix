# Traveler host configuration (ThinkPad Z13 laptop)
{ config, inputs, ... }:
{
  configurations.nixos.traveler.module =
    { pkgs, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z13-gen1
      ] ++ (with config.flake.modules.nixos; [
        base
        desktop
      ]);

      # Hardware configuration
      boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/b8450900-bf03-4466-9ba3-71ac3f4ec4b2";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

      boot.initrd.luks.devices."luks-afaf17dd-1313-4a5c-850b-42ab4a00e34a".device = "/dev/disk/by-uuid/afaf17dd-1313-4a5c-850b-42ab4a00e34a";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/C8A5-6BC3";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      swapDevices = [ ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

      # Boot configuration
      boot.tmp.cleanOnBoot = true;
      boot.loader.systemd-boot.enable = true;
      boot.lanzaboote = {
        enable = false;
        pkiBundle = "/var/lib/sbctl";
      };
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

      systemd.services.plasma-waitforname.serviceConfig.TimeoutStartSec = "10s";

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
            user = "greeter";
          };
        };
      };

      systemd.services."getty@tty1".enable = false;
      systemd.services."sddm".wants = [ "graphical.target" ];

      services.yggdrasil = {
        enable = true;
        group = "users";
      };

      hardware.graphics.enable = true;
      services.haveged.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      systemd.services.NetworkManager-wait-online.enable = false;

      services.displayManager.sddm.settings = {
        Theme = {
          Current = "breeze";
        };
      };

      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      services.power-profiles-daemon.enable = true;

      networking.hostName = "traveler";
      networking.hostId = "53cbda52";

      networking.networkmanager = {
        enable = true;
        plugins = with pkgs; [
          networkmanager-l2tp
          networkmanager-strongswan
        ];
      };

      services.strongswan = {
        enable = true;
        secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
      };

      time.timeZone = "Europe/Berlin";
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

      services.xserver.xkb.variant = "";
      home-manager.backupFileExtension = "backup-home";
      services.printing.enable = true;

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.libinput.enable = true;

      users.users.anon = {
        isNormalUser = true;
        description = "anon";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
          kdePackages.kate
          _1password-gui
          _1password-cli
          thunderbird
        ];
      };

      programs.firefox.enable = true;
      programs.nm-applet.enable = true;

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        vim
        wget
        curl
        mullvad-browser
        signal-desktop
        ungoogled-chromium
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
        tor-browser
        lact
        element-desktop
        corectrl
        iamb
        discord
        wasistlos
        tokyonight-gtk-theme
        gnomeExtensions.tailscale-qs
        gnomeExtensions.user-themes
        gnome-tweaks
        pulseview
        arion
        nil
        nixd
        xwayland-satellite
      ];

      virtualisation.docker.enable = true;
      virtualisation.podman.enable = false;
      virtualisation.podman.dockerSocket.enable = true;

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

      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "1password-gui"
          "1password"
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

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
      };

      networking.firewall.checkReversePath = "loose";
      networking.firewall.enable = true;

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      system.stateVersion = "25.05";
    };
}
