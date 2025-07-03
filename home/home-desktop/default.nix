{
  pkgs,
  ...
}:
{
  imports = [
    ./programs
    ../home-common
  ];

  home = {
    username = "anon";
    homeDirectory = "/home/anon";
    stateVersion = "23.05";
  };

  home.packages = with pkgs; [
    simplex-chat-desktop
    age-plugin-yubikey
    rage
    wl-clipboard-rs
  ];

  programs.home-manager.enable = true;
  services.lorri.enable = true;
}
