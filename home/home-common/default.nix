{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./shell.nix
    ./tmux.nix
    #./zellij.nix
    #./kitty.nix
  ];

  programs.ghostty = {
   enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "tokyonight";
      font-size = 10.5;
    };
  };

  programs.helix = {
    enable = true;
    settings.theme = "tokyonight";
  };

}