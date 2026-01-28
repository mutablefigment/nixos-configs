# Home-manager NixOS integration module
{ config, inputs, ... }:
{
  flake.modules.nixos = {
    # Base home-manager integration for all hosts
    base = {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };

        users.${config.meta.owner.username} = {
          imports = [
            (
              { osConfig, ... }:
              {
                home.stateVersion = osConfig.system.stateVersion;
              }
            )
            config.flake.modules.homeManager.base
          ];
        };
      };
    };

    # Desktop hosts get GUI home-manager modules
    desktop = {
      home-manager = {
        sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
        users.${config.meta.owner.username}.imports = [
          config.flake.modules.homeManager.desktop
        ];
      };
    };
  };
}
