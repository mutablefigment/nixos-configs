# Desktop configuration shared across desktop hosts
{ config, inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      # Fonts
      fonts = {
        packages = with pkgs; [
          nerd-fonts.hack
          nerd-fonts.jetbrains-mono
          nerd-fonts.iosevka
          ibm-plex
          nerd-fonts.departure-mono
        ];
        fontconfig.defaultFonts = {
          monospace = [ "Iosevka Nerd Font Mono" ];
          sansSerif = [ "Iosevka Nerd Font" ];
          serif = [ "Iosevka Nerd Font" ];
        };
      };

      # Audio with pipewire
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # Networking
      networking.networkmanager.enable = true;

      # Systemd-boot in initrd
      boot.initrd.systemd.enable = true;

      # Display server
      services.xserver.enable = true;
      services.xserver.xkb = {
        layout = "us";
        options = "ctrl:nocaps";
      };

      # KDE Plasma
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      services.desktopManager.plasma6.enable = true;
    };
}
