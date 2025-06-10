{
  pkgs,
  ...
}:
{
  systemd.services."background-tmux" = {
    description = "Start tmux in background";
    serviceConfig = {
      Type = "simple";
      User = "anon";
      ExecStart = "${pkgs.tmux}/bin/tmux -S /tmp/tmux.sock";
      RestartSec = 5;
      Restart = "always";
    };
  };
}
