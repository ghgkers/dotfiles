{ config, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Overlays for Chaotic-Nyx and custom DWM patches
  nixpkgs.overlays = [
    inputs.chaotic.overlays.default
    (self: super: {
      dwm = super.dwm.overrideAttrs (o: {
        postPatch = ''
          sed -i "/static const char \*termcmd/a static const char *vdn[]={ \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%-\", NULL };\nstatic const char *vup[]={ \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%+\", NULL };" config.def.h
        '';
      });
    })
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Stylix UI Theming
  stylix = {
    enable = true;
    image = /home/dx3d/Downloads/zam.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/shades-of-purple.yaml";
    cursor = { package = pkgs.bibata-cursors; name = "Bibata-Modern-Ice"; size = 24; };
    opacity.terminal = 0.8;
  };

  # Bootloader and Kernel (CachyOS + NVIDIA Fixes)
  boot = {
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    kernelParams = [ 
      "modprobe.blacklist=i2c_hid_acpi" 
      "nvidia-drm.modeset=1" 
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    kernelPackages = pkgs.linuxPackages_cachyos;
  };

  networking.hostName = "nix";
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # NVIDIA Graphics Configuration
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false; 
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # System Services
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      windowManager.dwm.enable = true;
      xkb = { layout = "us,ru"; options = "grp:win_space_toggle"; };
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;
    asusd.enable = true;
    libinput.enable = true;
  };

  # User Configuration
  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    packages = with pkgs; [
      st kitty hyprland waybar fastfetch vesktop ayugram-desktop 
      librewolf pavucontrol wofi yazi micro git gh dmenu 
      htop brightnessctl flameshot xclip wireplumber lm_sensors 
      gawk xsetroot procps thunar appimage-run acpi
    ];
  };

  # Programs and Aliases
  programs = {
    steam.enable = true;
    gamemode.enable = true;
    hyprland.enable = true;
    bash.shellAliases = {
      dotsync = "cd ~/dotfiles && sudo cp /etc/nixos/configuration.nix . && sudo cp /etc/nixos/hardware-configuration.nix . && sudo cp /etc/nixos/flake.nix . && cp -r ~/.config/hypr . && cp -r ~/.config/waybar . && git add . && git commit -m \"update:$(date +'%Y-%m-%d %H:%M')\" && git pull origin main --rebase && git push origin main && cd -";
      clean = "sudo nix-collect-garbage -d";
    };
  };

  system.stateVersion = "25.11";
}
