{
  config,
  pkgs,
  ssh-keys,
  ...
}:
{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  security.rtkit.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  users.users.root.ignoreShellProgramCheck = true;
  users.users.anon.ignoreShellProgramCheck = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.anon = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "anon";
    extraGroups = [
      "networkmanager"
      "wheel"
      "signald"
      "docker"
      "libvirtd"
      "qemu-libvirtd"
      "disk"
      "dialout"
      "plugdev"
      "podman"
    ];
    openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # use distributed builds
    distributedBuilds = true;

    # buildMachines = [
    #   {
    #     hostName = "describe";
    #     sshUser = "root";
    #     system = "x86_64-linux";
    #     protocol = "ssh";
    #     maxJobs = 4;
    #     speedFactor = 8;
    #     supportedFeatures = [
    #       "nixos-test"
    #       "benchmark"
    #       "big-parallel"
    #       "kvm"
    #     ];
    #     mandatoryFeatures = [ ];
    #   }
    #   {
    #     hostName = "describe";
    #     sshUser = "root";
    #     system = "x86_64-linux";
    #     protocol = "ssh";
    #     maxJobs = 4;
    #     speedFactor = 8;
    #     supportedFeatures = [
    #       "nixos-test"
    #       "benchmark"
    #       "big-parallel"
    #       "kvm"
    #     ];
    #     mandatoryFeatures = [ ];
    #   }
    #   # {
    #   #   hostName = "shellbox";
    #   #   hostName = "shellbox";
    #   #   sshUser = "root";
    #   #   system = "x86_64-linux";
    #   #   protocol = "ssh";
    #   #   maxJobs = 16;
    #   #   speedFactor = 32;
    #   #   supportedFeatures = [
    #   #   maxJobs = 16;
    #   #   speedFactor = 32;
    #   #   supportedFeatures = [
    #   #     "nixos-test"
    #   #     "benchmark"
    #   #     "big-parallel"
    #   #     "kvm"
    #   #   ];
    #   #   mandatoryFeatures = [ ];
    #   # }
    # ];
    settings = {

      trusted-users = [
        "anon"
        "root"
        "@wheel"
      ];

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    nnn
    age
  ];

  environment.shells = with pkgs; [ zsh ];
  environment.variables.EDITOR = "hx";

  security.sudo.wheelNeedsPassword = false;

}
