# Example MicroVM configuration
# This demonstrates how to define a MicroVM that runs on the watchtower host
{ config, lib, pkgs, ... }:

{
  # Define MicroVMs to run on this host
  microvm.vms = {
    # Example: A simple web server MicroVM
    example-vm = {
      # Use the same pkgs as the host
      pkgs = pkgs;

      config = {
        networking.hostName = "example-vm";

        # Share the host's nix store (recommended for faster builds and smaller images)
        microvm.shares = [{
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "ro-store";
          proto = "virtiofs";
        }];

        # Writable persistent storage for /var
        microvm.volumes = [{
          mountPoint = "/var";
          image = "var.img";
          size = 1024; # 1GB
        }];

        # Network interface - will be attached to microvm-br bridge
        microvm.interfaces = [{
          type = "tap";
          id = "vm-example";
          mac = "02:00:00:00:00:01";
        }];

        # Hypervisor selection
        # Options: qemu, cloud-hypervisor, firecracker, crosvm, kvmtool, stratovirt
        microvm.hypervisor = "qemu";

        # Resource allocation
        microvm.mem = 512;  # RAM in MB
        microvm.vcpu = 2;   # Number of virtual CPUs

        # Enable systemd-networkd for DHCP
        networking.useNetworkd = true;
        systemd.network.enable = true;
        systemd.network.networks."20-lan" = {
          matchConfig.Type = "ether";
          networkConfig = {
            DHCP = "yes";
          };
        };

        # Example service: nginx
        # services.nginx = {
        #   enable = true;
        #   virtualHosts."default" = {
        #     root = "/var/www";
        #   };
        # };

        # Allow SSH access
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };

        # Set a root password for testing (change this!)
        users.users.root.initialPassword = "microvm";

        system.stateVersion = "24.11";
      };
    };

    # Add more MicroVMs here following the same pattern:
    #
    # database = {
    #   config = {
    #     networking.hostName = "database";
    #     microvm.hypervisor = "qemu";
    #     microvm.mem = 1024;
    #     microvm.vcpu = 2;
    #     # ... rest of config
    #   };
    # };
  };
}
