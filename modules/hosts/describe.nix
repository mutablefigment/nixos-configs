# Describe host configuration
{ config, inputs, ... }:
{
  configurations.nixos.describe.module =
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
      boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/904b053b-39e0-42ee-ba05-672a9832f0d3";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-d744045d-9b30-4238-8a26-1fec221c706e".device = "/dev/disk/by-uuid/d744045d-9b30-4238-8a26-1fec221c706e";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/425D-F315";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/246d857a-798a-4f23-90bc-a1606acc8d31"; }
      ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

      # Boot configuration
      boot.tmp.cleanOnBoot = true;
      boot.loader.systemd-boot.enable = true;
      boot.lanzaboote = {
        enable = false;
        pkiBundle = "/var/lib/sbctl";
      };
      boot.plymouth.enable = true;
      boot.supportedFilesystems = [ "zfs" ];

      boot.initrd.luks.devices."luks-5bb6fe24-6aeb-4233-af1a-6edb1880b9f5".device =
        "/dev/disk/by-uuid/5bb6fe24-6aeb-4233-af1a-6edb1880b9f5";

      networking.hostName = "describe";
      networking.networkmanager.enable = true;
      networking.hostId = "5c00c7a2";

      time.timeZone = "Europe/Berlin";

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      environment.systemPackages = with pkgs; [
        vim
        wget
        git
        nixd
        nil
        mullvad-browser
        tor-browser
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
        bazel
        zig
        go
        keymapp
        discord
        jetbrains-toolbox
        bitwarden-desktop
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

      services.udev.packages = [ pkgs.zsa-udev-rules ];

      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "onepassword-password-manager"
          "1password-gui"
          "1password"
          "steam"
          "steam-original"
          "steam-unwrapped"
          "steam-run"
        ];
      nixpkgs.config.allowUnfree = true;

      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "anon" ];
      };

      security.polkit.enable = true;
      home-manager.backupFileExtension = "backup-home";

      environment.variables = {
        SSH_AUTH_SOCK = "/home/anon/.1password/agent.sock";
        SSH_AUTH_SOCKET = "/home/anon/.1password/agent.sock";
      };

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
      };

      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          experimental = true;
          iptables = true;
        };
      };

      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      networking.firewall.enable = true;
      networking.firewall.checkReversePath = "loose";
      networking.nftables.enable = true;

      services.openssh.enable = true;
      services.i2p.enable = true;

      networking.networkmanager.plugins = with pkgs; [
        networkmanager-fortisslvpn
        networkmanager-l2tp
        networkmanager-openvpn
      ];

      programs.nm-applet.enable = true;

      services.strongswan.enable = true;
      environment.etc."strongswan.conf".text = "";

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      services.ollama = {
        enable = true;
        loadModels = [
          "qwen3-coder:latest"
          "gpt-oss:latest"
        ];
      };

      system.stateVersion = "25.05";
    };
}
