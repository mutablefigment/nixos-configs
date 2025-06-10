{
  pkgs,
  ...
}:
{
  # Enable the prometheus exporter node
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
    ];

    openFirewall = true;
    firewallFilter = "-i tailscale0 -p tcp -m tcp --dport 9100";
  };
}
