{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./shell.nix
    ./tmux.nix
    ./zellij.nix
    ./helix.nix
    ./atui.nix
    ./zoxide.nix
    #./kitty.nix
  ];

  programs.wezterm = {
   enable = true;
    enableZshIntegration = true;
    extraConfig = ''-- Your lua code / config here
      return {
        font = wezterm.font("JetBrains Mono"),
        font_size = 12.0,
        color_scheme = "Gruvbox Dark (Gogh)",
        hide_tab_bar_if_only_one_tab = true,
        -- default_prog = { "zsh", "--login", "-c", "tm" },
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
    clearDefaultKeybinds = true;
    settings = {
      theme = "Gruvbox Dark Hard";
      font-family = "IBM Plex Mono";
    };
  };

  programs.alacritty = {
    enable = false;
    theme = "tokyo_night_enhanced";
    settings = {
      scrolling.history = 1000;
  		font = {
				normal = {
					family = "JetBrains Mono Nerd Font";
					style = "Regular";
				};
				bold = {
					family = "JetBrains Mono Nerd Font";
					style = "Bold";
				};
				italic = {
					family = "JetBrains Mono Nerd Font";
					style = "Italic";
				};
				size = 14;
			};
    };
  };
}
