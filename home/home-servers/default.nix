{ 
  config, 
  pkgs, 
  ... 
}: {
  imports = [
    ../home-common
  ];

  home = {
    username = "anon";
    homeDirectory = "/home/anon";
    stateVersion = "23.05";
  };

  programs.home-manager.enable = true;
}
