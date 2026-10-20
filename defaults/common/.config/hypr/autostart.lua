-- UWSM and other notify services already manage their session lifecycle.
local manages_session = not os.getenv("NOTIFY_SOCKET")

-- Run once when Hyprland starts, not each time the configuration reloads.
hl.on("hyprland.start", function()
    if manages_session then
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user start hyprland-session.target")
    end
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("qs")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("~/.config/startup.sh")
end)

hl.on("hyprland.shutdown", function()
    if manages_session then
        os.execute("systemctl --user stop hyprland-session.target")
    end
end)
