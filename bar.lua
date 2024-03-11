local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local gears = require("gears")
local wibox = require("wibox")
local helpers = require("helpers")
local lain = require("lain")
local icons = require("icons").image

local markup = lain.util.markup
local separators = lain.util.separators

local SHOW_BATTERY = true

local tag_colors_empty = {
    "#00000000",
    "#00000000",
    "#00000000",
    "#00000000",
    "#00000000",
    "#00000000",
    "#00000000",
    "#00000000",
    "#00000000",
    "#00000000",
}

local tag_colors_urgent = {
    x.foreground,
    x.foreground,
    x.foreground,
    x.foreground,
    x.foreground,
    x.foreground,
    x.foreground,
    x.foreground,
    x.foreground,
    x.foreground,
}

local tag_colors_focused = {
    x.color1,
    x.color5,
    x.color4,
    x.color6,
    x.color2,
    x.color3,
    x.color1,
    x.color5,
    x.color4,
    x.color6,
}

local tag_colors_occupied = {
    x.color1 .. "45",
    x.color5 .. "45",
    x.color4 .. "45",
    x.color6 .. "45",
    x.color2 .. "45",
    x.color3 .. "45",
    x.color1 .. "45",
    x.color5 .. "45",
    x.color4 .. "45",
    x.color6 .. "45",
}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
        t:view_only()
    end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end),
    awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", { raise = true })
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

-- Helper function that updates a taglist item
local update_taglist = function(item, tag, index)
    if tag.selected then
        item.bg = tag_colors_focused[index]
    elseif tag.urgent then
        item.bg = tag_colors_urgent[index]
    elseif #tag:clients() > 0 then
        item.bg = tag_colors_occupied[index]
    else
        item.bg = tag_colors_empty[index]
    end
end

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
    {
        "hotkeys",
        function()
            hotkeys_popup.show_help(nil, awful.screen.focused())
        end,
    },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    {
        "quit",
        function()
            awesome.quit()
        end,
    },
}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Separators
local spr = wibox.widget.textbox(" ")
local arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)
-- }}}

-- {{{ Icons
-- CPU usage
local cpuicon = wibox.widget.imagebox(icons.cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.font(beautiful.font, " " .. cpu_now.usage .. "% "))
    end,
})

-- Net
local neticon = wibox.widget.imagebox(beautiful.widget_net)
local net = lain.widget.net({
    settings = function()
        widget:set_markup(
            markup.font(
                beautiful.font,
                markup("#7AC82E", " " .. string.format("%06.1f", net_now.received))
                .. " "
                .. markup("#46A8C3", " " .. string.format("%06.1f", net_now.sent) .. " ")
            )
        )
    end,
})

-- Battery
local baticon = wibox.widget.imagebox(icons.battery)
local bat = lain.widget.bat({
    settings = function()
        if bat_now.status and bat_now.status ~= "N/A" then
            if bat_now.ac_status == 1 then
                baticon:set_image(icons.battery_charging)
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
                baticon:set_image(icons.alert)
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
                -- TODO: add icon for low and alert
                baticon:set_image(icons.alert)
            else
                baticon:set_image(icons.battery)
            end
            widget:set_markup(markup.font(beautiful.font, " " .. bat_now.perc .. "% "))
        else
            widget:set_markup(markup.font(beautiful.font, " AC "))
            baticon:set_image(beautiful.widget_ac)
        end
    end,
})

-- }}}

