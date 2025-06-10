{
  pkgs,
  ...
}: {
  # All the common packages I will 
  # need on all systems
  home.packages = with pkgs; [
    neofetch
    zip
    xz
    unzip
    p7zip

    ripgrep
    fzf
    mtr
    dnsutils
    nmap

    file
    tree
    gnused
    gnutar
    gnumake
    zstd
    gnupg

    btop
    mosh
  ];
}
