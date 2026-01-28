# Installer ISO configuration
{ config, inputs, ... }:
{
  configurations.nixos.installer.module =
    { pkgs, lib, modulesPath, ... }:
    {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        inputs.disko.nixosModules.disko
      ];

      nixpkgs.hostPlatform = "x86_64-linux";

      # ISO configuration
      isoImage.makeEfiBootable = true;
      isoImage.makeUsbBootable = true;
      isoImage.squashfsCompression = "zstd -Xcompression-level 6";

      # Add dm-verity support to initrd
      boot.initrd.kernelModules = [ "dm-verity" "dm-mod" ];
      boot.initrd.availableKernelModules = [ "dm-verity" ];

      # Auto-login as nixos user for convenience
      services.getty.autologinUser = lib.mkForce "nixos";

      # Enable SSH for remote installation
      services.openssh.enable = true;
      services.openssh.settings.PermitRootLogin = "yes";

      # Add necessary packages for installation
      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        curl
        parted
        gptfdisk
        zfs
        cryptsetup
      ];

      # Enable flakes in the live environment
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      system.stateVersion = "24.05";
    };
}
