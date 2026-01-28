# Hardened security profile for NixOS hosts
# This module can be optionally imported by hosts for enhanced security
{ config, inputs, ... }:
{
  flake.modules.nixos.hardened =
    { pkgs, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/profiles/hardened.nix")
        config.flake.modules.nixos.hardened-extended
      ];

      # Use the hardened kernel (overrides profile default, hosts can use mkForce to override)
      boot.kernelPackages = lib.mkOverride 90 pkgs.linuxPackages_hardened;

      # Use GrapheneOS hardened_malloc instead of scudo
      environment.memoryAllocator.provider = lib.mkForce "graphene-hardened";

      # Override settings that may break common functionality
      # Allow user namespaces for containers (Docker, Podman, etc.)
      security.unprivilegedUsernsClone = true;

      # Allow loading kernel modules at runtime (needed for hardware drivers)
      security.lockKernelModules = false;
    };
}
