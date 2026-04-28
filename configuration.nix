{config,pkgs,...}:{
imports=[./hardware-configuration.nix(import(builtins.fetchTarball"https://github.com/danth/stylix/archive/release-24.11.tar.gz")).nixosModules.stylix];
stylix={enable=true;image=/home/dx3d/Downloads/zam.jpg;polarity="dark";base16Scheme="${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";cursor={package=pkgs.bibata-cursors;name="Bibata-Modern-Ice";};opacity.terminal=0.8;};
nix.settings.auto-optimise-store=true;
nix.gc={automatic=true;dates="weekly";options="--delete-older-than 7d";};
zramSwap.enable=true;
programs.appimage={enable=true;binfmt=true;};
programs.gamemode.enable=true;
programs.hyprland.enable=true;
programs.steam={enable=true;remotePlay.openFirewall=true;dedicatedServer.openFirewall=true;};
boot.loader.systemd-boot.enable=true;
boot.loader.efi.canTouchEfiVariables=true;
boot.kernelParams=["modprobe.blacklist=i2c_hid_acpi"];
boot.kernelPackages=pkgs.linuxPackages_zen;
networking.hostName="nix";
networking.networkmanager.enable=true;
nixpkgs.config.allowUnfree=true;
services.xserver={enable=true;videoDrivers=["nvidia"];windowManager.dwm.enable=true;xkb={layout="us,ru";options="grp:win_space_toggle";};};
hardware.nvidia={open=true;modesetting.enable=true;};
services.asusd={enable=true;enableUserService=true;};
services.tlp.enable=true;
services.flatpak.enable=true;
services.gvfs.enable=true;
services.udisks2.enable=true;
i18n.defaultLocale="en_US.UTF-8";
console={font="Lat2-Terminus16";keyMap="us";};
environment.sessionVariables={WLR_NO_HARDWARE_CURSORS="1";NIXOS_OZONE_WL="1";FASTFETCH_LOGO_TYPE="kitty";};
users.users.dx3d={isNormalUser=true;extraGroups=["wheel" "networkmanager" "video" "audio"];packages=with pkgs;[ghostty imagemagick kitty hyprland waybar st dmenu vim asusctl fastfetch vesktop ayugram-desktop librewolf xorg-server pavucontrol wofi yazi flatpak micro nitch wl-clipboard appimage-run git gh pkg-config hyprpaper htop xfce.thunar xfce.thunar-volman xfce.thunar-archive-plugin brightnessctl base16-schemes flameshot xclip wireplumber acpi lm_sensors gawk procps xorg.xsetroot];};
system.stateVersion="25.11";
system.activationScripts.ff={text=''
m=/home/dx3d/.config/fastfetch
mkdir -p $m
echo '{"logo":{"type":"kitty","source":"/home/dx3d/Downloads/nixos-logo.png","width":28,"height":12},"display":{"separator":" ➜ "},"modules":["title","separator","os","kernel","packages","shell","break","wm","cursor","terminal","break","colors"]}' > $m/config.jsonc
chown -R dx3d:users $m
'';deps=[];};
programs.bash.shellAliases={dotsync="cd ~/dotfiles&&sudo cp /etc/nixos/*.nix .&&git add .&&git commit -m 'upd'&&git push origin main&&cd -";clean="sudo nix-collect-garbage -d";};
nixpkgs.overlays=[(self: super: {dwm=super.dwm.overrideAttrs(o: {postPatch=''
sed -i 's/static const char \*termcmd\[\]  = { "st", NULL };/static const char *termcmd[] = { "ghostty", NULL };/' config.def.h
sed -i 's/#005577/#8f3f71/g' config.def.h
sed -i '1i #include <X11/XF86keysym.h>' config.def.h
sed -i "/static const char \*termcmd/a static const char *vdn[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%-\", NULL };" config.def.h
sed -i "/static const char \*termcmd/a static const char *vup[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%+\", NULL };" config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioLowerVolume, spawn, {.v = vdn}}," config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioRaiseVolume, spawn, {.v = vup}}," config.def.h
'';});})];
services.libinput={enable=true;touchpad.disableWhileTyping=true;};
services.xserver.displayManager.sessionCommands=''
${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 165
while true;do
v=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@|awk '{print int($2*100)"%"}')
${pkgs.xorg.xsetroot}/bin/xsetroot -name "Vol:$v | $(date +'%H:%M')"
sleep 2
done&
'';}
