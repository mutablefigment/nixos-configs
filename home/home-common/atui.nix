{
  pkgs,
  ...
}:
{
  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      search_mode = "fuzzy";
    };
  };
}
