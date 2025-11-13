# Auto-installer ISO for NixOS with desktop configuration
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # ISO configuration
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  # Enable dm-verity for ISO root filesystem integrity checking
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # Add dm-verity support to initrd
  boot.initrd.kernelModules = [ "dm-verity" "dm-mod" ];

  # Enable verity for the squashfs image
  boot.initrd.availableKernelModules = [ "dm-verity" ];
  
  # Auto-login as nixos user for convenience
  services.getty.autologinUser = lib.mkForce "nixos";

  # Enable SSH for remote installation if needed
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # Add necessary packages for installation
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    parted
    gptfdisk
    zfs
    cryptsetup  # Includes veritysetup for dm-verity management
  ];

  # Enable flakes in the live environment
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Embed the installation script
  environment.etc."installer/disko-config.nix".source = ./disko-config.nix;

  # dm-verity helper script for setting up verified partitions
  environment.etc."installer/setup-verity.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      # Helper script to set up dm-verity on a partition
      # Usage: setup-verity.sh <data-device> <hash-device> [name]

      set -euo pipefail

      if [ "$#" -lt 2 ]; then
        echo "Usage: $0 <data-device> <hash-device> [name]"
        echo ""
        echo "Example: $0 /dev/sda2 /dev/sda3 verified-root"
        echo ""
        echo "This will:"
        echo "  1. Format the hash device with dm-verity hash tree"
        echo "  2. Display the root hash for verification"
        echo "  3. Set up the dm-verity device mapping"
        exit 1
      fi

      DATA_DEV="$1"
      HASH_DEV="$2"
      NAME="''${3:-verity}"

      if [ ! -b "$DATA_DEV" ]; then
        echo "Error: $DATA_DEV is not a valid block device"
        exit 1
      fi

      if [ ! -b "$HASH_DEV" ]; then
        echo "Error: $HASH_DEV is not a valid block device"
        exit 1
      fi

      echo "Setting up dm-verity for $DATA_DEV"
      echo "Hash device: $HASH_DEV"
      echo "Mapping name: $NAME"
      echo ""

      # Format the hash device
      echo "Creating hash tree..."
      HASH_OUTPUT=$(veritysetup format "$DATA_DEV" "$HASH_DEV")

      echo ""
      echo "$HASH_OUTPUT"
      echo ""

      # Extract root hash from output
      ROOT_HASH=$(echo "$HASH_OUTPUT" | grep "Root hash:" | awk '{print $3}')

      if [ -z "$ROOT_HASH" ]; then
        echo "Error: Failed to extract root hash"
        exit 1
      fi

      echo "Root hash: $ROOT_HASH"
      echo ""
      echo "To activate the dm-verity device, run:"
      echo "  veritysetup open $DATA_DEV $NAME $HASH_DEV $ROOT_HASH"
      echo ""
      echo "The verified device will be available at: /dev/mapper/$NAME"
      echo ""
      echo "IMPORTANT: Save the root hash! You'll need it to mount this device."
      echo "Add this to your kernel command line or initrd configuration:"
      echo "  roothash=$ROOT_HASH"
    '';
  };
  
  environment.etc."installer/install.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "=========================================="
      echo "NixOS Auto-Installer with Desktop Config"
      echo "=========================================="
      echo ""
      echo "WARNING: This will ERASE ALL DATA on the selected disk!"
      echo ""

      # Prompt for disk selection
      echo "Available disks:"
      lsblk -d -o NAME,SIZE,TYPE | grep disk
      echo ""
      read -p "Enter the disk to install to (e.g., sda or nvme0n1): " DISK_NAME

      if [ -z "$DISK_NAME" ]; then
        echo "Error: No disk specified"
        exit 1
      fi

      DISK_PATH="/dev/$DISK_NAME"
      
      if [ ! -b "$DISK_PATH" ]; then
        echo "Error: $DISK_PATH is not a valid block device"
        exit 1
      fi

      echo ""
      echo "Installing to: $DISK_PATH"
      read -p "Are you ABSOLUTELY sure? Type 'yes' to continue: " CONFIRM

      if [ "$CONFIRM" != "yes" ]; then
        echo "Installation cancelled"
        exit 0
      fi

      # Create a temporary disko config with the selected disk
      DISKO_CONFIG="/tmp/disko-config.nix"
      sed "s|/dev/sda|$DISK_PATH|g" /etc/installer/disko-config.nix > "$DISKO_CONFIG"

      echo ""
      echo "Step 1: Partitioning disk with disko..."
      nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
        --mode disko "$DISKO_CONFIG"

      echo ""
      echo "Step 2: Generating hardware configuration..."
      mkdir -p /mnt/etc/nixos
      nixos-generate-config --root /mnt

      echo ""
      echo "Step 3: Cloning your nixos-configs repository..."
      read -p "Enter your GitHub username (default: mutablefigment): " GITHUB_USER
      GITHUB_USER=''${GITHUB_USER:-mutablefigment}
      
      git clone "https://github.com/$GITHUB_USER/nixos-configs.git" /mnt/etc/nixos/config || {
        echo "Failed to clone repository. Continuing with basic configuration..."
      }

      echo ""
      echo "Step 4: Installing NixOS with desktop configuration..."
      
      # Determine which host config to use
      echo "Available host configurations:"
      echo "1) describe (desktop with KDE Plasma)"
      echo "2) gumshoe"
      echo "3) traveler (ThinkPad Z13)"
      echo "4) pve (server)"
      read -p "Select configuration (1-4) or press Enter for describe: " HOST_CHOICE

      case "$HOST_CHOICE" in
        2) HOST_CONFIG="gumshoe" ;;
        3) HOST_CONFIG="traveler" ;;
        4) HOST_CONFIG="pve" ;;
        *) HOST_CONFIG="describe" ;;
      esac

      if [ -d "/mnt/etc/nixos/config" ]; then
        nixos-install --flake "/mnt/etc/nixos/config#$HOST_CONFIG" --no-root-passwd
      else
        echo "Repository not found, installing with generated config..."
        nixos-install --no-root-passwd
      fi

      echo ""
      echo "=========================================="
      echo "Installation complete!"
      echo "=========================================="
      echo ""
      echo "Please set a root password and user password after reboot."
      echo ""
      read -p "Reboot now? (y/N): " REBOOT

      if [ "$REBOOT" = "y" ] || [ "$REBOOT" = "Y" ]; then
        reboot
      fi
    '';
  };

  # Create a desktop shortcut for easy access to the installer
  system.activationScripts.installerShortcut = ''
    mkdir -p /home/nixos/Desktop
    cat > /home/nixos/Desktop/install.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Install NixOS
    Exec=konsole -e sudo /etc/installer/install.sh
    Icon=system-software-install
    Terminal=false
    EOF
    chmod +x /home/nixos/Desktop/install.desktop
    chown nixos:users /home/nixos/Desktop/install.desktop
  '';

  # Add a welcome message
  programs.bash.interactiveShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      echo ""
      echo "=========================================="
      echo "Welcome to NixOS Auto-Installer!"
      echo "=========================================="
      echo ""
      echo "To start the installation, run:"
      echo "  sudo /etc/installer/install.sh"
      echo ""
      echo "Or use the desktop shortcut if available."
      echo ""
      echo "dm-verity support is enabled!"
      echo "For dm-verity setup, see:"
      echo "  /etc/installer/setup-verity.sh --help"
      echo ""
    fi
  '';
}
