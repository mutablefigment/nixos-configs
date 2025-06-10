{ 
  config, 
  pkgs, 
  ... 
}:
{
  networking.firewall.logRefusedConnections = false;
  #networking.networkmanager.enable = true;
  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
    trustedInterfaces = [ "tailscale0" ];
  };
}