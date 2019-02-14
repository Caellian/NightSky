local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

local GET_VOLUME_CMD = 'pamixer --get-volume'
local SET_VOLUME_CMD = 'pamixer --set-volume '
local TOG_VOLUME_CMD = 'pamixer -t'
local TON_VOLUME_CMD = 'pamixer -u'

local volume = 0
local muted = false

local volume_text = wibox.widget.textbox(" VOL: ")

local volumearc = wibox.widget {
    max_value = 1,
    thickness = 4,
    start_angle = 4.71238898, -- 2pi*3/4
    forced_height = 20,
    forced_width = 20,
    bg = beautiful.scheme.widget.background.shadow,
    paddings = 2,
    widget = wibox.container.arcchart
}

local volumearc_widget = wibox.widget {
  volume_text,
  wibox.container.mirror(volumearc, { horizontal = true }),
  layout = wibox.layout.fixed.horizontal,
}

local update_graphic = function(widget, stdout, _, _, _)
    volume = tonumber(stdout)

    widget.value = volume / 100

    widget.colors = muted and { beautiful.scheme.widget.background.red } or { beautiful.scheme.preset.primary }

end

volumearc_widget:connect_signal("button::press", function(_, _, _, button)
    if (button == 4) then
      newval = math.min(volume + 5, 100)
      awful.spawn(SET_VOLUME_CMD .. tostring(newval), false)
    elseif (button == 5) then
      newval = math.max(volume - 5, 0)
      awful.spawn(SET_VOLUME_CMD .. tostring(newval), false)
    elseif (button == 1) then
      muted = not muted
      awful.spawn(TOG_VOLUME_CMD, false)
    end


    spawn.easy_async(GET_VOLUME_CMD, function(stdout, stderr, exitreason, exitcode)
        update_graphic(volumearc, stdout, stderr, exitreason, exitcode)
    end)
end)

awful.spawn(TON_VOLUME_CMD, false)

watch(GET_VOLUME_CMD, 1, update_graphic, volumearc)

return volumearc_widget
