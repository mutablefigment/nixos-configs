{
    config,
    pkgs,
    ...
}:
{
    security.apparmor.enable = true;
    services.fail2ban.enable = true;
}