local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local config = require("module.config")

--- Main ram widget shown on wibar
local ramgraph_widget = wibox.widget {
  border_width = 0,
  colors = {
    beautiful.scheme.foreground.normal, beautiful.scheme.widget.background.shadow
  },
  display_labels = false,
  forced_width = 25,
  widget = wibox.widget.piechart
}

--- Widget which is shown when user clicks on the ram widget
local w = wibox {
  height = 200,
  width = 400,
  ontop = true,
  expand = true,
  bg = beautiful.scheme.widget.background.normal,
  max_widget_size = 500
}

w:setup {
  border_width = 1,
  colors = {
    beautiful.scheme.widget.foreground.normal.."aa",
    beautiful.scheme.widget.foreground.normal.."55",
    beautiful.scheme.widget.foreground.normal.."88",
  },
  display_labels = true,
  forced_width = 25,
  id = 'pie',
  widget = wibox.widget.piechart
}

local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap

local function getPercentage(value)
    return math.floor(value / (total+total_swap) * 100 + 0.5) .. '%'
end

watch('bash -c "free | grep -z Mem.*Swap.*"', 1,
  function(widget, stdout, stderr, exitreason, exitcode)
    total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap =
      stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')

    widget.data = { used, total-used } widget.data = { used, total-used }

    if w.visible then
      w.pie.data_list = {
        {'used ' .. getPercentage(used + used_swap), used + used_swap},
        {'free ' .. getPercentage(free + free_swap), free + free_swap},
        {'buff_cache ' .. getPercentage(buff_cache), buff_cache}
      }
    end
  end,
  ramgraph_widget
)

ramgraph_widget:connect_signal("mouse::enter", function()
  awful.placement.bottom_right(w, { margins = {bottom = 35, right = 10}, parent = awful.screen.focused() })
  w.pie.data_list = {
    {'used ' .. getPercentage(used + used_swap), used + used_swap},
    {'free ' .. getPercentage(free + free_swap), free + free_swap},
    {'buff_cache ' .. getPercentage(buff_cache), buff_cache}
  }
  w.visible = true
end)
ramgraph_widget:connect_signal("mouse::leave", function()
  w.visible = false
end)
ramgraph_widget:connect_signal("button::press", function(_, _, _, button)
    if (button == 1) then
      awful.spawn(config.commands.task_manager)
    end
end)

return ramgraph_widget
