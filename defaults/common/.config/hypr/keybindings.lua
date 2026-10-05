local programs = require("programs")
local main_mod = programs.main_mod

hl.config({ binds = { scroll_event_delay = 0 } })

-- Basic programs -> HOME ROW LEFT (home row right is for movement)
hl.bind(main_mod .. " + A", hl.dsp.exec_cmd(programs.terminal), { description = programs.terminal })
hl.bind(main_mod .. " + S", hl.dsp.exec_cmd(programs.browser), { description = programs.browser })
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(programs.ai), { description = programs.ai })
hl.bind(main_mod .. " + D", hl.dsp.focus({ workspace = 97 }), { description = "workspace 97" })
hl.bind(main_mod .. " + F", hl.dsp.exec_cmd(programs.files), { description = programs.files })
hl.bind(main_mod .. " + CONTROL + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "fullscreen 1" })
hl.bind(main_mod .. " + G", hl.dsp.exec_cmd(programs.music), { description = programs.music })
hl.bind(main_mod .. " + G", hl.dsp.focus({ workspace = 99 }), { description = "workspace 99" })
hl.bind(main_mod .. " + SHIFT + G", hl.dsp.exec_cmd(programs.chat), { description = programs.chat })
hl.bind(main_mod .. " + SHIFT + G", hl.dsp.focus({ workspace = 98 }), { description = "workspace 98" })
hl.bind(main_mod .. " + 0", hl.dsp.exec_cmd("prism-apps"), { description = "prism-apps" })

-- System commands -> BOT ROW
hl.bind(main_mod .. " + SHIFT + C", hl.dsp.exec_cmd("prism-ctl calendar"), { description = "prism-ctl calendar" })
hl.bind(main_mod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "INSERT", window = "activewindow" }), { description = "Copy" })
hl.bind(main_mod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "INSERT", window = "activewindow" }), { description = "Paste" })
hl.bind(main_mod .. " + X", hl.dsp.send_shortcut({ mods = "SHIFT", key = "DELETE", window = "activewindow" }), { description = "Cut" })
hl.bind(main_mod .. " + SHIFT + V", hl.dsp.exec_cmd("prism-clipboard"), { description = "prism-clipboard" })
hl.bind(main_mod .. " + CONTROL + V", hl.dsp.exec_cmd("prism-clipboard --wipe"), { description = "prism-clipboard --wipe" })
hl.bind(main_mod .. " + CONTROL + B", hl.dsp.exec_cmd("prism-ctl sidebar"), { description = "prism-ctl sidebar" })
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd("prism-ctl brightness"), { description = "prism-ctl brightness" })
hl.bind(main_mod .. " + Z", hl.dsp.exec_cmd("prism-settings"), { description = "prism-settings" })
hl.bind(main_mod .. " + CONTROL + M", hl.dsp.exit(), { description = "Close hyperland" })
hl.bind(main_mod .. " + N", hl.dsp.exec_cmd("prism-ctl notifications"), { description = "prism-ctl notifications" })
hl.bind(main_mod .. " + M", hl.dsp.exec_cmd("prism-ctl mixer"), { description = "prism-ctl mixer" })

-- Utils / Window management -> TOP ROW
hl.bind(main_mod .. " + Y", hl.dsp.window.float({ action = "toggle" }), { description = "togglefloating" })
hl.bind(main_mod .. " + CONTROL + Q", hl.dsp.window.close(), { description = "killactive" })
hl.bind(main_mod .. " + P", hl.dsp.exec_cmd("prism-screenshot fullscreen edit"), { description = "prism-screenshot fullscreen edit" })
hl.bind(main_mod .. " + SHIFT + P", hl.dsp.exec_cmd("prism-screenshot region edit"), { description = "prism-screenshot region edit" })
hl.bind(main_mod .. " + CONTROL + P", hl.dsp.exec_cmd("prism-ctl session"), { description = "prism-ctl session" })
hl.bind(main_mod .. " + O", hl.dsp.exec_cmd("prism-screenrecord --desktop --mic --webcam"), { description = "prism-screenrecord --desktop --mic --webcam" })
hl.bind(main_mod .. " + CONTROL + O", hl.dsp.exec_cmd("prism-screenrecord --stop"), { description = "prism-screenrecord --stop" })
hl.bind(main_mod .. " + T", hl.dsp.workspace.toggle_special(""), { description = "Toggle special workspace" })
hl.bind(main_mod .. " + CONTROL + T", hl.dsp.exec_cmd("prism-ctl themes"), { description = "prism-ctl themes" })
hl.bind(main_mod .. " + SHIFT + T", hl.dsp.window.move({ workspace = "special", follow = true }), { description = "Move to special workspace" })
hl.bind(main_mod .. " + R", hl.dsp.group.toggle(), { description = "Toggle group" })
hl.bind(main_mod .. " + SHIFT + R", hl.dsp.window.move({ out_of_group = true }), { description = "Move current window out of group" })
hl.bind(main_mod .. " + W", hl.dsp.group.prev(), { description = "Back" })
hl.bind(main_mod .. " + CONTROL + W", hl.dsp.exec_cmd("prism-ctl wallpapers"), { description = "prism-ctl wallpapers" })
hl.bind(main_mod .. " + E", hl.dsp.group.next(), { description = "Forward" })
hl.bind(main_mod .. " + U", hl.dsp.exec_cmd("prism-tui prism-install"), { description = "prism-tui prism-install" })
hl.bind(main_mod .. " + CONTROL + U", hl.dsp.exec_cmd("prism-tui prism-delete"), { description = "prism-tui prism-delete" })
hl.bind(main_mod .. " + SHIFT + CONTROL + U", hl.dsp.exec_cmd("prism-tui prism-update ~/.config/prism"), { description = "prism-tui prism-update ~/.config/prism" })

