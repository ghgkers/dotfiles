{config,pkgs,...}:{
imports=[./hardware-configuration.nix (import (builtins.fetchTarball "https://github.com/danth/stylix/archive/release-24.11.tar.gz")).nixosModules.stylix];
stylix={enable=true;image=/home/dx3d/Downloads/zam.jpg;polarity="dark";base16Scheme="${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";cursor={package=pkgs.bibata-cursors;name="Bibata-Modern-Ice";};opacity.terminal=0.8;};
boot.loader.systemd-boot.enable=true;
boot.loader.efi.canTouchEfiVariables=true;
boot.kernelParams=["modprobe.blacklist=i2c_hid_acpi"];
networking.hostName="nix";
networking.networkmanager.enable=true;
nixpkgs.config.allowUnfree=true;
services.xserver.videoDrivers=["nvidia"];
services.asusd={enable=true;enableUserService=true;};
services.xserver.xkb={layout="us,ru";variant="";options="grp:win_space_toggle";};
i18n.defaultLocale="en_US.UTF-8";
console={font="Lat2-Terminus16";keyMap="us";};
hardware.nvidia.open=true;
environment.sessionVariables={WLR_NO_HARDWARE_CURSORS="1";NIXOS_OZONE_WL="1";};
users.users.dx3d={isNormalUser=true;extraGroups=["wheel" "networkmanager" "video" "audio"];packages=with pkgs;[kitty hyprland waybar st dmenu vim asusctl fastfetch vesktop dwm ayugram-desktop librewolf xorg-server pavucontrol wofi yazi flatpak micro nitch wl-clipboard appimage-run git gh pkg-config hyprpaper gamemode htop xfce.thunar xfce.thunar-volman xfce.thunar-archive-plugin brightnessctl base16-schemes flameshot xclip];};
programs.hyprland.enable=true;
programs.steam={enable=true;remotePlay.openFirewall=true;dedicatedServer.openFirewall=true;};
services.flatpak.enable=true;
system.activationScripts.flatpak-setup={text=''${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
${pkgs.flatpak}/bin/flatpak install -y flathub org.vinegarhq.Sober'';};
system.stateVersion="25.11";
services.gvfs.enable=true;
services.udisks2.enable=true;
services.picom={enable=true;backend="glx";vSync=true;activeOpacity=0.92;inactiveOpacity=0.85;fade=true;fadeDelta=5;settings={corner-radius=12;blur={method="dual_kawase";strength=5;};shadow=true;shadow-radius=12;shadow-offset-x=-12;shadow-offset-y=-12;unredir-if-possible=true;};};
boot.kernelPackages=pkgs.linuxPackages_zen;
services.xserver={enable=true;windowManager.dwm.enable=true;};
programs.bash.shellAliases={dotsync="cd ~/dotfiles && sudo cp /etc/nixos/configuration.nix . && sudo cp /etc/nixos/hardware-configuration.nix . && cp -r ~/.config/hypr . && cp -r ~/.config/waybar . && git add . && git commit -m \"update: $(date +'%Y-%m-%d %H:%M')\" && git push origin main && cd -";};
nixpkgs.overlays=[(self: super: {dwm=super.dwm.overrideAttrs(oldAttrs:{postPatch=''sed -i 's/#005577/#ff9e64/g' config.def.h
sed -i '1i #include <X11/XF86keysym.h>' config.def.h
sed -i "/static const char \*termcmd/a static const char *upvol[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%+\", NULL };\nstatic const char *downvol[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%-\", NULL };\nstatic const char *mutevol[] = { \"wpctl\", \"set-mute\", \"@DEFAULT_AUDIO_SINK@\", \"toggle\", NULL };\nstatic const char *brup[] = { \"brightnessctl\", \"set\", \"5%+\", NULL };\nstatic const char *brdown[] = { \"brightnessctl\", \"set\", \"5%-\", NULL };\nstatic const char *sscmd[] = { \"flameshot\", \"gui\", NULL };" config.def.h
sed -i "/static const Key keys/a {0,XK_Print,spawn,{.v=sscmd}}," config.def.h
sed -i "/static const Key keys/a {0,XF86XK_AudioRaiseVolume,spawn,{.v=upvol}}," config.def.h
sed -i "/static const Key keys/a {0,XF86XK_AudioLowerVolume,spawn,{.v=downvol}}," config.def.h
sed -i "/static const Key keys/a {0,XF86XK_AudioMute,spawn,{.v=mutevol}}," config.def.h
sed -i "/static const Key keys/a {0,XF86XK_MonBrightnessUp,spawn,{.v=brup}}," config.def.h
sed -i "/static const Key keys/a {0,XF86XK_MonBrightnessDown,spawn,{.v=brdown}}," config.def.h'';});})];
services.libinput={enable=true;touchpad.disableWhileTyping=true;touchpad.additionalOptions=''Option "Ignore" "on"'';};
}
