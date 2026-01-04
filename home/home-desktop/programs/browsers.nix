{
  config,
  pkgs,
  inputs,
  ...
}:
{

  programs = {
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };

    firefox = {
      enable = true;
      package = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
}
