# Mountain server host configuration (homelab server with Proxmox)
{ config, inputs, ... }:
{
  configurations.nixos.mountain.module =
    { pkgs, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.proxmox-nixos.nixosModules.proxmox-ve
        config.flake.modules.nixos.base
      ];

      # Hardware configuration
      boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" "e1000e" "igb" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/8976cfe8-7644-49e7-9848-a99929004d87";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-98f28586-41d3-4974-bfef-3c1519da0e1f".device = "/dev/disk/by-uuid/98f28586-41d3-4974-bfef-3c1519da0e1f";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/6D81-6FE6";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/03b59027-1711-4138-ba88-c8261cac343d"; }
      ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

      # Bootloader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.supportedFilesystems = [ "bcachefs" ];

      boot.initrd.network = {
        enable = false;
        udhcpc.enable = true;
        flushBeforeStage2 = true;
        ssh = {
          enable = false;
          port = 22;
          authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOU+iWnGXqMpNj5wZOXN7/IpEz7Cavarzs2rM7RS/aq" ];
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        };
        postCommands = ''
          echo 'cryptsetup-askpass || echo "Unlock was successful; exiting SSH session" && exit 1' >> /root/.profile
        '';
      };

      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.binfmt.emulatedSystems = [
        "armv6l-linux"
        "armv7l-linux"
      ];

      virtualisation.docker.enable = true;

      networking.hostName = "mountain";
      networking.networkmanager.enable = true;

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        helix
      ];

      users.users.${config.meta.owner.username}.openssh.authorizedKeys.keyFiles = [ config.meta.sshKeysPath ];

      services.openssh.enable = true;
      services.openssh.settings.AcceptEnv = lib.mkForce [ "LANG" "LC_*" ];
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "both";
      };

      system.autoUpgrade = {
        enable = true;
        flake = "github:mutablefigment/nixos-configs#mountain";
        dates = "daily";
        randomizedDelaySec = "1h";
        allowReboot = false;
      };

      networking.firewall.enable = true;
      networking.firewall.trustedInterfaces = [ "incusbr0" ];

      # Proxmox configuration
      services.proxmox-ve = {
        enable = true;
        ipAddress = "192.168.176.156";
      };

      nixpkgs.overlays = [
        inputs.proxmox-nixos.overlays.x86_64-linux
      ];

      system.stateVersion = "25.05";
    };
}
