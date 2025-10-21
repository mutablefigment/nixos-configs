# Disko configuration for automatic disk partitioning
# This creates a GPT layout with EFI boot, LUKS encryption, and ZFS root
# Uses an empty password file for ISO installer (passwordless encryption)
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda"; # Change this to match your disk (e.g., /dev/nvme0n1)
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                # Empty password file for ISO installer - allows for passwordless encryption
                passwordFile = "/tmp/empty-password";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
          acltype = "posixacl";
          xattr = "sa";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
              atime = "off";
            };
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
