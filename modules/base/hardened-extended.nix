# Extended hardening options beyond the NixOS hardened profile
# Based on recommendations from https://madaidans-insecurities.github.io/guides/linux-hardening.html
#
# The base NixOS hardened profile already covers:
# - Hardened kernel with security patches
# - kptr_restrict=2, bpf_jit_enable=false, ftrace_enabled=false
# - Strict reverse path filtering, ICMP hardening
# - ICMP redirect blocking, slab_nomerge, page_poison
# - page_alloc.shuffle, debugfs=off, blacklisted modules
# - AppArmor, scudo allocator, lockKernelModules, protectKernelImage
# - forcePageTableIsolation, flushL1DataCache
#
# This module adds additional hardening not covered by the base profile.
{ config, inputs, ... }:
{
  flake.modules.nixos.hardened-extended =
    { pkgs, lib, ... }:
    {
      # ============================================================
      # Use sudo-rs (memory-safe Rust implementation of sudo)
      # ============================================================
      security.sudo.enable = false;
      security.sudo-rs = {
        enable = true;
        execWheelOnly = true;
      };

      # ============================================================
      # Kernel sysctl hardening (from madaidans guide section 2.2)
      # ============================================================
      boot.kernel.sysctl = {
        # --- Kernel self-protection ---

        # Restrict dmesg to processes with CAP_SYSLOG
        "kernel.dmesg_restrict" = lib.mkDefault true;

        # Restrict eBPF to CAP_BPF and harden JIT
        "kernel.unprivileged_bpf_disabled" = lib.mkDefault 1;
        "net.core.bpf_jit_harden" = lib.mkDefault 2;

        # Restrict TTY line discipline loading to CAP_SYS_MODULE
        "dev.tty.ldisc_autoload" = lib.mkDefault 0;

        # Restrict userfaultfd to CAP_SYS_PTRACE (mitigates use-after-free exploits)
        "vm.unprivileged_userfaultfd" = lib.mkDefault 0;

        # Note: kernel.kexec_load_disabled is set by security.protectKernelImage in hardened profile

        # Restrict SysRq to only SAK (Secure Attention Key)
        "kernel.sysrq" = lib.mkDefault 4;

        # Restrict perf_event to CAP_PERFMON
        "kernel.perf_event_paranoid" = lib.mkDefault 3;

        # --- Network hardening ---

        # Enable TCP SYN cookies (mitigates SYN flood attacks)
        "net.ipv4.tcp_syncookies" = lib.mkDefault 1;

        # Protect against time-wait assassination (RFC 1337)
        "net.ipv4.tcp_rfc1337" = lib.mkDefault 1;

        # Disable source routing (prevents man-in-the-middle attacks)
        "net.ipv4.conf.all.accept_source_route" = lib.mkDefault 0;
        "net.ipv4.conf.default.accept_source_route" = lib.mkDefault 0;
        "net.ipv6.conf.all.accept_source_route" = lib.mkDefault 0;
        "net.ipv6.conf.default.accept_source_route" = lib.mkDefault 0;

        # Disable IPv6 router advertisements (prevents MITM)
        "net.ipv6.conf.all.accept_ra" = lib.mkDefault 0;
        "net.ipv6.conf.default.accept_ra" = lib.mkDefault 0;

        # Disable TCP SACK (commonly exploited, often unnecessary)
        # Note: May impact performance on high-latency/lossy networks
        "net.ipv4.tcp_sack" = lib.mkDefault 0;
        "net.ipv4.tcp_dsack" = lib.mkDefault 0;

        # Disable TCP timestamps (prevents clock fingerprinting)
        "net.ipv4.tcp_timestamps" = lib.mkDefault 0;

        # --- User space protection ---

        # Restrict ptrace to CAP_SYS_PTRACE
        "kernel.yama.ptrace_scope" = lib.mkDefault 2;

        # Increase ASLR entropy (for x86_64)
        "vm.mmap_rnd_bits" = lib.mkDefault 32;
        "vm.mmap_rnd_compat_bits" = lib.mkDefault 16;

        # Protect symlinks and hardlinks from TOCTOU races
        "fs.protected_symlinks" = lib.mkDefault 1;
        "fs.protected_hardlinks" = lib.mkDefault 1;

        # Protect FIFOs and regular files in world-writable directories
        "fs.protected_fifos" = lib.mkDefault 2;
        "fs.protected_regular" = lib.mkDefault 2;

        # --- Core dumps ---
        # Disable core dumps for setuid processes
        "fs.suid_dumpable" = lib.mkDefault 0;

        # --- Swap ---
        # Only swap when absolutely necessary
        "vm.swappiness" = lib.mkDefault 1;

        # --- IPv6 privacy extensions ---
        "net.ipv6.conf.all.use_tempaddr" = lib.mkDefault 2;
        "net.ipv6.conf.default.use_tempaddr" = lib.mkDefault 2;
      };

      # ============================================================
      # Boot parameters (from madaidans guide section 2.3)
      # ============================================================
      boot.kernelParams = [
        # Zero memory on allocation and free (mitigates use-after-free)
        "init_on_alloc=1"
        "init_on_free=1"

        # Randomize kernel stack offset on syscalls
        "randomize_kstack_offset=on"

        # Disable vsyscalls (obsolete, potential ROP target)
        "vsyscall=none"

        # Panic on oops (prevents exploitation of kernel bugs)
        # Note: May cause crashes on bad drivers
        "oops=panic"

        # Quiet boot to prevent information leaks
        "quiet"
        "loglevel=0"

        # Enable IOMMU for DMA protection (section 21.6)
        "intel_iommu=on"
        "amd_iommu=on"
        # Disable early PCI DMA (fixes IOMMU hole)
        "efi=disable_early_pci_dma"

        # Don't blindly trust CPU RDRAND (section 18)
        "random.trust_cpu=off"
      ];

      # ============================================================
      # Blacklist additional kernel modules (section 2.5.2)
      # ============================================================
      boot.blacklistedKernelModules = [
        # Obscure networking protocols (high attack surface)
        "dccp"
        "sctp"
        "rds"
        "tipc"
        "n-hdlc"
        "x25"
        "decnet"
        "econet"
        "af_802154"
        "ipx"
        "appletalk"
        "psnap"
        "p8023"
        "p8022"
        "can"
        "atm"

        # Rare/legacy filesystems
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "squashfs"
        "udf"

        # Vivid driver (test driver, has caused privilege escalation)
        "vivid"

        # Firewire and Thunderbolt (DMA attack vectors)
        "firewire-core"
        "thunderbolt"
      ];

      # ============================================================
      # Core dump prevention (section 12)
      # ============================================================
      systemd.coredump.enable = lib.mkDefault false;

      # ============================================================
      # File permissions (section 11.2)
      # ============================================================
      # Set restrictive umask
      environment.variables.UMASK = "0077";

      # ============================================================
      # Restrict /proc visibility (section 2.4 - hidepid)
      # ============================================================
      # Users can only see their own processes
      boot.specialFileSystems."/proc".options = [ "hidepid=2" ];

      # Allow systemd-logind to see all processes
      systemd.services.systemd-logind.serviceConfig.SupplementaryGroups = [ "proc" ];

      # Create proc group for whitelisting
      users.groups.proc = { };

      # ============================================================
      # SSH hardening (section 8.4)
      # ============================================================
      services.openssh.settings = {
        # Deny root login via SSH
        PermitRootLogin = lib.mkDefault "no";
        # Use strong key exchange algorithms
        KexAlgorithms = lib.mkDefault [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
        ];
        # Disable password authentication
        PasswordAuthentication = lib.mkDefault false;
        # Disable keyboard-interactive authentication
        KbdInteractiveAuthentication = lib.mkDefault false;
      };

      # ============================================================
      # PAM hardening (section 14)
      # ============================================================
      # Add delay between failed login attempts
      security.pam.loginLimits = [
        # Disable core dumps for all users
        { domain = "*"; type = "hard"; item = "core"; value = "0"; }
      ];

      # ============================================================
      # Microcode updates (section 15)
      # ============================================================
      hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
      hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
    };
}
