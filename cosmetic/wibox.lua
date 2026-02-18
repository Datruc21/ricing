--This file is related to the widget bar

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local menubar = require("menubar")

local vicious = require("vicious")

--to set the home and ~
home = os.getenv("HOME")
beautiful.init(home.."/.config/awesome/default/theme.lua") --This line takes the theme table and make it globally available under the name beautiful


local layout_map = {
    ["fr"] = "FR",
    ["ara"] = "AR"
}



-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout({
    country_codes = {"FR","AR"}
})


my_systray = wibox.container.background(
    wibox.widget.systray({opacity = 0.85}),
    beautiful.bg_systray
)

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))




--fonction that sets the wallpaper
--Need to modify it to connect it to the signal each time tag is changed
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end


-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)




awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    local names = { "١", "٢", "٣", "٤", "٥"}

    local l = awful.layout.suit  -- Just to save some typing: use an alias.
    local layouts = { l.tile, l.tile, l.tile, l.tile}
    awful.tag(names, s, layouts)



    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
	style = {
		shape = gears.shape.partia_squircle,
        spacing = 20
		}
	--widget_template = {
				


	--}
        
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
    local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
    local volume_widget_module = require('awesome-wm-widgets.pactl-widget.volume')
    volume_widget = volume_widget_module{
    widget_type = 'arc'
}    local network_widget = wibox.widget.textbox()
    vicious.register(
    	network_widget,
	vicious.widgets.net,
	function(widget, args)
        if args["{wlp2s0 carrier}"] == 1 then
            return string.format(
                " 🌐 ↓ %.1f KB/s ↑ %.1f KB/s",
                args["{wlp2s0 down_kb}"],
                args["{wlp2s0 up_kb}"]
            )
        else
            return " ❌ offline"
        end
    end,
    1
  )
    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, stretch = true, opacity = 0.85 })
    
    -- Change its color
    s.mywibox.bg = beautiful.wibar_bg 

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        wibox.container.place(
        mytextclock,
        "center", -- horizontal Alignement 
        "center"  -- vertical Alignement 
        ), -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 15,
            mykeyboardlayout,
            my_systray, --indicates where notifications and other things must be displayed
            --network_widget,
	    brightness_widget{
            type = 'icon_and_text',
            program = 'brightnessctl',
            step = 2,        
        },volume_widget,
            batteryarc_widget({
            show_current_level = true,
            arc_thickness = 1,
        })
        },
    }
end)

-- }}}