-- WORKSPACE MOVEMENT
hl.bind(main_mod .. " + 1", hl.dsp.focus({ workspace = 1 }), { description = "workspace 1" })
hl.bind(main_mod .. " + 2", hl.dsp.focus({ workspace = 2 }), { description = "workspace 2" })
hl.bind(main_mod .. " + 3", hl.dsp.focus({ workspace = 3 }), { description = "workspace 3" })
hl.bind(main_mod .. " + 4", hl.dsp.focus({ workspace = 4 }), { description = "workspace 4" })
hl.bind(main_mod .. " + 5", hl.dsp.focus({ workspace = 5 }), { description = "workspace 5" })
hl.bind(main_mod .. " + 6", hl.dsp.focus({ workspace = 6 }), { description = "workspace 6" })
hl.bind(main_mod .. " + 7", hl.dsp.focus({ workspace = 7 }), { description = "workspace 7" })
hl.bind(main_mod .. " + 8", hl.dsp.focus({ workspace = 8 }), { description = "workspace 8" })
hl.bind(main_mod .. " + 9", hl.dsp.focus({ workspace = 9 }), { description = "workspace 9" })
-- Duplicate for left only navigation
hl.bind("ALT + 1", hl.dsp.focus({ workspace = 1 }), { description = "workspace 1" })
hl.bind("ALT + 2", hl.dsp.focus({ workspace = 2 }), { description = "workspace 2" })
hl.bind("ALT + 3", hl.dsp.focus({ workspace = 3 }), { description = "workspace 3" })
hl.bind("ALT + 4", hl.dsp.focus({ workspace = 4 }), { description = "workspace 4" })
hl.bind("ALT + 5", hl.dsp.focus({ workspace = 5 }), { description = "workspace 5" })

-- Move window to workspace
hl.bind(main_mod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1, follow = true }), { description = "movetoworkspace 1" })
hl.bind(main_mod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2, follow = true }), { description = "movetoworkspace 2" })
hl.bind(main_mod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3, follow = true }), { description = "movetoworkspace 3" })
hl.bind(main_mod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4, follow = true }), { description = "movetoworkspace 4" })
hl.bind(main_mod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5, follow = true }), { description = "movetoworkspace 5" })
hl.bind(main_mod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6, follow = true }), { description = "movetoworkspace 6" })
hl.bind(main_mod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7, follow = true }), { description = "movetoworkspace 7" })
hl.bind(main_mod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8, follow = true }), { description = "movetoworkspace 8" })
hl.bind(main_mod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9, follow = true }), { description = "movetoworkspace 9" })

-- Move focus
hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "l" }), { description = "movefocus l" })
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "d" }), { description = "movefocus d" })
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "u" }), { description = "movefocus u" })
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "r" }), { description = "movefocus r" })

-- Move window
hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l", group_aware = false }), { description = "movewindow l" })
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d", group_aware = false }), { description = "movewindow d" })
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u", group_aware = false }), { description = "movewindow u" })
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r", group_aware = false }), { description = "movewindow r" })

hl.bind(main_mod .. " + CONTROL + H", hl.dsp.window.move({ into_group = "l" }), { description = "Move into group" })
hl.bind(main_mod .. " + CONTROL + L", hl.dsp.window.move({ into_group = "r" }), { description = "moveintogroup r" })
hl.bind(main_mod .. " + CONTROL + K", hl.dsp.window.move({ into_group = "u" }), { description = "moveintogroup u" })
hl.bind(main_mod .. " + CONTROL + J", hl.dsp.window.move({ into_group = "d" }), { description = "moveintogroup d" })

-- Window resize
hl.bind(main_mod .. " + SHIFT + CONTROL + H", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { description = "resizeactive -40 0", repeating = true })
hl.bind(main_mod .. " + SHIFT + CONTROL + J", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { description = "resizeactive 0 40", repeating = true })
hl.bind(main_mod .. " + SHIFT + CONTROL + K", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { description = "resizeactive 0 -40", repeating = true })
hl.bind(main_mod .. " + SHIFT + CONTROL + L", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { description = "resizeactive 40 0", repeating = true })

-- Laptop multimedia
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { description = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+", repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { description = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { description = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { description = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { description = "brightnessctl s 10%+", repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { description = "brightnessctl s 10%-", repeating = true, locked = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { description = "playerctl next", locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { description = "playerctl play-pause", locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { description = "playerctl play-pause", locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { description = "playerctl previous", locked = true })

-- Move and resize with mouse
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { description = "movewindow", mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { description = "resizewindow", mouse = true })

-- Zoom
hl.bind("ALT + mouse_down", hl.dsp.exec_cmd("prism-zoom --in"), { description = "prism-zoom --in" })
hl.bind("ALT + mouse_up", hl.dsp.exec_cmd("prism-zoom --out"), { description = "prism-zoom --out" })
hl.bind("ALT + Z", hl.dsp.exec_cmd("prism-zoom --reset"), { description = "prism-zoom --reset" })
