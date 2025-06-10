{
  pkgs,
  ...
}:
{
  programs.zellij = {
    enable = false;
    enableZshIntegration = true;

    settings = {
      theme = "dracula";
    };
  };
}
