{config,pkgs,...}:{
imports=[./hardware-configuration.nix(import(builtins.fetchTarball"https://github.com/danth/stylix/archive/release-24.11.tar.gz")).nixosModules.stylix];
stylix={enable=true;image=/home/dx3d/Downloads/zam.jpg;polarity="dark";base16Scheme="${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";cursor={package=pkgs.bibata-cursors;name="Bibata-Modern-Ice";};opacity.terminal=0.8;};
nix.settings.auto-optimise-store=true;
nix.gc={automatic=true;dates="weekly";options="--delete-older-than 7d";};
zramSwap.enable=true;
programs.appimage={enable=true;binfmt=true;};
programs.gamemode.enable=true;
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
i18n.defaultLocale="en_US.UTF-8";
console={font="Lat2-Terminus16";keyMap="us";};
environment.sessionVariables={WLR_NO_HARDWARE_CURSORS="1";NIXOS_OZONE_WL="1";};
users.users.dx3d={isNormalUser=true;extraGroups=["wheel" "networkmanager" "video" "audio"];packages=with pkgs;[ghostty kitty hyprland waybar st dmenu vim asusctl fastfetch vesktop ayugram-desktop librewolf xorg-server pavucontrol wofi yazi flatpak micro nitch wl-clipboard appimage-run git gh pkg-config hyprpaper htop xfce.thunar xfce.thunar-volman xfce.thunar-archive-plugin brightnessctl base16-schemes flameshot xclip wireplumber acpi lm_sensors gawk procps xorg.xsetroot];};
programs.hyprland.enable=true;
programs.steam={enable=true;remotePlay.openFirewall=true;dedicatedServer.openFirewall=true;};
services.flatpak.enable=true;
services.gvfs.enable=true;
services.udisks2.enable=true;
services.picom={enable=true;backend="glx";vSync=true;activeOpacity=0.92;inactiveOpacity=0.85;fade=true;fadeDelta=5;settings={corner-radius=12;blur={method="dual_kawase";strength=5;};shadow=true;};};
system.stateVersion="25.11";
system.activationScripts={
backup-config={text="cp /etc/nixos/configuration.nix /home/dx3d/config_backup_$(date +%Y%m%d_%H%M%S).nix||true";deps=[];};
fastfetch-config={text="rm -f /home/dx3d/.config/fastfetch/config.jsonc&&mkdir -p /home/dx3d/.config/fastfetch&&echo '{\"logo\":{\"type\":\"iterm\",\"source\":\"/home/dx3d/Downloads/zam.jpg\",\"width\":28,\"height\":12,\"padding\":{\"top\":1}},\"display\":{\"separator\":\"  ➜  \",\"color\":\"magenta\"},\"modules\":[{\"type\":\"title\",\"color\":{\"user\":\"blue\",\"at\":\"red\",\"host\":\"cyan\"}},\"separator\",{\"type\":\"os\",\"key\":\"OS \",\"keyColor\":\"red\"},{\"type\":\"kernel\",\"key\":\"  kernel  \",\"keyColor\":\"red\"},{\"type\":\"packages\",\"key\":\"  packages\",\"keyColor\":\"red\"},{\"type\":\"shell\",\"key\":\"  shell   \",\"keyColor\":\"red\"},\"break\",{\"type\":\"wm\",\"key\":\"WM \",\"keyColor\":\"green\"},{\"type\":\"cursor\",\"key\":\"  cursor  \",\"keyColor\":\"green\"},{\"type\":\"terminal\",\"key\":\"  terminal\",\"keyColor\":\"green\"},{\"type\":\"font\",\"key\":\"  font    \",\"keyColor\":\"green\"},\"break\",{\"type\":\"host\",\"key\":\"PC \",\"keyColor\":\"yellow\"},{\"type\":\"cpu\",\"key\":\"  cpu     \",\"keyColor\":\"yellow\"},{\"type\":\"gpu\",\"key\":\"  gpu     \",\"keyColor\":\"yellow\"},{\"type\":\"memory\",\"key\":\"  memory  \",\"keyColor\":\"yellow\"},{\"type\":\"disk\",\"key\":\"  disk    \",\"keyColor\":\"yellow\"},{\"type\":\"display\",\"key\":\"  monitor \",\"keyColor\":\"yellow\"},\"break\",\"colors\"]}'>/home/dx3d/.config/fastfetch/config.jsonc&&chown dx3d:users /home/dx3d/.config/fastfetch/config.jsonc";deps=[];};
};
programs.bash.shellAliases={dotsync="cd ~/dotfiles&&sudo cp /etc/nixos/configuration.nix .&&sudo cp /etc/nixos/hardware-configuration.nix .&&cp -r ~/.config/hypr .&&cp -r ~/.config/waybar .&&git add .&&git commit -m \"update:$(date +'%Y-%m-%d %H:%M')\"&&git push origin main&&cd -";clean="sudo nix-collect-garbage -d";};
nixpkgs.overlays=[(self: super: {dwm=super.dwm.overrideAttrs(oldAttrs:{postPatch=''
sed -i 's/static const char \*termcmd\[\]  = { "st", NULL };/static const char *termcmd[] = { "ghostty", NULL };/' config.def.h
sed -i 's/#005577/#8f3f71/g' config.def.h
sed -i 's/#222222/#282828/g' config.def.h
sed -i 's/#bbbbbb/#ebdbb2/g' config.def.h
sed -i 's/#eeeeee/#282828/g' config.def.h
sed -i '1i #include <X11/XF86keysym.h>' config.def.h
sed -i "/static const char \*termcmd/a static const char *vdn[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%-\", NULL };\nstatic const char *vup[] = { \"wpctl\", \"set-volume\", \"@DEFAULT_AUDIO_SINK@\", \"5%+\", NULL };\nstatic const char *mutmic[] = { \"wpctl\", \"set-mute\", \"@DEFAULT_AUDIO_SOURCE@\", \"toggle\", NULL };" config.def.h
sed -i "/static const Key keys/a {MODKEY|ShiftMask, XK_c, spawn, {.v = termcmd}}," config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioLowerVolume, spawn, {.v = vdn}}," config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioRaiseVolume, spawn, {.v = vup}}," config.def.h
sed -i "/static const Key keys/a {0, XF86XK_AudioMicMute, spawn, {.v = mutmic}}," config.def.h
'';});})];
services.libinput={enable=true;touchpad.disableWhileTyping=true;};
services.xserver.displayManager.sessionCommands=''
${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 165
while true;do
vol=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@|${pkgs.gawk}/bin/awk '{print int($2*100)"%"}')
bat=$(${pkgs.acpi}/bin/acpi -b|${pkgs.gawk}/bin/awk '{print $4}'|tr -d ',')
cpu=$(${pkgs.procps}/bin/top -bn1|grep "Cpu(s)"|${pkgs.gawk}/bin/awk '{print $2"%"}')
ram=$(${pkgs.procps}/bin/free -h|grep "Mem"|${pkgs.gawk}/bin/awk '{print $3"/"$2}')
dte=$(date +"%H:%M %d/%m")
${pkgs.xorg.xsetroot}/bin/xsetroot -name "Vol:$vol | Bat:$bat | CPU:$cpu | RAM:$ram | $dte"
sleep 2
done&
'';
}
