{ config, pkgs, ... }: {
  networking.hostName = "nix-gaming";[cite: 3]

  services.asusd.enable = true;[cite: 3]
  services.xserver.videoDrivers = [ "nvidia" ];[cite: 3]
  hardware.bluetooth.enable = false;[cite: 3]

  hardware.nvidia = {
    modesetting.enable = true;[cite: 3]
    open = false;[cite: 3]
    package = config.boot.kernelPackages.nvidiaPackages.stable;[cite: 3]
  };

  boot.kernelParams = [ 
    "nvidia-drm.modeset=1"[cite: 3]
    "usbcore.autosuspend=-1"[cite: 3]
    "usbhid.kbpoll=1"[cite: 3]
  ];

  boot.blacklistedKernelModules = [
    "bluetooth" "btusb" "btintel" "btrtl"[cite: 3]
    "i2c_hid" "i2c_hid_acpi" "hid_multitouch"[cite: 3]
  ];
}
