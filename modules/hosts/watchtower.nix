# Watchtower host configuration (desktop workstation with microvm support)
{ config, inputs, ... }:
{
  configurations.nixos.watchtower.module =
    {
      pkgs,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.microvm.nixosModules.host
      ]
      ++ (with config.flake.modules.nixos; [
        base
        desktop
        microvm-host
        isolated-containers
      ]);

      # Hardware configuration
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      boot.initrd.luks.devices."luks-dcc62daf-e1d4-4368-a928-ab8c4e265a6d".device =
        "/dev/disk/by-uuid/dcc62daf-e1d4-4368-a928-ab8c4e265a6d";

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/ec88757a-1a29-47e8-8245-820c6d9a89e0";
        fsType = "ext4";
      };

      boot.kernelPackages = pkgs.linuxPackages_zen;
      boot.initrd.luks.devices."luks-37c63ff8-6890-4973-96f1-0b84a81f656b".device =
        "/dev/disk/by-uuid/37c63ff8-6890-4973-96f1-0b84a81f656b";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/C561-D936";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/b53b70e5-0166-46c4-a31d-95514c95b8fe"; }
      ];

      # networking.useDHCP = lib.mkDefault true;
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
      boot.supportedFilesystems = [ "zfs" ];

      networking.hostName = "watchtower";
      # networking.networkmanager.enable = true;
      networking.hostId = "5cddc8a2";

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
        wasistlos
        jetbrains-toolbox
        bitwarden-desktop
        libreoffice
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

      networking.firewall.enable = false;
      networking.firewall.checkReversePath = "loose";
      networking.nftables.enable = true;

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

      programs.mosh = {
        enable = true;
        withUtempter = true;
      };

      services.i2p.enable = true;

      networking.networkmanager.plugins = with pkgs; [
        networkmanager-fortisslvpn
        networkmanager-l2tp
        networkmanager-openvpn
      ];

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

      # Isolated GUI Containers (Qubes-like application isolation)
      isolatedContainers = {
        enable = true;
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJoSMoV6RY2ol56IBuiZ6cY7zuqgz1PxoD0s5r7qETN anon@watchtower";

        containers = {
          # Firefox browsing container (persistent for bookmarks/history)
          firefox-vm = {
            address = "10.99.0.10";
            ephemeral = false;
            enableGpu = true;
            packages = with pkgs; [
              firefox
              xdg-utils
              ffmpeg
            ];
          };

          # Banking/sensitive sites container (ephemeral for security)
          banking-vm = {
            address = "10.99.0.11";
            ephemeral = true;
            enableGpu = true;
            packages = with pkgs; [
              chromium
              xdg-utils
            ];
            extraConfig = {
              networking.firewall.enable = true;
            };
          };

          # Development container (persistent for projects/configs)
          dev-vm = {
            address = "10.99.0.12";
            ephemeral = false;
            enableGpu = true;
            packages = with pkgs; [
              (writeShellScriptBin "code" ''
                unset NIXOS_OZONE_WL
                exec ${vscode}/bin/code --ozone-platform=wayland --disable-gpu-sandbox "$@"
              '')
              vscode
              neovim
              git
              gh
              direnv
              nodejs
              python3
              go
              rustup
              kitty
              tmux
              ripgrep
              fd
              jq
              curl
              wget
            ];
          };

          # Untrusted/experimental software container (ephemeral)
          sandbox-vm = {
            address = "10.99.0.13";
            ephemeral = true;
            enableGpu = true;
            packages = with pkgs; [
              firefox
              file
              binutils
              strace
            ];
          };

          # Communication apps container (persistent)
          comms-vm = {
            address = "10.99.0.14";
            ephemeral = false;
            enableGpu = true;
            packages = with pkgs; [
              firefox
            ];
          };
        };
      };

      system.stateVersion = "25.05";
    };
}
