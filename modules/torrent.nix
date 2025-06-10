{ pkgs, config, ... }:
{

  systemd.services.bittorrent = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "i2pd.service" ];
    description = "Start qbittorrent-nox server";

    serviceConfig = {
      Type = "simple";
      User = "anon";
      ExecStart = ''${pkgs.qbittorrent-nox}/bin/qbittorrent-nox '';
    };
  };

  systemd.services."torrenttail" = {
    enable = true;
    description = "Server qbittorrent over tailscale";
    
    wantedBy = [ "multi-user.target" ];
    after = [ "tailscaled.service" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.tailscale}/bin/tailscale serve http://127.0.0.1:8080
      '';
      Restart = "always";
      RestartSec = 1;
    };
  };

  environment.systemPackages = [ pkgs.qbittorrent-nox ];
}
