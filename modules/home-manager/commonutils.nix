# Common utilities available on all systems
{ ... }:
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
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
        devenv
        alacritty

        # Required for zsh-nix-shell plugin
        bash
      ];
    };
}
