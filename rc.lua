-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load the widget.
local APW = require("apw/widget")

-- Freedesktop integration
-- FIXME for 3,5 since freedesktop is not compatabible
require("freedesktop.utils")
require("freedesktop.menu")
require("freedesktop.desktop")
-- use local keyword for awesome 3.5 compatability
-- calendar functions
local calendar2 = require("calendar2")
-- Extra widgets
local vicious = require("vicious")
-- to create shortcuts help screen
local keydoc = require("keydoc")
 
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

awful.util.spawn_with_shell("~/.config/awesome/dual-monitor.sh")
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'gnome'

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags

mytags = {}
if screen.count() == 1 then
   main_screen_id = 1
else if screen.count() == 3 then
   main_screen_id = 1
   mytags[2] = {
      names =  { "work" },
      layouts = { layouts[2] }
   }
   mytags[3] = {
      names =  { "work" },
      layouts = { layouts[2] }
   }
else
   main_screen_id = 1
   mytags[2] = {
      names =  { "work" },
      layouts = { layouts[2] }
   }
   
end
end

mytags[main_screen_id] = {
   names   = { "work",      "mail",      "www",       "irc",
	       "im",        "av",        "game",      "rdesktop",
	       "p2p",       "10",        "11",        "12" },
   layouts = { layouts[2],  layouts[3],  layouts[2],  layouts[10],
	       layouts[2],  layouts[2],  layouts[10], layouts[2],
	       layouts[2],  layouts[2],  layouts[2],  layouts[2] }
}

work_tag_id = 1
mail_tag_id = 2
www_tag_id = 3
irc_tag_id = 4
im_tag_id = 5
av_tag_id = 6
game_tag_id = 7
rdesktop_tag_id = 8
p2p_tag_id = 9

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
   tags[s] = awful.tag(mytags[s].names, s, mytags[s].layouts)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
 mysystem_menu = {
    { 'Lock Screen', 'gnome-screensaver-command --lock', freedesktop.utils.lookup_icon({ icon = 'system-lock-screen' }) },
    { 'Logout', awesome.quit, freedesktop.utils.lookup_icon({ icon = 'system-log-out' }) },
    { 'Reboot System', 'xdg-su -c "shutdown -r now"', freedesktop.utils.lookup_icon({ icon = 'reboot-notifier' }) },
    { 'Shutdown System', 'xdg-su -c "shutdown -h now"', freedesktop.utils.lookup_icon({ icon = 'system-shutdown' }) }
 }
 myawesome_menu = {
    { 'Restart Awesome', awesome.restart, freedesktop.utils.lookup_icon({ icon = 'gtk-refresh' }) },
    { "Edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
    { "manual", terminal .. " -e man awesome" }
 }
 top_menu = {
    { 'Applications', freedesktop.menu.new(), freedesktop.utils.lookup_icon({ icon = 'start-here' }) },
    { 'Awesome', myawesome_menu, beautiful.awesome_icon },
    { 'System', mysystem_menu, freedesktop.utils.lookup_icon({ icon = 'system' }) },
    { 'Terminal', freedesktop.utils.terminal, freedesktop.utils.lookup_icon({ icon = 'terminal' }) }
 }
 mymainmenu = awful.menu.new({ items = top_menu, width = 150 })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
spacer = widget({type = "textbox"})
separator = widget({type = "textbox"})
spacer.text = " "
separator.text = "|"

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

calendar2.addCalendarToWidget(mytextclock, "<span color='green'>%s</span>")

mycpuwidget = widget({ type = "textbox" })
vicious.register(mycpuwidget, vicious.widgets.cpu, "$1%")

mybattery = widget({ type = "textbox"})
vicious.register(mybattery, function(format, warg)
  local args = vicious.widgets.bat(format, warg)
  if args[2] < 50 then
    args['{color}'] = 'red'
  else
    args['{color}'] = 'green'
  end
  return args
end, '<span foreground="${color}">bat: $2% $3h</span>', 10, 'BAT0')

-- Initialize widget
mynetwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(mynetwidget, vicious.widgets.net, "${eth0 down_kb} / ${eth0 up_kb}", 1)

-- wifi
-- provides wireless information for a requested interface
-- takes the network interface as an argument, i.e. "wlan0"
-- returns a table with string keys: {ssid}, {mode}, {chan}, {rate}, {link}, {linp} and {sign}
wifi = widget({ type = "textbox" })
vicious.register(wifi, vicious.widgets.wifi, "${link}", 121, "wlan0")

-- Weather widget
myweatherwidget = widget({ type = "textbox" })
weather_t = awful.tooltip({ objects = { myweatherwidget },})
vicious.register(myweatherwidget, vicious.widgets.weather,
		function (widget, args)
                  weather_t:set_text("City: " .. args["{city}"] .."\nWind: " .. args["{windkmh}"] .. "km/h " .. args["{wind}"] .. "\nSky: " .. args["{sky}"] .. "\nHumidity: " .. args["{humid}"] .. "%")
                  return args["{tempc}"] .. "C"
                end, 1800, "EDDN")
                --'1800': check every 30 minutes.
                --'EDDN': Nuernberg ICAO code.

-- Keyboard map indicator and changer
-- https://awesome.naquadah.org/wiki/Change_keyboard_maps
-- default keyboard is us, second is german adapt to your needs
--

-- Keyboard map indicator and changer
 kbdcfg = {}
 kbdcfg.cmd = "setxkbmap"
 kbdcfg.layout = { { "fr", "FR" }, { "us", "EN" } }
 kbdcfg.current = 1 --  fr is our default layout
 kbdcfg.widget = widget({ type = "textbox", align = "right" })
 kbdcfg.widget.text = " " .. kbdcfg.layout[kbdcfg.current][1] .. " "
 kbdcfg.switch = function ()
 kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
 local t = kbdcfg.layout[kbdcfg.current]
 kbdcfg.widget.text = " " .. t[1] .. " "
 os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
 end
                                          
-- Mouse bindings
kbdcfg.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () kbdcfg.switch() end)
))

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],

        mytextclock,
	    separator,
	    spacer,

        s == main_screen_id and APW or nil,
        s == main_screen_id and spacer or nil,
        s == main_screen_id and separator or nil,
        s == main_screen_id and spacer or nil,

        s == main_screen_id and kbdcfg.widget or nil,
        s == main_screen_id and spacer or nil,
        s == main_screen_id and separator or nil,
        s == main_screen_id and spacer or nil,

        mycpuwidget,
        spacer,
        separator,
        spacer,

        mybattery,
        spacer,
        separator,
        spacer,

        mynetwidget,
        spacer,
        separator,
        spacer,

        wifi,
        spacer,
        separator,
        spacer,

        myweatherwidget,
        spacer,
        separator,
        spacer,

        s == main_screen_id and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- these are needed by the keydoc a better solution would be to place them in theme.lua
