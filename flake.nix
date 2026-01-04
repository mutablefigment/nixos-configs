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

    # Helix editor from master for latest features
    helix.url = "github:helix-editor/helix";
    # helix-gpt.url = "github:leona/helix-gpt";
    # helix-gpt.inputs.nixpkgs.follows = "nixpkgs";

    # Disko for declarative disk partitioning
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Morph for multi-machine deployment
    morph.url = "github:DBCDK/morph";
    morph.inputs.nixpkgs.follows = "nixpkgs";

    # Colmena for multi-machine deployment
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    impermanence.url = "github:nix-community/impermanence";

    zen-browser.url = "github:youwen5/zen-browser-flake";
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
      disko,
      morph,
      colmena,
      proxmox-nixos,
      impermanence,
      zen-browser,
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
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

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
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

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
              helix
              ;
          };

        };

        mountain = lib.nixosSystem {
          modules = [
           # lanzaboote.nixosModules.lanzaboote

            proxmox-nixos.nixosModules.proxmox-ve
            ({ pkgs, lib, ... }: {
              services.proxmox-ve = {
                enable = true;
                ipAddress = "192.168.176.156";
              };

              nixpkgs.overlays = [
                proxmox-nixos.overlays.${system}
              ];
            })

            ./hosts/mountain

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

        htz = lib.nixosSystem {
          modules = [
           # lanzaboote.nixosModules.lanzaboote
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
            ./hosts/htz

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
              helix
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

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
        
        watchtower = lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              outputs
              ssh-keys
              nixos-hardware
              helix
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
            ./hosts/watchtower
            home-manager.nixosModules.home-manager

            ({ config, pkgs, ... }: {
              environment.systemPackages = with pkgs; [
                anytype
              ];
            })

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        # ISO installer with automatic desktop installation
        installer = lib.nixosSystem {
          inherit system;
          modules = [
            disko.nixosModules.disko
            ./iso/installer.nix
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };

      # Packages output
      packages.${system} = {
        # Build the ISO with: nix build .#iso
        iso = self.nixosConfigurations.installer.config.system.build.isoImage;
      };

      # Development shells
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          colmena.packages.${system}.colmena
        ];
      };

      # Colmena deployment configuration
      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
            overlays = [
              (import ./overlays/anytype-overlay.nix)
            ];
          };
          specialArgs = {
            inherit
              inputs
              outputs
              ssh-keys
              nixos-hardware
              ;
          };
        };

        # Desktop machines
        gumshoe = {
          deployment = {
            targetHost = "gumshoe";
            targetUser = "anon";
            tags = [ "desktop" ];
          };
          imports = [
            lanzaboote.nixosModules.lanzaboote
            ./hosts/gumshoe

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        traveler = {
          deployment = {
            targetHost = "traveler";
            targetUser = "anon";
            tags = [ "desktop" "laptop" ];
          };
          imports = [
            nixos-hardware.nixosModules.lenovo-thinkpad-z13-gen1

            lanzaboote.nixosModules.lanzaboote
            ./hosts/traveler

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        describe = {
          deployment = {
            targetHost = "describe";
            targetUser = "anon";
            tags = [ "desktop" ];
          };
          imports = [
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
              home-manager.sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

              home-manager.users.anon = import ./home/home-desktop;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };

        # Server machines
        pve = {
          deployment = {
            targetHost = "pve";
            targetUser = "anon";
            tags = [ "server" ];
          };
          imports = [
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
        };
      };
    };
}
