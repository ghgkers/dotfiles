{ config, pkgs, inputs, lib, ... }:
let
  # ===================== NETWORK & HvH TWEAKS =====================
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

  # ===================== CORE OS =====================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "nix-gaming";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Almaty";

  # ===================== PRIVILEGE ESCALATION =====================
  security.sudo.enable = false;
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "dx3d" ];
    keepEnv = true;
    persist = true;
  }];

  # ===================== KERNEL & BOOT (CACHYOS + 8000HZ FIX) =====================
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    
    # Low-latency CachyOS Kernel
    kernelPackages = pkgs.linuxPackages_cachyos;
    
    # nvidia-drm for Wayland | usbhid.kbpoll=1 for 8000Hz polling rate
    kernelParams = [ 
      "nvidia-drm.modeset=1" 
      "usbcore.autosuspend=-1" 
      "usbhid.kbpoll=1" 
    ];
    kernel.sysctl = sysctlTweaks;
    
    # PERMANENT HARDWARE BLACKLIST (Touchpad & Bluetooth completely dead)
    blacklistedKernelModules = [
      "bluetooth" "btusb" "btintel" "btrtl"
      "i2c_hid" "i2c_hid_acpi" "hid_multitouch"
    ];

    supportedFilesystems = [ "fuse" ]; # Required for appimage-run FUSE execution
  };

  # ===================== HARDWARE (ASUS ROG + NVIDIA) =====================
  services.asusd.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.bluetooth.enable = false;

  hardware.nvidia = {
    modesetting.enable = true;
    # Forced to FALSE: Uses proprietary drivers to fix Java/Minecraft frame-pacing
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  powerManagement.cpuFreqGovernor = "performance"; # Locks CPU scaling from stuttering

  # ===================== AUDIO (LOW LATENCY TWEAK) =====================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    
    # High-performance audio quantum loops for instant sound cues
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 64;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 1024;
      };
    };
  };

  # ===================== GRAPHICS & WINDOW MANAGERS =====================
  # Wayland / Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable SDDM as the login manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # X11 & DWM Window Manager Configuration
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm;
    };

    # Keyboard layout configuration swapped by Super+Space
    xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle";
    };
  };

  console.useXkbConfig = true; # Forces console TTYs to respect layouts

  # Creates default startup execution link for raw X11 environments
  environment.etc."X11/xinit/xinitrc".text = ''
    exec dwm
  '';

  # ===================== FLATPAK & SOBER ROBLOX =====================
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  systemd.services.install-sober = {
    description = "Install Sober Roblox";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      ${pkgs.flatpak}/bin/flatpak install -y flathub org.vinegarhq.Sober || true
    '';
  };

  # ===================== PACKAGES =====================
  environment.systemPackages = with pkgs; [
    # System & Terminal
    git wget gnumake gcc xterm xorg.xinit dmenu st
    librewolf fastfetch htop pavucontrol
    
    # Wayland Essentials (Needed for Hyprland & Vim integration)
    wl-clipboard 
    waybar
    rofi
    vim
    doas
    kitty
    appimage-run
    vesktop
    file-roller
    xfce.thunar
    xfce.tumbler

    # Window Manager
    dwm
    
    # Gaming & Dependencies
    steam gamemode mangohud lutris wineWowPackages.stable
    jre8 # Required for old 1.16.5+ Minecraft Clients
    
    temurin-bin-8   # LiquidBounce 1.8.9
    temurin-bin-17  # LiquidBounce 1.16.5+
    temurin-bin-21  # Modern Fabric/Forge Clients
  ];

  # ===================== HARDCORE LATENCY ENVIRONMENT VARIABLES =====================
  environment.variables = {
    "__GL_MaxFramesAllowed" = "1";       # Eliminates NVIDIA pre-rendered frame lag
    "__GL_THREADED_OPTIMIZATIONS" = "1"; # Multi-threads OpenGL tasks (Huge for Minecraft)
    "PROMPT_COMMAND" = "";               # Slight terminal speedup
  };

  # Prevent client crash due to heavy mod assets file handle exhaustion
  security.pam.loginLimits = [
    { domain = "@wheel"; item = "nofile"; type = "soft"; value = "524288"; }
    { domain = "@wheel"; item = "nofile"; type = "hard"; value = "524288"; }
  ];

  # ===================== USER & OPTIMIZATION =====================
  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "gamemode" ];
  };

  zramSwap.enable = true;
  services.ananicy.enable = true;
  services.ananicy.package = pkgs.ananicy-cpp;

  system.stateVersion = "24.11";
}
