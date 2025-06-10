{
  pkgs,
  ...
}: {
  # All the common packages I will 
  # need on all systems
  home.packages = with pkgs; [
    signal-desktop
    bitwarden
    tilix
    waypipe

    dino
    profanity
    toxic
    simplex-chat-desktop
    direnv
    thunderbird
  ];
}
