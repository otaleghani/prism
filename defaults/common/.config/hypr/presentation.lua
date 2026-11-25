-- A nested desktop for sharing; notes stay in the outer Hyprland session.
hl.env("HYPRLAND_NO_SD_VARS", "1")
hl.env("HYPRLAND_NO_SD_NOTIFY", "1")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")

require("input")
require("styles")
require("layout")
hl.monitor({ output = "", mode = "1920x1080@60", position = "0x0", scale = 1 })

-- The outer desktop keeps SUPER shortcuts, including scratchpad and mic mute.
local mod = "SUPER + ALT"
hl.bind(mod .. " + A", hl.dsp.exec_cmd("ghostty"), { description = "Presentation terminal" })
hl.bind(mod .. " + S", hl.dsp.exec_cmd([[chromium --ozone-platform=wayland --enable-features=WebRTCPipeWireCapturer --user-data-dir="${XDG_DATA_HOME:-$HOME/.local/share}/prism/presentation/chromium"]]), { description = "Presentation browser" })
hl.bind(mod .. " + F", hl.dsp.exec_cmd("prism-tui yazi"), { description = "Presentation files" })
hl.bind(mod .. " + CONTROL + Q", hl.dsp.window.close(), { description = "Close presentation window" })
hl.bind(mod .. " + CONTROL + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize presentation window" })
hl.bind(mod .. " + Y", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mod .. " + CONTROL + M", hl.dsp.exit(), { description = "Close presentation desktop" })
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { description = "Move presentation window", mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { description = "Resize presentation window", mouse = true })

for workspace = 1, 9 do
    hl.bind(mod .. " + " .. workspace, hl.dsp.focus({ workspace = workspace }), { description = "Presentation workspace " .. workspace })
    hl.bind(mod .. " + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = true }), { description = "Move to presentation workspace " .. workspace })
end
for _, direction in ipairs({ { "H", "l" }, { "J", "d" }, { "K", "u" }, { "L", "r" } }) do
    hl.bind(mod .. " + " .. direction[1], hl.dsp.focus({ direction = direction[2] }), { description = "Focus " .. direction[2] })
end

hl.on("hyprland.start", function()
    -- Update only the private bus: --systemd would change the outer session.
    hl.exec_cmd("dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && ghostty")
end)
