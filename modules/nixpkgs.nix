# Nixpkgs configuration
{ lib, config, inputs, ... }:
{
  options.nixpkgs = {
    config = lib.mkOption {
      type = lib.types.attrs;
      default = {
        allowUnfree = true;
      };
    };
    overlays = lib.mkOption {
      type = lib.types.listOf lib.types.unspecified;
      default = [ ];
    };
  };

  config = {
    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = config.nixpkgs.config;
          overlays = config.nixpkgs.overlays;
        };
      };
  };
}
