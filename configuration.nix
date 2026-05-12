{ config, pkgs, inputs, lib, ... }:
let
  # Фиксируем коммит sowm для стабильности
  mySowm = pkgs.stdenv.mkDerivation {
    pname = "sowm";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "dylanaraps";
      repo = "sowm";
      rev = "9f276136be070c7e2e30737190038c8230722361";
      sha256 = "sha256-Q65sU5K86pFk3QNlzfxgyoEw6NpBaZQmFOkUFnmoh+U=";
    };
    buildInputs = with pkgs; [ libX11 libXinerama ];
    nativeBuildInputs = with pkgs; [ gcc gnumake ];
    installPhase = "mkdir -p $out/bin; make PREFIX=$out install";
  };

  # Твики системы для гейминга
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

  # ===================== ОСНОВНЫЕ НАСТРОЙКИ =====================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "nix-gaming";
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Almaty"; # Настрой под себя

  # ===================== ЯДРО И ЗАГРУЗКА =====================
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    
    # Используем CachyOS ядро (требует chaotic-nyx во flake.nix)
    kernelPackages = pkgs.linuxPackages_cachyos; 

    kernelParams = [ "nvidia-drm.modeset=1" ];
    kernel.sysctl = sysctlTweaks;
  };

  # ===================== HARDWARE (ASUS & NVIDIA) =====================
  services.asusd.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ===================== ЗВУК И ПЕРИФЕРИЯ =====================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ===================== ГРАФИКА (X11 + sowm) =====================
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    xkb.layout = "us,ru";
    xkb.options = "grp:win_space_toggle";
  };

  # Создаем .xinitrc для запуска sowm
  environment.etc."X11/xinit/xinitrc".text = ''
    exec ${mySowm}/bin/sowm
  '';

  # ===================== FLATPAK & FIX (ДЛЯ SOBER) =====================
  services.flatpak.enable = true;
  
  # ТОТ САМЫЙ ФИКС ОШИБКИ:
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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

  # ===================== ПАКЕТЫ =====================
  environment.systemPackages = with pkgs; [
    # Система
    git wget gnumake gcc xorg.xinit xterm dmenu st
    librewolf fastfetch htop pavucontrol
    
    # Гейминг
    steam gamemode mangohud lutris wineWowPackages.stable
    
    # Твой WM
    mySowm
  ];

  # ===================== ПОЛЬЗОВАТЕЛЬ =====================
  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "gamemode" ];
  };

  # Оптимизации
  zramSwap.enable = true;
  services.ananicy.enable = true;
  services.ananicy.package = pkgs.ananicy-cpp;

  system.stateVersion = "24.11";
}
