# Base system configuration shared across all NixOS hosts
{ config, inputs, ... }:
{
  flake.modules.nixos.base =
    { pkgs, lib, ... }:
    {
      imports = [
        config.flake.modules.nixos.hardened
      ];

      # Time zone
      time.timeZone = "Europe/Berlin";

      # Localization
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };

      # Security
      security.rtkit.enable = true;

      # Shell configuration
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;
      users.users.root.ignoreShellProgramCheck = true;

      # Primary user
      users.users.${config.meta.owner.username} = {
        isNormalUser = true;
        shell = pkgs.nushell;
        description = config.meta.owner.username;
        ignoreShellProgramCheck = true;
        extraGroups = [
          "networkmanager"
          "wheel"
          "signald"
          "docker"
          "libvirtd"
          "qemu-libvirtd"
          "disk"
          "dialout"
          "plugdev"
          "podman"
          "incus-admin"
        ];
        openssh.authorizedKeys.keyFiles = [ config.meta.sshKeysPath ];
      };

      # Nix settings
      nixpkgs.config.allowUnfree = true;
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        distributedBuilds = true;
      };

      # OpenSSH
      # services.openssh.enable = true;
    };
}
