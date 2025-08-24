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

  programs.wezterm = {
   enable = true;
    enableZshIntegration = true;
    extraConfig = ''-- Your lua code / config here
      return {
        font = wezterm.font("JetBrains Mono"),
        font_size = 12.0,
        color_scheme = "Tokyo Night",
        hide_tab_bar_if_only_one_tab = true,
        -- default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
        keys = {
          {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
        }
      }
    '';

    # settings = {
    #   theme = "tokyonight";
    #   font-size = 10.5;
    # };
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "tokyonight";
      font-family = "IBM Plex Mono";
    };
  };

  programs.alacritty = {
    enable = true;
    theme = "tokyo_night";
  };

  programs.helix = {
    enable = true;
    settings.theme = "tokyonight";
  };

}