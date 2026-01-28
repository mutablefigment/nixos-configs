# Isolated GUI Containers Module - flake-parts version
# Provides Qubes-like application isolation using NixOS containers (systemd-nspawn)
# with Wayland forwarding via waypipe for GUI applications
{ ... }:
{
  flake.modules.nixos.isolated-containers =
    { config, lib, pkgs, ... }:
    let
      cfg = config.isolatedContainers;

      # Base network for containers: 10.99.0.0/24
      hostAddress = "10.99.0.1";
      sshPubKey = cfg.sshPublicKey;

      # Generate container configuration from simplified options
      mkContainerConfig = name: containerCfg: let
        containerUser = containerCfg.user or "user";
        containerUid = containerCfg.uid or 1000;
        homeDir = "/home/${containerUser}";
        persistPath = "/var/lib/isolated-containers/${name}";
      in {
        autoStart = containerCfg.autoStart or false;
        ephemeral = containerCfg.ephemeral or false;
        privateNetwork = true;
        hostAddress = hostAddress;
        localAddress = containerCfg.address;

        bindMounts = {
          "/run/user/${toString containerUid}/pulse" = {
            hostPath = "/run/user/1000/pulse";
            isReadOnly = false;
          };
          "/run/user/${toString containerUid}/pipewire-0" = {
            hostPath = "/run/user/1000/pipewire-0";
            isReadOnly = false;
          };
        } // lib.optionalAttrs (containerCfg.enableGpu or true) {
          "/dev/dri" = {
            hostPath = "/dev/dri";
            isReadOnly = false;
          };
        } // lib.optionalAttrs (!(containerCfg.ephemeral or false)) {
          "${homeDir}" = {
            hostPath = "${persistPath}/home";
            isReadOnly = false;
          };
        } // (containerCfg.extraBindMounts or {});

        allowedDevices = lib.optionals (containerCfg.enableGpu or true) [
          { modifier = "rw"; node = "/dev/dri/card0"; }
          { modifier = "rw"; node = "/dev/dri/card1"; }
          { modifier = "rw"; node = "/dev/dri/renderD128"; }
          { modifier = "rw"; node = "/dev/dri/renderD129"; }
        ];

        config = { config, pkgs, lib, ... }: lib.mkMerge [
          {
            system.stateVersion = "24.11";
            networking.useHostResolvConf = lib.mkForce false;
            services.resolved.enable = true;

            environment.variables = {
              XDG_RUNTIME_DIR = "/run/user/${toString containerUid}";
              PULSE_SERVER = "unix:/run/user/${toString containerUid}/pulse/native";
              NIXOS_OZONE_WL = "1";
              ELECTRON_OZONE_PLATFORM_HINT = "wayland";
            };

            environment.systemPackages = with pkgs; [
              coreutils
              bashInteractive
              waypipe
              mesa
              mesa.drivers
              mesa-demos
              vulkan-tools
              pciutils
              fontconfig
              dejavu_fonts
              liberation_ttf
              adwaita-icon-theme
            ] ++ (containerCfg.packages or []);

            fonts.packages = with pkgs; [
              dejavu_fonts
              liberation_ttf
              noto-fonts
            ];

            users.users.${containerUser} = {
              isNormalUser = true;
              uid = containerUid;
              home = homeDir;
              createHome = true;
              group = "users";
              extraGroups = [ "video" "render" "audio" ];
              openssh.authorizedKeys.keys = lib.optional (sshPubKey != null) sshPubKey;
            };

            services.openssh = {
              enable = true;
              startWhenNeeded = false;
              settings = {
                PermitRootLogin = "no";
                PasswordAuthentication = false;
              };
            };

            systemd.tmpfiles.rules = [
              "d /run/user/${toString containerUid} 0700 ${containerUser} users -"
              "f ${homeDir}/.config/code-flags.conf 0644 ${containerUser} users - --ozone-platform=wayland"
              "f ${homeDir}/.config/chromium-flags.conf 0644 ${containerUser} users - --ozone-platform=wayland"
              "f ${homeDir}/.config/electron-flags.conf 0644 ${containerUser} users - --ozone-platform=wayland"
            ];

            environment.etc."xdg/electron-flags.conf".text = "--ozone-platform=wayland";
            environment.etc."xdg/chromium-flags.conf".text = "--ozone-platform=wayland";
            environment.etc."xdg/code-flags.conf".text = "--ozone-platform=wayland";

            hardware.graphics = {
              enable = true;
              enable32Bit = true;
              extraPackages = with pkgs; [ libva libva-utils vulkan-loader ];
            };

            networking.firewall = {
              enable = true;
              allowedTCPPorts = [ 22 ];
              trustedInterfaces = [ "eth0" ];
            };

            security.polkit.enable = true;
          }
          (containerCfg.extraConfig or {})
        ];
      };

    in {
      options.isolatedContainers = {
        enable = lib.mkEnableOption "isolated GUI containers";

        sshKeyFile = lib.mkOption {
          type = lib.types.str;
          default = "/home/anon/.ssh/id_ed25519";
          description = "SSH private key file to use for connecting to containers";
        };

        sshPublicKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "SSH public key to authorize in containers";
        };

        containers = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              address = lib.mkOption {
                type = lib.types.str;
                description = "Container IP address";
              };
              packages = lib.mkOption {
                type = lib.types.listOf lib.types.package;
                default = [];
              };
              ephemeral = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
              autoStart = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
              enableGpu = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };
              user = lib.mkOption {
                type = lib.types.str;
                default = "user";
              };
              uid = lib.mkOption {
                type = lib.types.int;
                default = 1000;
              };
              extraBindMounts = lib.mkOption {
                type = lib.types.attrsOf lib.types.attrs;
                default = {};
              };
              extraConfig = lib.mkOption {
                type = lib.types.attrs;
                default = {};
              };
            };
          });
          default = {};
        };
      };

      config = lib.mkIf cfg.enable {
        containers = lib.mapAttrs mkContainerConfig cfg.containers;

        systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (name: containerCfg:
          lib.optionals (!(containerCfg.ephemeral or false)) [
            "d /var/lib/isolated-containers/${name} 0755 root root -"
            "d /var/lib/isolated-containers/${name}/home 0700 1000 users -"
          ]
        ) cfg.containers);

        systemd.network.netdevs."20-container-br" = {
          netdevConfig = {
            Name = "container-br";
            Kind = "bridge";
          };
        };

        systemd.network.networks."20-container-br" = {
          matchConfig.Name = "container-br";
          networkConfig = {
            Address = "${hostAddress}/24";
            ConfigureWithoutCarrier = true;
          };
          linkConfig.RequiredForOnline = "no";
        };

        systemd.network.networks."21-container-veth" = {
          matchConfig.Name = "ve-*";
          linkConfig = {
            RequiredForOnline = "no";
            Unmanaged = true;
          };
        };

        networking.nat = {
          enable = true;
          internalIPs = [ "10.99.0.0/24" ];
        };

        networking.localCommands = ''
          ip rule add to 10.99.0.0/24 lookup main priority 5200 2>/dev/null || true
        '';

        networking.firewall = {
          trustedInterfaces = [ "container-br" "ve-+" ];
          extraInputRules = ''
            iifname "ve-*" accept
          '';
          extraForwardRules = ''
            iifname "ve-*" accept
            oifname "ve-*" accept
          '';
        };

        environment.systemPackages = [
          pkgs.waypipe

          (pkgs.writeShellScriptBin "container-run" ''
            set -e
            if [ $# -lt 2 ]; then
              echo "Usage: container-run <container-name> <command> [args...]"
              exit 1
            fi
            CONTAINER="$1"
            shift
            case "$CONTAINER" in
              firefox-vm) CONTAINER_IP="10.99.0.10" ;;
              banking-vm) CONTAINER_IP="10.99.0.11" ;;
              dev-vm) CONTAINER_IP="10.99.0.12" ;;
              sandbox-vm) CONTAINER_IP="10.99.0.13" ;;
              comms-vm) CONTAINER_IP="10.99.0.14" ;;
              *) echo "Unknown container: $CONTAINER"; exit 1 ;;
            esac
            if ! machinectl status "$CONTAINER" &>/dev/null; then
              sudo machinectl start "$CONTAINER"
              sleep 3
            fi
            SSH_KEY="${cfg.sshKeyFile}"
            exec ${pkgs.waypipe}/bin/waypipe --compress lz4 \
              ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR \
              user@"$CONTAINER_IP" "$@"
          '')

          (pkgs.writeShellScriptBin "container-shell" ''
            set -e
            if [ $# -lt 1 ]; then
              echo "Usage: container-shell <container-name>"
              exit 1
            fi
            CONTAINER="$1"
            if ! machinectl status "$CONTAINER" &>/dev/null; then
              sudo machinectl start "$CONTAINER"
              sleep 2
            fi
            sudo machinectl shell user@"$CONTAINER"
          '')

          (pkgs.writeShellScriptBin "container-start" ''
            if [ $# -lt 1 ]; then echo "Usage: container-start <container-name>"; exit 1; fi
            sudo machinectl start "$1"
          '')

          (pkgs.writeShellScriptBin "container-stop" ''
            if [ $# -lt 1 ]; then echo "Usage: container-stop <container-name>"; exit 1; fi
            sudo machinectl stop "$1"
          '')

          (pkgs.writeShellScriptBin "container-list" ''
            echo "Isolated Containers:"
            machinectl list
          '')
        ];
      };
    };
}
