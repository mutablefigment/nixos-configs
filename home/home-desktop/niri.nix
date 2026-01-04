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
