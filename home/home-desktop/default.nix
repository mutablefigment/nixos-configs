{ 
  config, 
  pkgs, 
  ... 
}: {
  imports = [
    ./programs
    ../home-common
  ];

  home = {
    username = "anon";
    homeDirectory = "/home/anon";
    stateVersion = "23.05";
  };

  # Do some overlay magic
  nixpkgs.overlays = [ 
    ./overlays/simplex-chat-desktop.nix
  ];

  home.packages = with pkgs; [
    simplex-chat-desktop
    # (callPackage ../modules/derivations/serve-d.nix { })    

    # For passage that uses rage and a yubikey that decrypts the password
    # store
    age-plugin-yubikey
    rage
    wl-clipboard-rs
  ];

  programs.home-manager.enable = true;
  services.lorri.enable = true;
}
