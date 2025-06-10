{
    config,
    lib,
    pkgs,
    ...
} :
{
  # all of the boot settings
  boot = {
    # Set up static IPv4 address in the initrd.
    # kernelParams = [ "ip=<ipv4_address>::<ipv4_gateway>:<ipv4_netmask>::<interface>:none" ];

    # root is on the zfs partition!
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    # bootloader is needed for booting the system
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # We need this otherwise the system doesn't boot
    zfs = {
      requestEncryptionCredentials = true;
    };

    initrd = {
      # Switch this to your ethernet's kernel module.
      # You can check what module you're currently using by running: lspci -v
      kernelModules = [ "virtio_pci" ];

      network = {
        # This will use udhcp to get an ip address.
        # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`,
        # so your initrd can load it!
        # Static ip addresses might be configured using the ip argument in kernel command line:
        # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
        enable = true;
        ssh = {
          enable = false;
          # To prevent ssh clients from freaking out because a different host key is used,
          # a different port for ssh is useful (assuming the same host has also a regular sshd running)
          port = 2222;
          # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
          # the keys are copied to initrd from the path specified; multiple keys can be set
          # you can generate any number of host keys using
          # `ssh-keygen -t ed25519 -N "" -f /persist/etc/ssh/ssh_host_ed25519_key_initrd`
          hostKeys = [ /persist/etc/ssh/ssh_host_ed25519_key_initrd ];
          # public ssh key used for login
          authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
        };
        # this will automatically load the zfs password prompt on login
        # and kill the other prompt so boot can continue
        postCommands = ''
          cat <<EOF > /root/.profile
          if pgrep -x "zfs" > /dev/null
          then
            zfs load-key -a
            killall zfs
          else
            echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
          fi
          EOF
        '';
      };
    };
  };


  # Default secure ssh settings!
  services.openssh = {
    enable = true;
    settings = { 
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };

	  hostKeys = [
      {
        bits = 4096;
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Enable zram for swap
  zramSwap.enable = true;
  
  # Disable password for sudos
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    coreutils
    curl
    file
    git
    htop
    lsof
    nano
    openssl
    pciutils
    pv
    tmux
    tree
    unar
    vim_configurable
    wget
    zip
  ];

  services.avahi = {
    enable = true;
    ipv4 = true;
    ipv6 = true;
    nssmdns4 = true;
    publish = { 
      enable = true; 
      domain = true; 
      addresses = true; 
    };
  };

}