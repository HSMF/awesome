local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local lfs = require("lfs")
local helpers = require("helpers")

local wallpapers_location = os.getenv("HOME") .. "/Pictures/wallpapers/"
local wallpapers = helpers.user_config().spotify_wallpapers or {}

---gets the wallpaper for the artist
---first tries the user-configs table
---second tries any file in the wallpapers directory that matches the artist name
---finally falls back to the wallpaper for the current theme
---@param artist string
local function get_wallpaper(artist)
    local wallpaper = wallpapers[artist]
    if wallpaper then
        return wallpapers_location .. wallpaper
    end
    for file in lfs.dir(wallpapers_location) do
        if file == "." or file == ".." then
            goto continue
        end
        local f = wallpapers_location .. "/" .. file
        local attr = lfs.attributes(f)
        if attr.mode == "directory" then
            goto continue
        end

        local name = file:match("^(.+)%.[^.]+$")

        if name == artist then
            return f
        end

        ::continue::
    end

    return beautiful.wallpaper
end

awful.screen.connect_for_each_screen(function(s)
    ---@diagnostic disable-next-line: unused-local
    awesome.connect_signal("myevents::spotify", function(artist, title, status)
        -- local wallpaper = wallpapers[artist]
        -- if wallpaper then
        --     wallpaper = wallpapers_location .. wallpaper
        -- end
        local wallpaper = get_wallpaper(artist)
        wallpaper = wallpaper or beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end)
end)
