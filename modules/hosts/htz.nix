# HTZ server host configuration (Hetzner server with impermanence)
{ config, inputs, ... }:
let
  # Disko configuration for ZFS with impermanence
  diskoConfig = {
    disko.devices = {
      disk = {
        nvme0 = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02";
              };
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
        nvme1 = {
          type = "disk";
          device = "/dev/nvme1n1";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02";
              };
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      zpool = {
        zroot = {
          type = "zpool";
          mode = "";
          options = {
            ashift = "12";
            autotrim = "on";
          };
          rootFsOptions = {
            mountpoint = "none";
            compression = "zstd";
            acltype = "posixacl";
            xattr = "sa";
            dnodesize = "auto";
            normalization = "formD";
            relatime = "on";
            "com.sun:auto-snapshot" = "false";
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "prompt";
          };
          postCreateHook = ''
            zfs snapshot zroot/root@blank
          '';
          datasets = {
            "root" = {
              type = "zfs_fs";
              options.mountpoint = "legacy";
              mountpoint = "/";
            };
            "nix" = {
              type = "zfs_fs";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "false";
              };
              mountpoint = "/nix";
            };
            "persist" = {
              type = "zfs_fs";
              options = {
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "true";
              };
              mountpoint = "/persist";
              mountOptions = [ "noatime" ];
            };
            "swap" = {
              type = "zfs_volume";
              size = "8G";
              options = {
                volblocksize = "4096";
                compression = "zle";
                logbias = "throughput";
                sync = "always";
                primarycache = "metadata";
                secondarycache = "none";
                "com.sun:auto-snapshot" = "false";
              };
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };
in
{
  configurations.nixos.htz.module =
    { pkgs, lib, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        (modulesPath + "/profiles/qemu-guest.nix")
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        config.flake.modules.nixos.base
        diskoConfig
      ];

      # Hardware configuration
      boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "e1000e" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

      # Bootloader
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = [
          "/dev/nvme0n1"
          "/dev/nvme1n1"
        ];
      };

      # Mark /persist as needed for boot
      fileSystems."/persist".neededForBoot = true;

      # ZFS support
      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs.forceImportRoot = false;
      boot.zfs.requestEncryptionCredentials = true;
      networking.hostId = "007f0100";
      networking.hostName = "htz";

      # SSH in initrd for remote ZFS passphrase entry
      boot.initrd.network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [ "/persist/etc/ssh/initrd_ssh_host_ed25519_key" ];
          authorizedKeys = [
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

      # Rollback root to blank snapshot on boot
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

      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOU+iWnGXqMpNj5wZOXN7/IpEz7Cavarzs2rM7RS/aq"
      ];

      system.stateVersion = "24.05";
    };
}
