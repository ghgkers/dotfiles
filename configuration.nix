{ config, pkgs, inputs, lib, ... }:
let
  mySowm = pkgs.stdenv.mkDerivation {
    pname = "sowm";
    version = "master";
    src = pkgs.fetchFromGitHub {
      owner = "dylanaraps";
      repo = "sowm";
      rev = "master";
      sha256 = "sha256-Q65sU5K86pFk3QNlzfxgyoEw6NpBaZQmFOkUFnmoh+U=";
    };
    buildInputs = with pkgs; [ libx11 libxinerama ];
    nativeBuildInputs = with pkgs; [ gcc gnumake ];
    installPhase = "mkdir -p $out/bin; make PREFIX=$out install";
  };

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
in
{
  imports = [ ./hardware-configuration.nix ];

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

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_cachyos;
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "modprobe.blacklist=i2c_hid_acpi,i2c_hid,bluetooth,btusb,uvcvideo,usblp,lp"
    ];
    kernel.sysctl = {
      "vm.vfs_cache_pressure" = 500;
      "vm.swappiness" = 10;
    };
  };

  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  documentation.enable = false;
  documentation.nixos.enable = false;
  environment.defaultPackages = lib.mkForce [];

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  environment.variables._JAVA_OPTIONS = mcFlags;

  services.fstrim.enable = true;
  services.dbus.implementation = "broker";
  services.logind.settings.Login.NAutoVTs = 1;
  services.journald.extraConfig = "SystemMaxUse=50M";

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ASUS control (correct way – no hardware.asusctl)
  services.asusd.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb = {
      layout = "us,ru";
      options = "grp:win_space_toggle";
    };
    # Default window manager
    windowManager.default = "sowm";
  };

  # Custom session for sowm (NixOS has no built-in sowm module)
  services.displayManager.session = [{
    manage = "desktop";
    name = "sowm";
    start = ''
      ${mySowm}/bin/sowm &
      exec ${pkgs.xorg.xrandr}/bin/xrandr --auto
    '';
  }];

  services.displayManager.ly.enable = true;

  programs = {
    steam.enable = true;
    gamemode = {
      enable = true;
      settings.general.renice = 10;
    };
    gamescope.enable = true;
    bash.shellAliases = {
      dotsync = "cd ~/dotfiles && sudo cp /etc/nixos/configuration.nix . && sudo cp /etc/nixos/hardware-configuration.nix . && sudo cp /etc/nixos/flake.nix . && git add . && git commit -m \"update:$(date +'%Y-%m-%d %H:%M')\" && git pull origin main --rebase && git push origin main && cd -";
      clean = "sudo nix-collect-garbage -d";
      v = "nvim";
    };
  };

  users.users.dx3d = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    packages = with pkgs; [
      mySowm st scrot vesktop micro git gh feh appimage-run
      pavucontrol dmenu xclip flatpak librewolf fastfetch
      mangohud pciutils asusctl temurin-bin-25
      xorg.xorgserver xorg.xinput config.boot.kernelPackages.nvidiaPackages.stable.settings
    ];
  };

  # One‑time Sober installation
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

  system.stateVersion = "25.11";
}
