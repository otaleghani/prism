{ lib, ... }:

{
  # Libinput
  # Essential for proper gesture support in SDDM/Display Managers
  services.libinput = {
    enable = lib.mkDefault true;

    # Settings for the login screen
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger"; # 2-finger right click
    };
  };

  # Kernel Tweaks
  # Many modern laptops (Dell XPS, Lenovo ThinkPad, Framework) suffer from
  # laggy cursor movement because they default to legacy PS/2 mode.
  # This forces the use of the modern RMI4/SMBus protocol.
  boot.kernelParams = [
    "psmouse.synaptics_intertouch=1"
  ];

  # Test for lenovo laptop
  boot.blacklistedKernelModules = [ "elan_i2c" ];
}
