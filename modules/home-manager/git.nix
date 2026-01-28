# Git configuration
{ config, ... }:
let
  name = "Mutable";
  email = "gh@mutablefigment.xyz";
  signkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOU+iWnGXqMpNj5wZOXN7/IpEz7Cavarzs2rM7RS/aq";
in
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.gh ];

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = name;
            email = email;
            signingkey = signkey;
          };
          commit.gpgsign = true;
          gpg.format = "ssh";
        };
      };

      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = name;
            email = email;
          };
          signing = {
            behavior = "own";
            backend = "ssh";
            key = signkey;
          };
        };
      };
    };
}
