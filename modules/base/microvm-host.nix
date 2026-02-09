# MicroVM host configuration as a flake-parts module
{ inputs, ... }:
{
  flake.modules.nixos.microvm-host =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      # Use systemd-networkd for network management
      networking.useNetworkd = true;
      systemd.network.enable = true;

      # Create a bridge for MicroVM networking
      systemd.network.netdevs."10-microvm-br" = {
        netdevConfig = {
          Name = "microvm-br";
          Kind = "bridge";
        };
      };

      # Configure the bridge with a static IP
      systemd.network.networks."10-microvm-bridge" = {
        matchConfig.Name = "microvm-br";
        networkConfig = {
          Address = "10.10.0.1/24";
          DHCPServer = true;
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "no";
        dhcpServerConfig = {
          PoolOffset = 10;
          PoolSize = 200;
          EmitDNS = true;
          DNS = "10.10.0.1";
        };
      };

      # Attach MicroVM TAP interfaces to the bridge
      systemd.network.networks."11-microvm-tap" = {
        matchConfig.Name = "vm-*";
        networkConfig = {
          Bridge = "microvm-br";
        };
        linkConfig.RequiredForOnline = "no";
      };

      # Exclude Docker veth interfaces from systemd-networkd management
      systemd.network.networks."09-docker" = {
        matchConfig.Name = "veth*";
        linkConfig = {
          Unmanaged = true;
        };
      };

      # Enable NAT for MicroVM internet access
      networking.nat = {
        enable = true;
        internalInterfaces = [ "microvm-br" ];
      };

      # Allow traffic on the bridge
      networking.firewall.trustedInterfaces = [ "microvm-br" ];
    };
}
