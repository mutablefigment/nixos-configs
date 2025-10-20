# Auto-installer ISO for NixOS with desktop configuration
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # ISO configuration
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  
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
  ];

  # Enable flakes in the live environment
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Embed the installation script
  environment.etc."installer/disko-config.nix".source = ./disko-config.nix;
  
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
    fi
  '';
}
