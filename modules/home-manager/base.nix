# Base home-manager configuration (shared across all users)
{ config, inputs, ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.home-manager.enable = true;
      services.lorri.enable = true;

      # Base packages available everywhere
      home.packages = with pkgs; [
        age-plugin-yubikey
        rage
        wl-clipboard-rs
      ];
    };
}
