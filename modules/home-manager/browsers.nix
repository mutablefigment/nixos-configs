# Browser configuration with jail.nix sandboxing
{ inputs, ... }:
{
  flake.modules.homeManager.browsers =
    { pkgs, lib, ... }:
    let
      jail = inputs.jail-nix.lib.init pkgs;

      # Wrap Firefox with jail.nix for sandboxing and disable hardened malloc
      firefoxJailed = jail "firefox" pkgs.firefox (with jail.combinators; [
        network
        gui
        gpu
        (try-rw-bind (noescape "~/.mozilla") (noescape "~/.mozilla"))
        (try-rw-bind (noescape "~/Downloads") (noescape "~/Downloads"))
        (set-env "LD_PRELOAD" "")
      ]);
    in
    {
      programs = {
        chromium = {
          enable = true;
          package = pkgs.ungoogled-chromium;
        };

        firefox = {
          enable = true;
          package = firefoxJailed;

          profiles.anon = {
            settings = {
              "extensions.pocket.enabled" = false;
              "signon.rememberSignons" = false;
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.emailtracking.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "privacy.donottrackheader.enabled" = true;
              "privacy.fingerprintingProtection" = true;
            };

            extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
              ublock-origin
              sponsorblock
              darkreader
              youtube-shorts-block
              vimium
            ];
          };
        };
      };
    };
}
