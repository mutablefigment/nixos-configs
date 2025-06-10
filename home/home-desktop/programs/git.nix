{
  pkgs,
  ...
}: {
  home.packages = [ 
    pkgs.gh 
  ];

  programs.git = {
    enable = true;
    userName = "Mutable";
    userEmail = "gh@mutablefigment.xyz";
    extraConfig = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOU+iWnGXqMpNj5wZOXN7/IpEz7Cavarzs2rM7RS/aq";
    };
  };
}
