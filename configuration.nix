{config,pkgs,...}:{
imports=[./hardware-configuration.nix(import(builtins.fetchTarball"https://github.com/danth/stylix/archive/release-24.11.tar.gz")).nixosModules.stylix];
stylix={enable=true;image=/home/dx3d/Downloads/zam.jpg;polarity="dark";base16Scheme="${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";cursor={package=pkgs.bibata-cursors;name="Bibata-Modern-Ice";};opacity.terminal=0.8;};
nix.settings.auto-optimise-store=true;
nix.gc={automatic=true;dates="weekly";options="--delete-older-than 7d";};
zramSwap.enable=true;
boot={loader={systemd-boot.enable=true;efi.canTouchEfiVariables=true;};kernelParams=["modprobe.blacklist=i2c_hid_acpi"];kernelPackages=pkgs.linuxPackages_zen;};
networking={hostName="nix";networkmanager.enable=true;};
nixpkgs.config.allowUnfree=true;
hardware.nvidia={open=true;modesetting.enable=true;};
services={
  xserver={enable=true;videoDrivers=["nvidia"];windowManager.dwm.enable=true;xkb={layout="us,ru";options="grp:win_space_toggle";};};
  asusd={enable=true;enableUserService=true;};
  tlp.enable=true;
  flatpak.enable=true;
  gvfs.enable=true;
  udisks2.enable=true;
  libinput={enable=true;touchpad.disableWhileTyping=true;};
  picom={
    enable=true;
    backend="glx";
    vSync=true;
    activeOpacity=0.95;
    inactiveOpacity=0.88;
    fade=true;
    fadeDelta=4;
    settings={
      corner-radius=12;
      blur={method="dual_kawase";strength=5;};
      shadow=true;
      experimental-backends=true;
    };
  };
};
environment.sessionVariables={WLR_NO_HARDWARE_CURSORS="1";NIXOS_OZONE_WL="1";};
users.users.dx3d={isNormalUser=true;extraGroups=["wheel" "networkmanager" "video" "audio"];
packages=with pkgs;[ghostty kitty fastfetch vesktop ayugram-desktop librewolf pavucontrol wofi yazi micro nitch wl-clipboard git htop brightnessctl flameshot xclip wireplumber lm_sensors gawk xorg.xsetroot acpi procps xfce.thunar];};
programs={steam.enable=true;gamemode.enable=true;hyprland.enable=true;};
system.stateVersion="25.11";
nixpkgs.overlays=[(self: super: {dwm=super.dwm.overrideAttrs(old:{postPatch=''
  sed -i 's/"st"/"ghostty"/' config.def.h
  sed -i 's/MODKEY|ShiftMask,           XK_c,      killclient,     {0}/MODKEY|ShiftMask,           XK_c,      killclient,     {0}/' config.def.h
  sed -i '/static const char \*termcmd/a static const char *vdn[]={"wpctl","set-volume","@DEFAULT_AUDIO_SINK@","5%-",NULL};\nstatic const char *vup[]={"wpctl","set-volume","@DEFAULT_AUDIO_SINK@","5%+",NULL};' config.def.h
  sed -i '/static const Key keys/a {0,0x1008ff11,spawn,{.v=vdn}},\n{0,0x1008ff13,spawn,{.v=vup}},' config.def.h
'';});})];
system.activationScripts.fastfetch-config.text=''
  m=/home/dx3d/.config/fastfetch
  mkdir -p $m
  echo '{"logo":{"type":"kitty-direct","source":"/home/dx3d/Downloads/zam.jpg","width":28,"height":12},"modules":["title","os","kernel","packages","wm","terminal","cpu","gpu","memory"]}' > $m/config.jsonc
  chown -R dx3d:users $m
'';
services.xserver.displayManager.sessionCommands=''
${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 165
while true;do
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@|awk '{print int($2*100)"%"}')
bat=$(acpi -b|awk '{print $4}'|tr -d ',')
${pkgs.xorg.xsetroot}/bin/xsetroot -name "Vol:$vol | Bat:$bat | $(date +'%H:%M')"
sleep 2
done&
'';
}
