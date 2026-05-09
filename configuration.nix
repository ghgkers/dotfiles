{ config, pkgs, inputs, lib, ... }:
let
  # ---- Custom sowm (from your original config) ----
  mySowm = pkgs.stdenv.mkDerivation {
    pname = "sowm";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "dylanaraps";
      repo = "sowm";
      rev = "master";
      sha256 = "sha256-Q65sU5K86pFk3QNlzfxgyoEw6NpBaZQmFOkUFnmoh+U=";
    };
    buildInputs = with pkgs; [ libX11 libXinerama ];
    nativeBuildInputs = with pkgs; [ gcc gnumake ];
    installPhase = "mkdir -p $out/bin; make PREFIX=$out install";
  };

  # ---- JVM flags for Minecraft (your tweaks) ----
  mcFlags = builtins.concatStringsSep " " [
    "-Xmx6G" "-Xms2G" "-XX:+UseZGC" "-XX:+ZGenerational"
    "-XX:+UnlockExperimentalVMOptions" "-XX:+UnlockDiagnosticVMOptions"
    "-XX:+AlwaysPreTouch" "-XX:+UseNUMA" "-XX:+AlwaysActAsServerClassMachine"
    "-XX:+UseCriticalJavaThreadPriority" "-XX:ThreadPriorityPolicy=1"
    "-XX:AllocatePrefetchStyle=3" "-XX:ReservedCodeCacheSize=256M"
    "-XX:+UseVectorCmov" "-XX:+PerfDisableSharedMem"
    "-XX:+UseFastUnorderedTimeStamps" "-XX:+UseLargePages"
    "-XX:+ExitOnOutOfMemoryError" "-Dsun.graphics.2d.noddraw=true"
    "-Djava.net.preferIPv4Stack=true" "-Dio.netty.allocator.type=pooled"
  ];

  # ---- Extra sysctl performance tweaks ----
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

  # ===================== NIX SETTINGS =====================
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

  # ===================== BOOT & KERNEL =====================
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # The key to insane speed: CachyOS LTO kernel
    kernelPackages = pkgs.linuxPackages_cachyos-lto;

    # Safe params – console always visible, NVIDIA modeset disabled
    kernelParams = [
      "nvidia-drm.modeset=0"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];

    kernel.sysctl = sysctlTweaks;
  };

  # ===================== HARDWARE =====================
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  # NVIDIA – stable driver, open module, no kernel modeset
  hardware.nvidia = {
    open = true;
    modesetting.enable = false;      # Xorg handles it
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # CPU frequency governor (change to "schedutil" for battery)
  powerManagement.cpuFreqGovernor = "performance";

  # ===================== PERFORMANCE DAEMONS =====================
  # CachyOS‑like user‑space optimisations
  services.ananicy.enable = true;            # auto‑nice daemon
  services.irqbalance.enable = true;         # distribute IRQs
  systemd.oomd.enable = true;                # better OOM killer

  # ASUS ROG laptop daemon (fan control, keyboard lights, etc.)
  services.asusd.enable = true;

  # ===================== NETWORKING =====================
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  # ===================== DISK & MEMORY =====================
  services.fstrim.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Lightweight D‑Bus
  services.dbus.implementation = "broker";

  # I/O scheduler udev rules (NVMe: none, SSD: kyber, HDD: bfq)
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
    ACTION=="add|change", KERNEL=="sd*[!0-9]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  # ===================== AUDIO =====================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ===================== X11 & WINDOW MANAGER =====================
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us,ru";
    xkb.options = "grp:win_space_toggle";
    # No display manager – we use startx from TTY
  };

  # Drop your custom sowm into .xinitrc
  systemd.tmpfiles.rules = [
    "L+ /home/dx3d/.xinitrc - - - - ${pkgs.writeText "xinitrc" ''
      #!/bin/sh
      exec ${mySowm}/bin/sowm
    ''}"
  ];

  # ===================== GAMING & PERFORMANCE PACKAGES =====================
  environment.systemPackages = with pkgs; [
    xorg.xinit
    st                     # terminal
    librewolf              # browser
    mySowm                 # your custom window manager

    # Gaming essentials
    steam
    gamemode
    gamescope
    mangohud
    goverlay               # GUI to configure MangoHud
    libstrangle            # frame rate limiter
    wineWowPackages.stable
    winetricks
    dxvk
    vkd3d
    lutris                 # optional game launcher
    protonup-qt            # easy Proton‑GE installs

    # System monitoring
    fastfetch
    htop

    # File management & media
    feh
    scrot
    pavucontrol
    dmenu
    xclip
  ];

  # ===================== PROGRAMS & SERVICES =====================
  programs.steam.enable = true;
  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };
  programs.gamescope.enable = true;
  programs.mangohud.enable = true;

  # Bash aliases (from your original)
  programs.bash.shellAliases = {
    dotsync = "cd ~/dotfiles && sudo cp /etc/nixos/configuration.nix . && sudo cp /etc/nixos/hardware-configuration.nix . && sudo cp /etc/nixos/flake.nix . && git add . && git commit -m \"update:$(date +'%Y-%m-%d %H:%M')\" && git pull origin main --rebase && git push origin main && cd -";
    clean = "sudo nix-collect-garbage -d";
    v = "nvim";
  };

  # ===================== USER =====================
  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "networkmanager" "video" "audio"
      "input"                 # critical for keyboard/mouse in X
      "gamemode"              # so gamemode can renice games
    ];
    # User‑specific packages (if you prefer them isolated)
    packages = with pkgs; [
      # Already in systemPackages, but you could list additional ones here
    ];
  };

  # ===================== MISC TWEAKS =====================
  documentation.enable = false;
  documentation.nixos.enable = false;
  environment.defaultPackages = lib.mkForce [];

  services.journald.extraConfig = "SystemMaxUse=50M";
  services.logind.settings.Login.NAutoVTs = 1;

  # Flatpak + Sober (Roblox) – your existing service
  systemd.services.install-sober = {
    description = "Install Sober Flatpak from Flathub";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      ${pkgs.flatpak}/bin/flatpak install -y flathub org.vinegarhq.Sober || true
    '';
    serviceConfig.Type = "oneshot";
    path = [ pkgs.flatpak ];
    scriptArgs = "--skip-if-done";
    environment.XDG_CACHE_HOME = "/var/cache/flatpak";
  };

  # ===================== STATE =====================
  system.stateVersion = "25.11";
}
