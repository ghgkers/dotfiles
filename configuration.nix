{config,pkgs,...}:{
imports=[./hardware-configuration.nix (import(builtins.fetchTarball"https://github.com/danth/stylix/archive/release-24.11.tar.gz")).nixosModules.stylix];
stylix={enable=true;image=/home/dx3d/Downloads/zam.jpg;polarity="dark";base16Scheme="${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";cursor={package=pkgs.bibata-cursors;name="Bibata-Modern-Ice";};opacity.terminal=0.8;};
nix.settings.auto-optimise-store=true;
nix.gc={automatic=true;dates="weekly";options="--delete-older-than 7d";};
boot={loader={systemd-boot.enable=true;efi.canTouchEfiVariables=true;};kernelParams=["modprobe.blacklist=i2c_hid_acpi"];kernelPackages=pkgs.linuxPackages_zen;};
networking={hostName="nix";networkmanager.enable=true;};
nixpkgs.config.allowUnfree=true;
hardware.nvidia={open=true;modesetting.enable=true;};
services={
  xserver={enable=true;videoDrivers=["nvidia"];windowManager.dwm.enable=true;xkb={layout="us,ru";options="grp:win_space_toggle";};};
  asusd={enable=true;enableUserService=true;};tlp.enable=true;libinput.enable=true;gvfs.enable=true;udisks2.enable=true;
  picom={enable=true;backend="glx";vSync=true;activeOpacity=0.92;inactiveOpacity=0.85;fade=true;settings={corner-radius=12;blur={method="dual_kawase";strength=5;};};};
};
users.users.dx3d={isNormalUser=true;extraGroups=["wheel" "networkmanager" "video" "audio"];
packages=with pkgs;[st kitty hyprland waybar fastfetch vesktop ayugram-desktop librewolf pavucontrol wofi yazi micro nitch git htop brightnessctl flameshot xclip wireplumber lm_sensors gawk xorg.xsetroot procps xfce.thunar];};
programs={steam.enable=true;gamemode.enable=true;hyprland.enable=true;bash.shellAliases={
  dotsync="cd ~/dotfiles&&sudo cp /etc/nixos/configuration.nix .&&sudo cp /etc/nixos/hardware-configuration.nix .&&cp -r ~/.config/hypr .&&cp -r ~/.config/waybar .&&git add .&&git commit -m \"update:$(date +'%Y-%m-%d %H:%M')\"&&git push origin main&&cd -";
  clean="sudo nix-collect-garbage -d";
};};
nixpkgs.overlays=[(self: super:{dwm=super.dwm.overrideAttrs(o:{postPatch=''
  sed -i '/static const char \*termcmd/a static const char *vdn[]={"wpctl","set-volume","@DEFAULT_AUDIO_SINK@","5%-",NULL};\nstatic const char *vup[]={"wpctl","set-volume","@DEFAULT_AUDIO_SINK@","5%+",NULL};' config.def.h
'';});})];
system.activationScripts.ff.text="mkdir -p /home/dx3d/.config/fastfetch&&echo '{\"logo\":{\"type\":\"kitty-direct\",\"source\":\"/home/dx3d/Downloads/zam.jpg\",\"width\":25,\"height\":12}}'>/home/dx3d/.config/fastfetch/config.jsonc&&chown dx3d:users /home/dx3d/.config/fastfetch/config.jsonc";
services.xserver.displayManager.sessionCommands="${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 165\nwhile true;do\nv=$(wpctl get-volume @DEFAULT_AUDIO_SINK@|awk '{print int($2*100)\"%\"}')\nb=$(acpi -b|awk '{print $4}'|tr -d ',')\nxsetroot -name \"Vol:$v | Bat:$b | $(date +'%H:%M')\"\nsleep 2\ndone&";
system.stateVersion="25.11";
}
