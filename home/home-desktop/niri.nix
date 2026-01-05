{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.niri.homeModules.niri
  ];

  programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
  programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
  # programs.waybar.enable = true; # launch on startup in the default setting (bar)
  services.mako.enable = true; # notification daemon
  services.swayidle.enable = true; # idle management daemon
  services.polkit-gnome.enable = true; # polkit
  home.packages = with pkgs; [
    swaybg # wallpaper
  ];

  programs.niri = {
    enable = true;
    settings = {

      prefer-no-csd = true;

      binds = with config.lib.niri.actions; {
        "Mod+T".action.spawn = "wezterm";
        "Mod+Q".action = close-window;
        "Mod+D".action = spawn "fuzzel";
        "Mod+Space".action = toggle-column-tabbed-display;
        "Mod+Tab".action = focus-window-down-or-column-right;
        "Mod+L".action = focus-window-down-or-column-right;
        "Mod+H".action = focus-window-up-or-column-left;
        "Mod+Shift+Tab".action = focus-window-up-or-column-left;

        "Mod+E".action = quit;
        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = expand-column-to-available-width;

        "Mod+C".action = center-column;
        "Mod+Ctrl+C".action = center-visible-columns;

        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

        "Mod+W".action = toggle-column-tabbed-display;
        # "Print".action = screenshot;
        # "Ctrl+Print".action = screenshot-screen;
        # "Alt+Print".action = screenshot-window;

        # "Mod+Shift+P".action = power-off-monitor;

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;

        # "Mod+Ctrl+1".action = move-column-to-workspace 1;
        # "Mod+Ctrl+2".action = move-column-to-workspace 2;
        # "Mod+Ctrl+3".action = move-column-to-workspace 3;
        # "Mod+Ctrl+4".action = move-column-to-workspace 4;
        # "Mod+Ctrl+5".action = move-column-to-workspace 5;

        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

      };
      window-rules =
        let
          color = config.lib.stylix.colors.withHashtag;
        in
        [
          {
            draw-border-with-background = false;
            geometry-corner-radius =
              let
                r = 8.0;
              in
              {
                top-left = r;
                top-right = r;
                bottom-left = r;
                bottom-right = r;
              };
            clip-to-geometry = true;
          }
        ];
    };
  };

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };

}
