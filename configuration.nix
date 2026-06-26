{ config, pkgs, inputs, lib, ... }:
let
  sysctlTweaks = {
    "vm.vfs_cache_pressure" = 500;[cite: 3]
    "vm.swappiness" = 10;[cite: 3]
    "kernel.sched_child_runs_first" = 1;[cite: 3]
    "kernel.sched_autogroup_enabled" = 0;[cite: 3]
    "net.core.default_qdisc" = "cake";[cite: 3]
    "net.ipv4.tcp_congestion_control" = "bbr";[cite: 3]
  };
in
{
  imports = [ ]; 

  nix.settings.experimental-features = [ "nix-command" "flakes" ];[cite: 3]
  nixpkgs.config.allowUnfree = true;[cite: 3]
  networking.networkmanager.enable = true;[cite: 3]
  time.timeZone = "Asia/Almaty";[cite: 3]

  security.sudo.enable = false;[cite: 3]
  security.doas.enable = true;[cite: 3]
  security.doas.extraRules = [{
    users = [ "dx3d" ];[cite: 3]
    keepEnv = true;[cite: 3]
    persist = true;[cite: 3]
  }];

  boot = {
    loader.systemd-boot.enable = true;[cite: 3]
    loader.efi.canTouchEfiVariables = true;[cite: 3]
    kernelPackages = pkgs.linuxPackages_cachyos;[cite: 3]
    kernel.sysctl = sysctlTweaks;[cite: 3]
    supportedFilesystems = [ "fuse" ];[cite: 3]
  };
  
  powerManagement.cpuFreqGovernor = "performance";[cite: 3]
  zramSwap.enable = true;[cite: 3]
  
  services.ananicy = {
    enable = true;[cite: 3]
    package = pkgs.ananicy-cpp;[cite: 3]
  };

  services.pipewire = {
    enable = true;[cite: 3]
    alsa.enable = true;[cite: 3]
    alsa.support32Bit = true;[cite: 3]
    pulse.enable = true;[cite: 3]
    
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;[cite: 3]
        "default.clock.quantum" = 64;[cite: 3]
        "default.clock.min-quantum" = 32;[cite: 3]
        "default.clock.max-quantum" = 1024;[cite: 3]
      };
    };
  };

  programs.hyprland = {
    enable = true;[cite: 3]
    xwayland.enable = true;[cite: 3]
  };

  services.displayManager.sddm = {
    enable = true;[cite: 3]
    wayland.enable = true;[cite: 3]
  };

  services.xserver = {
    enable = true;[cite: 3]
    displayManager.startx.enable = true;[cite: 3]
    windowManager.dwm = {
      enable = true;[cite: 3]
      package = pkgs.dwm;[cite: 3]
    };
    xkb = {
      layout = "us,ru";[cite: 3]
      options = "grp:win_space_toggle";[cite: 3]
    };
  };

  console.useXkbConfig = true;[cite: 3]
  environment.etc."X11/xinit/xinitrc".text = ''
    exec dwm
  '';[cite: 3]

  services.flatpak.enable = true;[cite: 3]
  xdg.portal = {
    enable = true;[cite: 3]
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];[cite: 3]
    config.common.default = "*";[cite: 3]
  };

  systemd.services.install-sober = {
    description = "Install Sober Roblox";[cite: 3]
    after = [ "network-online.target" ];[cite: 3]
    wants = [ "network-online.target" ];[cite: 3]
    wantedBy = [ "multi-user.target" ];[cite: 3]
    serviceConfig.Type = "oneshot";[cite: 3]
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      ${pkgs.flatpak}/bin/flatpak install -y flathub org.vinegarhq.Sober || true
    '';[cite: 3]
  };

  users.users.dx3d = {
    isNormalUser = true;[cite: 3]
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "gamemode" ];[cite: 3]
  };

  environment.variables = {
    "__GL_MaxFramesAllowed" = "1";[cite: 3]
    "__GL_THREADED_OPTIMIZATIONS" = "1";[cite: 3]
    "PROMPT_COMMAND" = "";[cite: 3]
  };

  security.pam.loginLimits = [
    { domain = "@wheel"; item = "nofile"; type = "soft"; value = "524288"; }[cite: 3]
    { domain = "@wheel"; item = "nofile"; type = "hard"; value = "524288"; }[cite: 3]
  ];

  environment.systemPackages = with pkgs; [
    git wget gnumake gcc xterm xorg.xinit dmenu st doas[cite: 3]
    librewolf fastfetch htop pavucontrol appimage-run file-roller[cite: 3]
    waybar rofi vim kitty vesktop xfce.thunar xfce.tumbler[cite: 3]
    steam gamemode mangohud lutris wineWowPackages.stable[cite: 3]
    jre8 temurin-bin-8 temurin-bin-17 temurin-bin-21[cite: 3]
  ];

  system.stateVersion = "24.11";[cite: 3]
}
