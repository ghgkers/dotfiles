{config,pkgs,inputs,...}:
let
mySowm=pkgs.stdenv.mkDerivation{
pname="sowm";
version="master";
src=pkgs.fetchFromGitHub{
owner="dylanaraps";
repo="sowm";
rev="master";
sha256="sha256-Q65sU5K86pFk3QNlzfxgyoEw6NpBaZQmFOkUFnmoh+U=";
};
buildInputs=with pkgs;[libx11 libxinerama];
nativeBuildInputs=with pkgs;[gcc gnumake];
installPhase="mkdir -p $out/bin;make PREFIX=$out install";
};
in{
imports=[./hardware-configuration.nix];
nixpkgs.overlays=[inputs.chaotic.overlays.default];
nix.settings.experimental-features=["nix-command" "flakes"];
boot={
loader={systemd-boot.enable=true;efi.canTouchEfiVariables=true;};
kernelPackages=pkgs.linuxPackages_cachyos;
kernelParams=["nvidia-drm.modeset=1" "nvidia.NVreg_PreserveVideoMemoryAllocations=1"];
};
networking.hostName="nix";
networking.networkmanager.enable=true;
nixpkgs.config.allowUnfree=true;
hardware.nvidia={
open=true;
modesetting.enable=true;
package=config.boot.kernelPackages.nvidiaPackages.stable;
};
services.xserver={
enable=true;
videoDrivers=["nvidia"];
xkb={layout="us,ru";options="grp:win_space_toggle";};
displayManager.sessionCommands=''
${pkgs.picom}/bin/picom &
${pkgs.feh}/bin/feh --bg-fill /home/dx3d/Downloads/zam.jpg &
${mySowm}/bin/sowm
'';
};
services.displayManager.ly.enable=true;
programs={
steam.enable=true;
gamemode.enable=true;
gamescope.enable=true;
bash.shellAliases={
dotsync="cd ~/dotfiles && sudo cp /etc/nixos/configuration.nix . && sudo cp /etc/nixos/hardware-configuration.nix . && sudo cp /etc/nixos/flake.nix . && cp -r ~/.config/hypr . && cp -r ~/.config/waybar . && git add . && git commit -m \"update:$(date +'%Y-%m-%d %H:%M')\" && git pull origin main --rebase && git push origin main && cd -";
clean="sudo nix-collect-garbage -d";
};
};
users.users.dx3d={
isNormalUser=true;
extraGroups=["wheel" "networkmanager" "video" "audio"];
packages=with pkgs;[mySowm st scrot micro git feh dmenu xclip flatpak picom librewolf gh fastfetch mangohud pciutils];
};
system.activationScripts.sober.text=''
${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
${pkgs.flatpak}/bin/flatpak install -y flathub org.vinegarhq.Sober || true
'';
system.stateVersion="25.11";
}
