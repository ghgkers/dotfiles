{ config, pkgs, ... }: {
  networking.hostName = "nix-gaming";

  services.asusd.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.bluetooth.enable = false;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.kernelParams = [ 
    "nvidia-drm.modeset=1"
    "usbcore.autosuspend=-1"
    "usbhid.kbpoll=1"
  ];

  boot.blacklistedKernelModules = [
    "bluetooth" "btusb" "btintel" "btrtl"
    "i2c_hid" "i2c_hid_acpi" "hid_multitouch"
  ];
}
