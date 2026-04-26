{ config, pkgs, ... }:
{
imports = [ ./hardware-configuration.nix ];
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
networking.hostName = "nix";
networking.networkmanager.enable = true;
nixpkgs.config.allowUnfree = true;
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia.open = true;
environment.sessionVariables = {
WLR_NO_HARDWARE_CURSORS = "1";
NIXOS_OZONE_WL = "1";
};
users.users.dx3d = {
isNormalUser = true;
extraGroups = [ "wheel"  "networkmanager" ];
packages = with pkgs; [kitty hyprland waybar st dmenu vim asusctl fastfetch vesktop dwm ayugram-desktop librewolf wofi yazi flatpak micro nitch wl-clipboard git gh hyprpaper gamemode htop xfce.thunar xfce.thunar-volman xfce.thunar-archive-plugin ];
};
programs.hyprland.enable = true;
programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
services.flatpak.enable = true;
system.stateVersion = "25.11";
services.gvfs.enable = true; 
services.udisks2.enable = true;
boot.kernelPackages = pkgs.linuxPackages_zen;
services.xserver = {
enable = true;
windowManager.dwm.enable = true;
};
programs.bash.shellAliases = {
dotsync = "cd ~/dotfiles && sudo cp /etc/nixos/configuration.nix . && sudo cp /etc/nixos/hardware-configuration.nix . && cp -r ~/.config/hypr . && cp -r ~/.config/waybar . && git add . && git commit -m \"update: $(date +'%Y-%m-%d %H:%M')\" && git push origin main && cd -";
};
services.libinput = {
  enable = true;
  touchpad.disableWhileTyping = true;
  touchpad.additionalOptions = ''Option "Ignore" "on"'';
};
}

