![Logo](./logo.svg)

# Nix Configurations

This repo contains all nix configs that build my systems


## How to install Nix and Deploy this Flake?

After installed NixOS with `nix-command` & `flake` enabled, you can deploy this flake with the following command:

```bash
sudo nixos-rebuild switch --flake .#traveler
```

## Notes

boot.kernelPackages = latest; breaks grave host for some reason, kernel 6.1 is fine

To fix `no space left on device` error while switching nixos configs, run `./nobootspaceleft.sh`

## Tailscale policy file

Tailscale policy is in policy.hujson


## Remote deployments

```bash
sudo nixos-rebuild switch --target-host watchtower --flake .#watchtower
````
