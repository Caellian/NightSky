local wibox = require("wibox")
local beautiful = require("beautiful")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")

local GET_BRIGHTNESS_CMD = "light -G"
local INC_BRIGHTNESS_CMD = "light -A 1"
local DEC_BRIGHTNESS_CMD = "light -U 1"

local brightness_text = wibox.widget.textbox(" LUM: ")

local brightnessarc = wibox.widget {
    max_value = 1,
    value = 0.5,
    thickness = 4,
    start_angle = 4.71238898, -- 2pi*3/4
    forced_height = 20,
    forced_width = 20,
    bg = beautiful.scheme.widget.background.shadow,
    paddings = 2,
    widget = wibox.container.arcchart
}

local brightness_widget = wibox.widget {
  brightness_text,
  wibox.container.mirror(brightnessarc, { horizontal = true }),
  layout = wibox.layout.fixed.horizontal,
}

local update_widget = function(widget, stdout, stderr, exitreason, exitcode)
    local brightness_level = tonumber(string.format("%.0f", stdout))
    brightnessarc.value = brightness_level / 100
end

function toggleBlueLightFilter()
  spawn.easy_async("pidof xflux", function(stdout, stderr, exitreason, exitcode)
    if stdout == "" then
      spawn("xflux -l 45.328979 -g 14.457664 -k 2000", false)
      brightnessarc.colors = { beautiful.scheme.widget.background.yellow }
    else
      spawn("kill -15 " .. stdout, false)
      brightnessarc.colors = { beautiful.scheme.preset.primary }
    end
  end)
end

brightness_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4)     then spawn(INC_BRIGHTNESS_CMD, false)
    elseif (button == 5) then spawn(DEC_BRIGHTNESS_CMD, false)
    elseif (button == 1) then toggleBlueLightFilter()
    end

    spawn.easy_async(GET_BRIGHTNESS_CMD, function(stdout, stderr, exitreason, exitcode)
        update_widget(brightness_widget, stdout, stderr, exitreason, exitcode)
    end)
end)

spawn.easy_async("pidof xflux", function(stdout, stderr, exitreason, exitcode)
  if stdout == "" then
    brightnessarc.colors = { beautiful.scheme.preset.primary, }
  else
    brightnessarc.colors = { beautiful.scheme.widget.background.yellow, }
  end
end)

watch(GET_BRIGHTNESS_CMD, 5, update_widget, brightness_text)

return brightness_widget
