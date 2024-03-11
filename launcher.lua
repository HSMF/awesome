local awful = require("awful")

local M = {}

--- Is called at startup, may set up anything needed.
function M.init() end

--- run launcher
function M.launch()
    local rofi_conf = os.getenv("HOME") .. "/.config/rofi/config/launcher.rasi"
    local theme = ""
    if require("helpers").file_exists(rofi_conf) then
        theme = "-theme " .. rofi_conf
    end
    -- awful.util.spawn("dmenu_run")
    awful.util.spawn([[ rofi -show drun \
          -modi run,drun,ssh \
          -scroll-method 0 \
          -drun-match-fields all \
          -drun-display-format "{name}" \
          -no-drun-show-actions \
          -terminal kitty \
          -kb-cancel Escape \
    ]] .. theme, false)
end

return M