---@param opts table
local function create_info_bar(opts)
    local output = {}

    local function add(prop)
        if prop == nil then
            return
        elseif type(prop) == "function" then
            add(prop())
        elseif type(prop) == "table" then
            for _, value in ipairs(prop) do
                output[#output + 1] = value
            end
        else
            output[#output + 1] = prop
        end
    end

    local sep = opts.separator

    local infos = {
        "keyboard_layout",
        "cpu",
        "battery",
        "network",
        "clock",
        "tray",
        -- layout to the very right
        "layout",
    }

    for i, info in ipairs(infos) do
        if type(sep) == "function" then
            add(sep(i))
        elseif i ~= 1 then
            add(sep)
        end
        add(opts[info])
    end

    output.layout = wibox.layout.fixed.horizontal

    return output
end

awful.screen.connect_for_each_screen(function(s)
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    s.main_menu = awful.menu({
        items = {
            { "awesome",       myawesomemenu, beautiful.awesome_icon },
            { "open terminal", terminal },
        },
    })

    local mylauncher = awful.widget.launcher({ image = icons.start, menu = s.main_menu })
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 3, function()
            awful.layout.inc(-1)
        end),
        awful.button({}, 4, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 5, function()
            awful.layout.inc(-1)
        end)
    ))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,

        layout = wibox.layout.flex.horizontal,
        widget_template = {
            widget = wibox.container.background,
            create_callback = function(self, tag, index, _)
                self:connect_signal("mouse::enter", function()
                    if self.bg ~= tag_colors_focused[index] then
                        self.backup = self.bg
                        self.has_backup = true
                    end
                    self.bg = tag_colors_focused[index]
                end)
                self:connect_signal("mouse::leave", function()
                    if self.has_backup then
                        self.bg = self.backup
                    end
                end)

                update_taglist(self, tag, index)
            end,
            update_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
        },
    })

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist({
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,

        style = {
            font = beautiful.tasklist_font,
            bg = x.color0,
        },

        layout = {
            layout = wibox.layout.flex.horizontal,
        },

        widget_template = {
            {

                {
                    {
                        id = "text_role",
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                left = 10,
                right = 10,
                widget = wibox.container.margin,
            },
            id = "background_role",
            widget = wibox.container.background,
        },
    })

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })
    s.traybox = wibox({ visible = false, ontop = true, shape = helpers.rrect(beautiful.border_radius), type = "dock" })

    local image = require("icons").image.home
    local tray_button = awful.widget.button({
        image = image,
        buttons = {
            awful.button({}, 1, nil, function()
                s.traybox.visible = not s.traybox.visible
            end),
        },
    })
    -- Add widgets to the wibox
    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        create_info_bar({
            keyboard_layout = { mykeyboardlayout },
            clock = { mytextclock },
            cpu = {
                cpuicon,
                cpu.widget,
            },
            tray = { tray_button },
            layout = { s.mylayoutbox },
            battery = function()
                if SHOW_BATTERY then
                    return {
                        baticon,
                        bat.widget,
                    }
                end
            end,
            -- network = {
            --     neticon,
            --     net.widget,
            -- },

            separator = {},
        }),
    })

    s.workspaces = awful.wibar({
        screen = s,
        visible = true,
        ontop = false,
        type = "dock",
        position = "top",
        height = dpi(20),
        bg = "#00000000",
    })

    s.workspaces:setup({
        widget = s.mytaglist,
    })

    -- Create a wibox that will only show the tray
    -- Hidden by default. Can be toggled with a keybind.
    s.traybox.width = dpi(120)
    s.traybox.height = dpi(120) -- beautiful.wibar_height - beautiful.screen_margin * 4
    s.traybox.x = s.geometry.width - beautiful.screen_margin * 2 - s.traybox.width
    s.traybox.y = s.geometry.height - s.traybox.height - beautiful.screen_margin * 2
    -- s.traybox.y = s.geometry.height - s.traybox.height - s.traybox.height / 2
    s.traybox.bg = beautiful.bg_systray
    s.traybox:setup({
        wibox.widget.systray(),
        left = dpi(6),
        right = dpi(6),
        widget = wibox.container.margin,
    })
    s.traybox:buttons(gears.table.join(
    -- Middle click - Hide traybox
        awful.button({}, 2, function()
            s.traybox.visible = false
        end)
    ))
    -- Hide traybox when mouse leaves
    s.traybox:connect_signal("mouse::leave", function()
        s.traybox.visible = false
    end)
end)
