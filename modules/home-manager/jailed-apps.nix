# Jailed applications with bubblewrap sandboxing via jail.nix
{ inputs, ... }:
{
  flake.modules.homeManager.jailed-apps =
    { pkgs, lib, ... }:
    let
      jail = inputs.jail-nix.lib.init pkgs;

      # Jailed Spotify
      spotifyJailed = jail "spotify" pkgs.spotify (with jail.combinators; [
        network
        gui
        gpu
        (try-rw-bind (noescape "~/.config/spotify") (noescape "~/.config/spotify"))
        (try-rw-bind (noescape "~/.cache/spotify") (noescape "~/.cache/spotify"))
        (set-env "LD_PRELOAD" "")
      ]);

      # Jailed Discord
      discordJailed = jail "discord" pkgs.discord (with jail.combinators; [
        network
        gui
        gpu
        (try-rw-bind (noescape "~/.config/discord") (noescape "~/.config/discord"))
        (try-rw-bind (noescape "~/.cache/discord") (noescape "~/.cache/discord"))
        (try-rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        (set-env "LD_PRELOAD" "")
      ]);

      # Jailed Signal
      signalJailed = jail "signal-desktop" pkgs.signal-desktop (with jail.combinators; [
        network
        gui
        gpu
        (try-rw-bind (noescape "~/.config/Signal") (noescape "~/.config/Signal"))
        (try-rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        (set-env "LD_PRELOAD" "")
      ]);
    in
    {
      home.packages = [
        spotifyJailed
        discordJailed
        signalJailed
      ];
    };
}
