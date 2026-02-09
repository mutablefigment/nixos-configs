# Desktop home-manager configuration
{ config, inputs, ... }:
{
  imports = [
    ./vscode.nix
    ./zed.nix
    ./neovim.nix
    ./plasma.nix
    ./jailed-apps.nix
    ./browsers.nix
  ];

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.homeManager.vscode
        config.flake.modules.homeManager.zed
        config.flake.modules.homeManager.neovim
        config.flake.modules.homeManager.plasma
        config.flake.modules.homeManager.jailed-apps
        config.flake.modules.homeManager.browsers
      ];

      home.packages = with pkgs; [
        simplex-chat-desktop
        obsidian
        claude-code

        # Messaging apps (signal-desktop is in jailed-apps)
        thunderbird
        waypipe
        dino
        profanity
        toxic
      ];
    };
}
