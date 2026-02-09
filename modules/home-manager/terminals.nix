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
          keybind = [
            # Splits (like tmux prefix+v / prefix+h)
            "ctrl+space>v=new_split:right"
            "ctrl+space>h=new_split:down"

            # New tab (like tmux prefix+w)
            "ctrl+space>w=new_tab"

            # Navigate splits (like tmux C-h/j/k/l)
            "ctrl+h=goto_split:left"
            "ctrl+j=goto_split:down"
            "ctrl+k=goto_split:up"
            "ctrl+l=goto_split:right"

            # Navigate tabs (like tmux C-M-j / C-M-k)
            "ctrl+alt+j=previous_tab"
            "ctrl+alt+k=next_tab"

            # Resize splits (like tmux prefix+r then h/j/k/l)
            "ctrl+shift+h=resize_split:left,10"
            "ctrl+shift+j=resize_split:down,10"
            "ctrl+shift+k=resize_split:up,10"
            "ctrl+shift+l=resize_split:right,10"

            # Zoom split (like tmux prefix+z)
            "ctrl+space>z=toggle_split_zoom"

            # Equalize splits
            "ctrl+space>equal=equalize_splits"

            # Rename tab (like tmux prefix+n)
            "ctrl+space>n=prompt_surface_title"

            # Close surface (like tmux prefix+x)
            "ctrl+space>x=close_surface"

            # Essentials (since defaults are cleared)
            "ctrl+shift+c=copy_to_clipboard"
            "ctrl+shift+v=paste_from_clipboard"
            "ctrl+equal=increase_font_size:1"
            "ctrl+minus=decrease_font_size:1"
            "ctrl+zero=reset_font_size"
            "ctrl+shift+n=toggle_fullscreen"
            "ctrl+shift+i=inspector:toggle"
            "ctrl+shift+comma=open_config"
            "ctrl+shift+r=reload_config"
          ];
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
