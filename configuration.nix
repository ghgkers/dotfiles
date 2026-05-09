{ config, pkgs, inputs, lib, ... }:
let
  # Extra sysctl tunings – merge with boot.kernel.sysctl below
  sysctlTweaks = {
    "vm.vfs_cache_pressure" = 500;
    "vm.swappiness" = 10;
    "kernel.sched_child_runs_first" = 1;
    "kernel.sched_autogroup_enabled" = 0;
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
in
{
  imports = [ ./hardware-configuration.nix ];

  # ----- Nix settings -----
  nixpkgs.overlays = [ inputs.chaotic.overlays.default ];
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    min-free = 536870912;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ----- Boot & Kernel (safe for console) -----
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_cachyos;
    kernelParams = [
      "nvidia-drm.modeset=0"            # keep console visible
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      # (your previous blacklist omitted – let things load for now)
    ];
    kernel.sysctl = sysctlTweaks;
  };

  # ----- Hardware -----
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = false;         # let X do its own modesetting
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ----- Power & CPU -----
  powerManagement.cpuFreqGovernor = "performance";   # use "schedutil" for battery

  # ----- System services (CachyOS-like) -----
  services.ananicy.enable = true;               # auto-nice daemon
  services.irqbalance.enable = true;            # IRQ distribution
  systemd.oomd.enable = true;                   # better OOM handling

  # ----- Networking -----
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  # ----- Trim & Disk -----
  services.fstrim.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # ----- DBus -----
  services.dbus.implementation = "broker";

  # ----- I/O Scheduler udev rule -----
  services.udev.extraRules = ''
    # Set no scheduler for NVMe, kyber for SSD, bfq for rotational
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
    ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  # ----- Audio -----
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ----- X11 with no display manager -----
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us,ru";
    xkb.options = "grp:win_space_toggle";
  };

  # ----- startx with DWM (temporary – will replace with sowm later) -----
  systemd.tmpfiles.rules = [
    "L+ /home/dx3d/.xinitrc - - - - ${pkgs.writeText "xinitrc" ''
      #!/bin/sh
      exec ${pkgs.dwm}/bin/dwm
    ''}"
  ];

  environment.systemPackages = with pkgs; [
    xorg.xinit
    dwm
    st                  # a terminal so you can test
    # add other packages later
  ];

  # ----- User -----
  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    # No extra packages for now – keep build quick
  };

  # ----- Misc -----
  documentation.enable = false;
  documentation.nixos.enable = false;
  environment.defaultPackages = lib.mkForce [];

  services.journald.extraConfig = "SystemMaxUse=50M";
  services.logind.settings.Login.NAutoVTs = 1;

  system.stateVersion = "25.11";
}
