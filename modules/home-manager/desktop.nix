# Desktop home-manager configuration
{ config, inputs, ... }:
{
  imports = [
    ./vscode.nix
    ./zed.nix
    ./emacs.nix
    ./neovim.nix
    ./plasma.nix
  ];

  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      imports = [
        config.flake.modules.homeManager.vscode
        config.flake.modules.homeManager.zed
        config.flake.modules.homeManager.emacs
        config.flake.modules.homeManager.neovim
        config.flake.modules.homeManager.plasma
      ];

      home.packages = with pkgs; [
        simplex-chat-desktop
        obsidian
        claude-code
      ];
    };
}
