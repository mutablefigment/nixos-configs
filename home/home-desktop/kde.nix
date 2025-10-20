{
  config,
  pkgs,
  ...
}:
{
  programs.plasma = {
    enable = true;

    # Workspace settings
    workspace = {
      # Look and Feel theme (Haiku Desktop)
      lookAndFeel = "org.magpie.besot.haiku.desktop";

      # Color scheme hash (from kdeglobals)
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
        # Default tile layout: 25% | 50% | 25%
        # This matches the configuration found in kwinrc
      };
    };

    # Configure file dialogs
    configFile = {
      # KWin Xwayland scale
      "kwinrc"."Xwayland"."Scale" = 1.7;

      # Color scheme reference
      "kdeglobals"."General"."ColorSchemeHash" = "ca98508595b9a12b935ada7617197818f6e7caca";

      # Look and Feel package
      "kdeglobals"."KDE"."LookAndFeelPackage" = "org.magpie.besot.haiku.desktop";

      # Window manager colors (from kdeglobals)
      "kdeglobals"."WM"."activeBackground" = "255,203,0";
      "kdeglobals"."WM"."activeBlend" = "252,252,252";
      "kdeglobals"."WM"."activeForeground" = "23,23,23";
      "kdeglobals"."WM"."inactiveBackground" = "232,232,232";
      "kdeglobals"."WM"."inactiveBlend" = "75,71,67";
      "kdeglobals"."WM"."inactiveForeground" = "53,53,53";
    };
  };

  # Ensure the Haiku theme is available
  # Note: This theme is installed locally at ~/.local/share/plasma/look-and-feel/org.magpie.besot.haiku.desktop
  # You may need to package it or keep it as a user-installed theme
  home.file.".local/share/plasma/look-and-feel/org.magpie.besot.haiku.desktop" = {
    source = /home/anon/.local/share/plasma/look-and-feel/org.magpie.besot.haiku.desktop;
    recursive = true;
  };
}
