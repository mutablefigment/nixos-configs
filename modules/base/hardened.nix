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

      # Override settings that may break common functionality
      # Allow user namespaces for containers (Docker, Podman, etc.)
      security.unprivilegedUsernsClone = true;

      # Allow loading kernel modules at runtime (needed for hardware drivers)
      security.lockKernelModules = false;
    };
}
