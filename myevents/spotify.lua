local awful = require("awful")

local function emit_info(playerctl_output)
    -- require("naughty").notify({ title = "asdhjk", text = playerctl_output })
    local artist = playerctl_output:match("^(.*)AWESOMEWM_TITLE")
    local title = playerctl_output:match("AWESOMEWM_TITLE(.*)AWESOMEWM_STATUS")
    local status = playerctl_output:match("AWESOMEWM_STATUS(.*)$"):lower()
    -- Use the lower case of status
    status = string.gsub(status, "^%s*(.-)%s*$", "%1")

    awesome.emit_signal("myevents::spotify", artist, title, status)
end

local script = [[sh -c '
    playerctl metadata --format '{{artist}}AWESOMEWM_TITLE{{title}}AWESOMEWM_STATUS{{status}}' --follow
']]

-- Kill old playerctl process
awful.spawn.easy_async_with_shell(
    "ps x | grep \"playerctl metadata\" | grep -v grep | awk '{print $1}' | xargs kill",
    function()
        -- Emit song info with each line printed
        awful.spawn.with_line_callback(script, {
            stdout = function(line)
                emit_info(line)
            end,
        })
    end
)
