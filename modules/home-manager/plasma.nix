# KDE Plasma configuration
{ ... }:
{
  flake.modules.homeManager.plasma =
    { ... }:
    {
      programs.plasma = {
        enable = true;

        # Workspace settings
        workspace = {
          lookAndFeel = "com.github.vinceliuice.McMojave";
          colorScheme = "ca98508595b9a12b935ada7617197818f6e7caca";
        };

        # Input settings
        input.keyboard = {
          # Remap CapsLock to Ctrl
          options = [ "ctrl:nocaps" ];
        };

        # KWin (window manager) settings
        kwin = {
          # Virtual desktop configuration
          virtualDesktops = {
            number = 2;
            rows = 1;
          };

          # Tiling settings
          tiling = {
            padding = 4;
          };
        };

        # Configure file dialogs
        configFile = {
          # KWin Xwayland scale
          "kwinrc"."Xwayland"."Scale" = 1.7;

          # Color scheme reference
          "kdeglobals"."General"."ColorSchemeHash" = "ca98508595b9a12b935ada7617197818f6e7caca";

          # Look and Feel package
          "kdeglobals"."KDE"."LookAndFeelPackage" = "com.github.vinceliuice.McMojave";

          # Window manager colors
          "kdeglobals"."WM"."activeBackground" = "255,203,0";
          "kdeglobals"."WM"."activeBlend" = "252,252,252";
          "kdeglobals"."WM"."activeForeground" = "23,23,23";
          "kdeglobals"."WM"."inactiveBackground" = "232,232,232";
          "kdeglobals"."WM"."inactiveBlend" = "75,71,67";
          "kdeglobals"."WM"."inactiveForeground" = "53,53,53";
        };
      };
    };
}
