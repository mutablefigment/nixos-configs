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
            terminal = "alacritty";
            startup = [
                {command = "firefox";}
            ];

             output."*".scale = "1.5";
        };

       
    };
}