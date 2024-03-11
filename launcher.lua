local awful = require("awful")

local M = {}

--- Is called at startup, may set up anything needed.
function M.init() end

--- run launcher
function M.launch()
    -- awful.util.spawn("dmenu_run")
    awful.util.spawn(
        [[rofi
        -modi drun
        -show drun
        -show-icons
        -width 22
        -no-click-to-exit
    ]],
        false
    )
end

return M
