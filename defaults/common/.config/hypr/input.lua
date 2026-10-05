hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            -- One finger: left click; two: right click; three: middle click.
            clickfinger_behavior = true,
            disable_while_typing = true,
            drag_lock = true,
        },
        -- -1.0 to 1.0; zero leaves sensitivity unchanged.
        sensitivity = 0,
        accel_profile = "flat",
    },
    gestures = {
        workspace_swipe_distance = 300,
        workspace_swipe_invert = true,
        workspace_swipe_min_speed_to_force = 30,
        workspace_swipe_cancel_ratio = 0.5,
    },
})

-- Enable this to add a three-finger workspace swipe:
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
