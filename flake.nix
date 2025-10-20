{
  description = "Mutablefigments NixOS Flake";

  # Enable flakes
  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    allowed-users = [ "anon" ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Official NixOS package sources (unstable)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # lanzaboot for secureboot setups!
    lanzaboote.url = "github:nix-community/lanzaboote";

    # Home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Plasma manager for KDE configuration
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # firefox addons
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    # Agenix for secret managment
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    ssh-keys = {
      url = "https://github.com/mutablefigment.keys";
      flake = false;
    };

    # This is important for the surface laptop, because it needs a custom linux kernel
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # For accessing `deploy-rs`'s utility Nix functions
    deploy-rs.url = "github:serokell/deploy-rs";

    _1password-shell-plugins.url = "github:1Password/shell-plugins";

  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      home-manager,
      agenix,
      helix,
      ssh-keys,
      nixos-hardware,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;        
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
        overlays = [
          (import ./overlays/anytype-overlay.nix)
        ];
      };
    in
    {
      inherit lib;

      nixosConfigurations = {

        gumshoe = lib.nixosSystem {
          modules = [

            lanzaboote.nixosModules.lanzaboote
            ./hosts/gumshoe

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];

          specialArgs = {
            inherit
              inputs
              outputs
              ssh-keys
              nixos-hardware
              ;
          };
        };

        traveler = lib.nixosSystem {
          modules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-z13-gen1

            lanzaboote.nixosModules.lanzaboote
            ./hosts/traveler

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];

          specialArgs = {
            inherit
              inputs
              outputs
              ssh-keys
              nixos-hardware
              ;
          };

        };

        pve = lib.nixosSystem {
          modules = [
            lanzaboote.nixosModules.lanzaboote
            ./hosts/pve

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.anon = import ./home/home-servers;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];

          specialArgs = {
            inherit
              inputs
              outputs
              ssh-keys
              nixos-hardware
              ;
          };

        };

        describe = lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              outputs
              ssh-keys
              nixos-hardware
              ;
          };

          modules = [
            # Apply overlays to the system
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [
                # (import ./overlays/anytype-overlay.nix)
              ];
              nixpkgs.config.allowUnfree = true;
            })

            lanzaboote.nixosModules.lanzaboote
            ./hosts/describe
            home-manager.nixosModules.home-manager

            ({ config, pkgs, ... }: {
              environment.systemPackages = with pkgs; [
                anytype
              ];
            })

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
      };
    };
}
