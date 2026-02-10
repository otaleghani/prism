{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.prism.hardware;
in
{

  options.prism.hardware = {
    gpu = lib.mkOption {
      type = lib.types.enum [
        "nvidia"
        "amd"
        "intel"
        "vm"
        "none"
      ];
      default = "none";
      description = "Select the GPU vendor for automatic driver configuration.";
    };
  };

  config = lib.mkMerge [
    # Global defaults, always true
    {
      hardware.graphics = {
        enable = lib.mkDefault true;
        # Required for Steam/Wine
        enable32Bit = lib.mkDefault true;
      };
    }

    # NVIDIA CONFIGURATION
    (lib.mkIf (cfg.gpu == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        # Modesetting is required for most Wayland compositors (Hyprland, Sway)
        modesetting.enable = true;

        # Nvidia power management. Experimental.
        powerManagement.enable = false;
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (alpha quality).
        open = false;

        # Enable the Nvidia settings menu
        nvidiaSettings = true;

        # Select the stable driver version by default
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };
    })

    # AMD CONFIGURATION
    (lib.mkIf (cfg.gpu == "amd") {
      services.xserver.videoDrivers = [ "amdgpu" ];

      # Load amdgpu at boot for better resolution during boot process
      boot.initrd.kernelModules = [ "amdgpu" ];

      # HIP/ROCm support
      systemd.tmpfiles.rules = [
        "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      ];
    })

    # INTEL CONFIGURATION
    (lib.mkIf (cfg.gpu == "intel") {
      nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      };

      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver # Broadwell+
        intel-vaapi-driver # Older
        libvdpau-va-gl
      ];
    })

    # VIRTUAL MACHINE (Guest) CONFIGURATION
    (lib.mkIf (cfg.gpu == "vm") {
      services.spice-vdagentd.enable = true;
      services.qemuGuest.enable = true;
    })
  ];

}
