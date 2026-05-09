{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader – systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Standard kernel (no CachyOS) – avoids black‑screen risks
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [
    "nvidia-drm.modeset=0"    # keep the text console visible
  ];

  # NVIDIA – allow unfree, use stable driver, no modesetting in kernel
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Basic networking
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  # X11 without a display manager – we use startx
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb.layout = "us";
  };

  # Create .xinitrc that launches dwm
  systemd.tmpfiles.rules = [
    "L+ /home/dx3d/.xinitrc - - - - ${pkgs.writeText "xinitrc" ''
      #!/bin/sh
      exec ${pkgs.dwm}/bin/dwm
    ''}"
  ];

  # Packages needed for a basic graphical session + Librewolf
  environment.systemPackages = with pkgs; [
    xorg.xinit
    dwm
    st          # terminal
    librewolf   # browser to reach DeepSeek
  ];

  # User
  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Allow flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
