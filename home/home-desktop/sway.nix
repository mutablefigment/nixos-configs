{
  config,
  pkgs,
  ...
}:
{
    wayland.windowManager.sway = {
        enable = false;
        wrapperFeatures.gtk = true;
        # package = pkgs.swayfx;

        config = rec {
            modifier = "Mod4";
            terminal = "alacritty";
            startup = [
                {command = "firefox";}
            ];

            # output."*".scale = "1.25";
        };
    };

    programs.waybar.enable = true;
}
