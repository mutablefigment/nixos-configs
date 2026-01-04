{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./programs
    ../home-common

    ./niri.nix
    ./kde.nix
  ];

  home = {
    username = "anon";
    homeDirectory = "/home/anon";
    stateVersion = "23.05";
  };

  home.packages = with pkgs; [
    simplex-chat-desktop
    # (callPackage ../modules/derivations/serve-d.nix { })

    # For passage that uses rage and a yubikey that decrypts the password
    # store
    age-plugin-yubikey
    rage
    wl-clipboard-rs

    obsidian
    claude-code
  ];

  programs.home-manager.enable = true;
  services.lorri.enable = true;
}
