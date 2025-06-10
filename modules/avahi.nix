{ 
  pkgs, 
  ... 
}:
{
  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    publish = { 
      enable = true; 
      domain = true; 
      addresses = true; 
    };
  };
}