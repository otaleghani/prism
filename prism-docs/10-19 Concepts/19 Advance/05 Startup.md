# Graphics

Handling graphics on Linux—especially on Wayland—can be a headache of conflicting drivers and environment variables. Prism simplifies this into a single option that prepares the system for high-performance rendering.

## The GPU toggle

In your `flake.nix` or hardware module, set the following option based on your physical hardware:

```nix
prism.hardware.gpu = "nvidia";   # For NVIDIA GPUs (Standard & RTX)
# prism.hardware.gpu = "amd";    # For AMD Radeon GPUs
# prism.hardware.gpu = "intel";  # For Intel Integrated or Arc Graphics
# prism.hardware.gpu = "vm";     # For Virtual Machines (Standard VirtIO)
```

### NVIDIA

Choosing `"nvidia"` does more than just install drivers. It automatically configures:

- **Proprietary Drivers:** Installs the latest stable production drivers.
- **Wayland Compatibility:** Sets `nvidia-drm.modeset=1` and necessary environment variables for Hyprland.
- **NVENC:** Enables hardware-accelerated video encoding (essential for `prism-screenrecord`).
- **Power Management:** Configures basic power saving for laptop users.

### AMD

Choosing `"amd"` utilizes the open-source `amdgpu` drivers.

- **Mesa:** Enables high-performance Vulkan and OpenGL support.
- **Variable Refresh Rate:** Pre-configures support for FreeSync monitors.

### Intel & VM

- **Intel:** Optimized for QuickSync video and low-power consumption.
- **VM:** Uses the `virtio` and `bochs` drivers, ensuring that the Prism UI remains fluid even without a physical GPU passed through.

## Performance verification

After applying your graphics configuration and rebooting, you can verify your setup using these built-in Prism tools:

|**Task**|**Tool**|**Command**|
|---|---|---|
|**Check GPU Load**|`btop`|Look for the GPU section in the UI|
|**Check Drivers**|`prism-system-monitor`|Review the "Graphics" information tab|
|**Verify Encoding**|`prism-screenrecord`|Attempt a short recording to test hardware accel|

## A Note on Hybrid Graphics (Laptops)

If you are on a laptop with both Intel/AMD integrated graphics and a dedicated NVIDIA chip, Prism currently defaults to the dedicated chip for the entire session to ensure maximum performance and animation smoothness.