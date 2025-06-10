{ 
  config, 
  pkgs, 
  ... 
}:
{
  # we want apparmor for firejail
  security.apparmor.enable = true;

  programs.firejail = {
    enable = true;

    wrappedBinaries = {
      librewolf = {
        executable = "${pkgs.librewolf}/bin/librewolf";
      };
      mullvad-browser = {
        executable = "${pkgs.mullvad-browser}/bin/mullvad-browser";
      };
    };
  };
}
