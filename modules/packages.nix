# ISO installer package
{ config, ... }:
{
  perSystem =
    { system, ... }:
    {
      packages.iso = config.flake.nixosConfigurations.installer.config.system.build.isoImage;
    };
}
