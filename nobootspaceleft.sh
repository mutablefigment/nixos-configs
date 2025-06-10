#!/usr/bin/env bash

sudo nix-collect-garbage --delete-older-than 30d
sudo nix-collect-garbage -d