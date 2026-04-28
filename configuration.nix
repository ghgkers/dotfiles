{config,pkgs,...}:{
imports=[./hardware-configuration.nix (import (builtins.fetchTarball "https://github.com/danth/stylix/archive/release-24.11.tar.gz")).nixosModules.stylix];
stylix={enable=true;image=/home/dx3d/Downloads/zam.jpg;polarity="dark";base16Scheme="${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";cursor={package=pkgs.bibata-cursors;name="Bibata-Modern-Ice";};opacity.terminal=0.8;};
boot.loader.systemd-boot.enable=true;
boot.loader.efi.canTouchEfiVariables=true;
boot.kernelParams=["modprobe.blacklist=i2c_hid_acpi"];
boot.kernelPackages=pkgs.linuxPackages_zen;
networking.hostName="nix";
networking.networkmanager.enable=true;
nixpkgs.config.allowUnfree=true;
services.xserver={enable=true;videoDrivers=["nvidia"];windowManager.dwm.enable=true;xkb={layout="us,ru";options="grp:win_space_toggle";};displayManager.sessionCommands=''${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 165'';};
hardware.nvidia={open=true;modesetting.enable=true;};
services.asusd={enable=true;enableUserService=true;};
i18n.defaultLocale="en_US.UTF-8";
console={font="Lat2-Terminus16";keyMap="us";};
environment.sessionVariables={WLR_NO_HARDWARE_CURSORS="1";NIXOS_OZONE_WL="1";};
users.users.dx3d={isNormalUser=true;extraGroups=["wheel" "networkmanager" "video" "audio"];packages=with pkgs;[kitty hyprland waybar st dmenu vim asusctl fastfetch vesktop dwm ayugram-desktop librewolf xorg-server pavucontrol wofi yazi flatpak micro nitch wl-clipboard appimage-run git gh pkg-config hyprpaper gamemode htop xfce.thunar xfce.thunar-volman xfce.thunar-archive-plugin brightnessctl base16-schemes flameshot xclip wireplumber];};
programs.hyprland.enable=true;
programs.steam={enable=true;remotePlay.openFirewall=true;dedicatedServer.openFirewall=true;};
services.flatpak.enable=true;
services.gvfs.enable=true;
services.udisks2.enable=true;
services.picom={enable=true;backend="glx";vSync=true;activeOpacity=0.92;inactiveOpacity=0.85;fade=true;fadeDelta=5;settings={corner-radius=12;blur={method="dual_kawase";strength=5;};shadow=true;};};
system.stateVersion="25.11";
programs.bash.shellAliases={dotsync="cd ~/dotfiles && sudo cp /etc/nixos/configuration.nix . && sudo cp /etc/nixos/hardware-configuration.nix . && cp -r ~/.config/hypr . && cp -r ~/.config/waybar . && git add . && git commit -m \"update: $(date +'%Y-%m-%d %H:%M')\" && git push origin main && cd -";};
nixpkgs.overlays=[(self: super: {dwm=super.dwm.overrideAttrs(oldAttrs:{postPatch=''
sed -i '1i #include <X11/XF86keysym.h>' config.def.h
sed -i "/static const char \*termcmd/a static const char *vdn[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%-\", NULL };\nstatic const char *vup[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%+\", NULL };\nstatic const char *mutmic[] = { \"wpctl\", \"set-mute\", \"@DEFAULT_AUDIO_SOURCE@\", \"toggle\", NULL };" config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioLowerVolume, spawn, {.v = vdn}}," config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioRaiseVolume, spawn, {.v = vup}}," config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioMicMute, spawn, {.v = mutmic}}," config.def.h
'';});})];
services.libinput={enable=true;touchpad.disableWhileTyping=true;};
}