-- but leaving them here also provides a mean to change the colors here ;)
beautiful.fg_widget_value="green"
beautiful.fg_widget_clock="gold"
beautiful.fg_widget_value_important="red"

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ "Mod1", "Control" }, "l",      function () 
	  awful.util.spawn("gnome-screensaver-command --lock") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Configure the hotkeys.
    awful.key({  }, "XF86AudioRaiseVolume",  APW.Up),
    awful.key({  }, "XF86AudioLowerVolume",  APW.Down),
    awful.key({  }, "XF86AudioMute",         APW.ToggleMute),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 12
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(12, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 12.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "F" .. i,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "F" .. i,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "F" .. i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "F" .. i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox/chromium to always map on tags number www_tag_id of screen main_screen_id.
    { rule = { class = "Navigator" },
       properties = { switchtotag = true, tag = tags[main_screen_id][www_tag_id] } },
    -- Set Thunderbird to always map on tags number mail_tag_id of screen main_screen_id.
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[main_screen_id][mail_tag_id] } },
    -- Set xchat to always map on tags number irc_tag_id of screen main_screen_id.
    { rule = { class = "Xchat" },
      properties = { tag = tags[main_screen_id][irc_tag_id] } },
    -- Set steam client to always map on tags number game_tag_id of screen main_screen_id.
    { rule = { class = "Steam" },
      properties = { tag = tags[main_screen_id][game_tag_id] } },
    -- Set spotify client to always map on tags number game_tag_id of screen main_screen_id.
    { rule = { class = "Spotify" },
      properties = { tag = tags[main_screen_id][av_tag_id] } },
    -- Set pidgin to always map on tags number im_tag_id of screen main_screen_id.
     { rule = { class = "Pidgin", role = "buddy_list" },
       properties = { floating=true,
		      maximized_vertical=false, maximized_horizontal=false,
		      tag = tags[main_screen_id][im_tag_id] },
      callback = function (c)
        local cl_width = 250    -- width of buddy list window
        local def_left = true   -- default placement. note: you have to restart
                                -- pidgin for changes to take effect

        local scr_area = screen[c.screen].workarea
        local cl_strut = c:struts()
        local geometry = nil

        -- adjust scr_area for this client's struts
        if cl_strut ~= nil then
            if cl_strut.left ~= nil and cl_strut.left > 0 then
                geometry = {x=scr_area.x-cl_strut.left, y=scr_area.y,
                            width=cl_strut.left}
            elseif cl_strut.right ~= nil and cl_strut.right > 0 then
                geometry = {x=scr_area.x+scr_area.width, y=scr_area.y,
                            width=cl_strut.right}
            end
        end
        -- scr_area is unaffected, so we can use the naive coordinates
        if geometry == nil then
            if def_left then
                c:struts({left=cl_width, right=0})
                geometry = {x=scr_area.x, y=scr_area.y,
                            width=cl_width, height=scr_area.height-20}
            else
                c:struts({right=cl_width, left=0})
                geometry = {x=scr_area.x+scr_area.width-cl_width, y=scr_area.y,
                            width=cl_width, height=scr_area.height}
            end
        end
        c:geometry(geometry)
    end },
    -- Set Remmina to always map on tags number rdesktop_tag_id of screen main_screen_id.
    { rule = { class = "Remmina" },
      properties = { tag = tags[main_screen_id][rdesktop_tag_id] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

awful.util.spawn_with_shell("numlockx")
run_once("davmail")

run_once("nm-applet")
run_once("blueman-applet")
run_once("thunderbird")
run_once("firefox")
--run_once("xchat")
run_once("pidgin")
run_once("steam")
run_once("spotify")
run_once("remmina")
run_once("gnome-screensaver")
run_once('~/.config/awesome/locker.sh')
awful.util.spawn_with_shell("dropbox running && dropbox start")
run_once("caffeine")

-- workaround
awful.util.spawn_with_shell("setxkbmap fr")
