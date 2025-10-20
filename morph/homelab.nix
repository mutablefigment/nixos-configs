# Morph deployment configuration for homelab
# Deploy with: nix run github:DBCDK/morph -- deploy ./morph/homelab.nix
{
  network = {
    description = "Homelab NixOS Network";
    ordering = {
      # Deploy in this order: servers first, then desktops
      tags = [ "server" "desktop" "laptop" ];
    };
  };

  # Desktop workstation
  describe = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "describe.local"; # or use IP address like "192.168.1.10"
      targetUser = "root";
      tags = [ "desktop" ];
      
      # Healthchecks - morph will verify these after deployment
      healthChecks = {
        systemd = {
          enable = true;
        };
      };
    };

    # Import the actual system configuration from your flake
    imports = [
      ../hosts/describe
      ../modules/system.nix
      ../modules/desktop.nix
      ../modules/firejail.nix
      ../modules/tmux.nix
    ];
  };

  # Main desktop/workstation
  gumshoe = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "gumshoe.local"; # or IP address
      targetUser = "root";
      tags = [ "desktop" ];
      
      healthChecks = {
        systemd = {
          enable = true;
        };
      };
    };

    imports = [
      ../hosts/gumshoe
    ];
  };

  # Laptop
  traveler = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "traveler.local"; # or IP address
      targetUser = "root";
      tags = [ "laptop" ];
      
      healthChecks = {
        systemd = {
          enable = true;
        };
      };
    };

    imports = [
      ../hosts/traveler
    ];
  };

  # Server
  pve = { config, pkgs, lib, ... }: {
    deployment = {
      targetHost = "pve.local"; # or IP address
      targetUser = "root";
      tags = [ "server" ];
      
      healthChecks = {
        systemd = {
          enable = true;
        };
      };
    };

    imports = [
      ../hosts/pve
    ];
  };
}
