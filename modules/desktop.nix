{ pkgs, config, ... }:
{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      ibm-plex
      nerd-fonts.departure-mono
    ];
  };


  # Enable sound with pipewire.
  #sound.enable = true;
  #services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  networking.networkmanager.enable = true;

  boot.initrd.systemd.enable = true;
  #boot.plymouth.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;

  # services.xserver.enable = true;
  # services.xserver.desktopManager.budgie.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;
}
