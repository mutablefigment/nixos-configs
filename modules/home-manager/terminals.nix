# Terminal programs
{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.wezterm = {
        enable = true;
        enableZshIntegration = true;
        extraConfig = ''
          return {
            font = wezterm.font("Iosevka NFM"),
            font_size = 12.5,
            color_scheme = "Tokyo Night",
            hide_tab_bar_if_only_one_tab = true,
            keys = {
              {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
            }
          }
        '';
      };

      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        clearDefaultKeybinds = true;
        settings = {
          theme = "TokyoNight Moon";
          font-family = "Iosevka Nerd Font Mono";
        };
      };

      programs.alacritty = {
        enable = false;
        theme = "tokyo_night_enhanced";
        settings = {
          scrolling.history = 1000;
          font = {
            normal = {
              family = "Iosevka Nerd Font Mono";
              style = "Regular";
            };
            bold = {
              family = "Iosevka Nerd Font Mono";
              style = "Bold";
            };
            italic = {
              family = "Iosevka Nerd Font Mono";
              style = "Italic";
            };
            size = 14;
          };
        };
      };

      programs.zellij = {
        enable = false;
        enableZshIntegration = true;
        settings = {
          theme = "tokyo-night";
        };
      };

      programs.zoxide.enableZshIntegration = true;

      programs.atuin = {
        enable = true;
        settings = {
          auto_sync = true;
          sync_frequency = "5m";
          search_mode = "fuzzy";
        };
      };
    };
}
