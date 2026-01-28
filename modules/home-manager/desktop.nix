# Desktop home-manager configuration
{ config, inputs, ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        simplex-chat-desktop
        obsidian
        claude-code
      ];
    };
}
