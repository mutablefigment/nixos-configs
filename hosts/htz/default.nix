{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ../../modules/system.nix
    ./hardware-configuration.nix
  ];
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    # Install GRUB on both drives for redundancy
    devices = [
      "/dev/nvme0n1"
      "/dev/nvme1n1"
    ];
  };

  # Mark /persist as needed for boot (required for impermanence)
  fileSystems."/persist".neededForBoot = true;

  # ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.requestEncryptionCredentials = true;
  networking.hostId = "007f0100"; # Required for ZFS - generate with: head -c 8 /etc/machine-id

  # Network driver for initrd
  boot.initrd.availableKernelModules = [ "e1000e" ];

  # SSH in initrd for remote ZFS passphrase entry
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222; # Different port to avoid host key conflicts
      # This key is generated during installation and persisted
      hostKeys = [ "/persist/etc/ssh/initrd_ssh_host_ed25519_key" ];
      authorizedKeys = [
        # Add your SSH public key here
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOU+iWnGXqMpNj5wZOXN7/IpEz7Cavarzs2rM7RS/aq"
      ];
    };
    postCommands = ''
      cat > /root/.profile <<'EOF'
keystatus=$(zfs get -H -o value keystatus zroot 2>/dev/null)
if [ "$keystatus" = "unavailable" ]; then
  echo ""
  echo "=== ZFS Encrypted Pool Unlock ==="
  echo "Enter passphrase for 'zroot':"
  echo ""
  zfs load-key zroot
  if [ $? -eq 0 ]; then
    echo ""
    echo "Pool unlocked successfully! Continuing boot..."
    killall zfs 2>/dev/null
  else
    echo "Failed to unlock. You can try again with: zfs load-key zroot"
    echo "Or type 'exit' to drop to shell"
  fi
else
  echo "ZFS pool 'zroot' key status: $keystatus"
  echo "Pool already unlocked, continuing boot..."
  killall zfs 2>/dev/null
fi
EOF
    '';
  };

  # Rollback root to blank snapshot on boot (impermanence)
  # This runs after ZFS devices are available but before mounting
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r zroot/root@blank
  '';

  # Impermanence configuration
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  # Ensure /persist directory structure exists
  systemd.tmpfiles.rules = [
    "d /persist 0755 root root -"
    "d /persist/var 0755 root root -"
    "d /persist/var/log 0755 root root -"
    "d /persist/var/lib 0755 root root -"
    "d /persist/var/lib/nixos 0755 root root -"
    "d /persist/var/lib/systemd 0755 root root -"
    "d /persist/var/lib/systemd/coredump 0755 root root -"
    "d /persist/etc 0755 root root -"
    "d /persist/etc/ssh 0755 root root -"
    "d /persist/etc/NetworkManager 0755 root root -"
    "d /persist/etc/NetworkManager/system-connections 0700 root root -"
  ];

  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOU+iWnGXqMpNj5wZOXN7/IpEz7Cavarzs2rM7RS/aq"
  ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

  system.stateVersion = "24.05";
}
