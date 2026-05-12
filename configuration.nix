{ config, pkgs, inputs, lib, ... }:
let
  # Фиксируем коммит sowm, чтобы хеш не слетал
  mySowm = pkgs.stdenv.mkDerivation {
    pname = "sowm";
    version = "2024-03-20"; 
    src = pkgs.fetchFromGitHub {
      owner = "dylanaraps";
      repo = "sowm";
      rev = "9f276136be070c7e2e30737190038c8230722361"; # Конкретный коммит
      sha256 = "sha256-Q65sU5K86pFk3QNlzfxgyoEw6NpBaZQmFOkUFnmoh+U=";
    };
    buildInputs = with pkgs; [ libX11 libXinerama ];
    nativeBuildInputs = with pkgs; [ gcc gnumake ];
    installPhase = "mkdir -p $out/bin; make PREFIX=$out install";
  };

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

  # ЭТО ВАЖНО: включаем flakes внутри конфига
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ===================== BOOT & KERNEL =====================
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    
    # Используем проверенное ядро из chaotic-nyx
    kernelPackages = pkgs.linuxPackages_cachyos; 

    kernelParams = [
      "nvidia-drm.modeset=1" # ВКЛЮЧАЕМ для стабильности на ROG Strix
      "nvme_load=YES"
    ];
    kernel.sysctl = sysctlTweaks;
  };

  # ===================== NVIDIA =====================
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Твой выбор, работает хорошо на новых картах
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # Для ноутбуков ASUS
  services.asusd.enable = true;
  services.asusd.enableUserService = true;

  # ===================== MEMORY & PERF =====================
  zramSwap.enable = true;
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp; # Более быстрая версия на C++
  };

  # ===================== GUI & WM =====================
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true; # Чтобы заходить через TTY -> startx
    xkb.layout = "us,ru";
  };

  # Автоматический .xinitrc (исправлено)
  environment.etc."X11/xinit/xinitrc".text = ''
    exec ${mySowm}/bin/sowm
  '';

  # ===================== PACKAGES =====================
  environment.systemPackages = with pkgs; [
    xorg.xinit xterm dmenu st
    librewolf
    steam gamemode mangohud
    flatpak # Для Roblox (Sober)
    fastfetch htop
    git wget # Для работы с конфигом
  ];

  # ===================== ROBLOX (SOBER) =====================
  services.flatpak.enable = true;
  # Оставляем твой скрипт, он рабочий, но добавим проверку сети
  systemd.services.install-sober = {
    description = "Install Sober";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      ${pkgs.flatpak}/bin/flatpak install -y flathub org.vinegarhq.Sober || true
    '';
  };

  # Остальные твои настройки (пользователь dx3d, аудио и т.д.)
  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "gamemode" ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  networking.networkmanager.enable = true;
  system.stateVersion = "24.05"; # Используй стабильную метку
}
