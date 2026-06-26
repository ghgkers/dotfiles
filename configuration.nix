{ config, pkgs, inputs, lib, ... }:
let
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
  imports = [ ]; 

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Almaty";

  security.sudo.enable = false;
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "dx3d" ];
    keepEnv = true;
    persist = true;
  }];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_cachyos;
    kernel.sysctl = sysctlTweaks;
    supportedFilesystems = [ "fuse" ];
  };
  
  powerManagement.cpuFreqGovernor = "performance";
  zramSwap.enable = true;
  
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 64;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 1024;
      };
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm;
    };
    xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle";
    };
  };

  console.useXkbConfig = true;
  environment.etc."X11/xinit/xinitrc".text = ''
    exec dwm
  '';

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

  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "gamemode" ];
  };

  environment.variables = {
    "__GL_MaxFramesAllowed" = "1";
    "__GL_THREADED_OPTIMIZATIONS" = "1";
    "PROMPT_COMMAND" = "";
  };

  security.pam.loginLimits = [
    { domain = "@wheel"; item = "nofile"; type = "soft"; value = "524288"; }
    { domain = "@wheel"; item = "nofile"; type = "hard"; value = "524288"; }
  ];

  environment.systemPackages = with pkgs; [
    git wget gnumake gcc xterm xorg.xinit dmenu st doas
    librewolf fastfetch htop pavucontrol appimage-run file-roller
    waybar rofi vim kitty vesktop xfce.thunar xfce.tumbler
    steam gamemode mangohud lutris wineWowPackages.stable
    jre8 temurin-bin-8 temurin-bin-17 temurin-bin-21
  ];

  system.stateVersion = "24.11";
}
