# Applications (jailing disabled due to issues)
{ inputs, ... }:
{
  flake.modules.homeManager.jailed-apps =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        spotify
        discord
        signal-desktop
      ];
    };
}
