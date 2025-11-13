{
  config,
  pkgs,
  ...
}:
{
    wayland.windowManager.sway = {
        enable = false;
        wrapperFeatures.gtk = true;

        config = rec {
            modifier = "Mod4";
            terminal = "ghostty";
            startup = [
                {command = "firefox";}
            ];

            output."*".scale = "1.75";
        };
    };

    programs.waybar.enable = true;
}
