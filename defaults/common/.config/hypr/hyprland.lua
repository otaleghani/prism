-- Prefer NVIDIA when the configured NVIDIA/AMD PCI devices are present.
-- Resolve PCI links first: AQ_DRM_DEVICES uses ":" to separate devices.
local gpu_paths = io.popen("readlink -e /dev/dri/by-path/pci-0000:01:00.0-card /dev/dri/by-path/pci-0000:06:00.0-card")
if gpu_paths then
    local nvidia_card, amd_card = gpu_paths:read("*l"), gpu_paths:read("*l")
    gpu_paths:close()
    if nvidia_card and amd_card then hl.env("AQ_DRM_DEVICES", nvidia_card .. ":" .. amd_card) end
end

-- Prism's configuration is split by purpose; old/ contains the Hyprlang originals.
require("programs")
require("hyprcursor")
require("input")
require("monitors")
require("styles")
require("layout")
require("windowrules")
require("keybindings")
require("mode")
require("autostart")
