local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")
local config = require("module.config")

local cpugraph_widget = wibox.widget {
    max_value = 100,
    background_color = "#00000000",
    forced_width = 50,
    step_width = 2,
    step_spacing = 1,
    widget = wibox.widget.graph
}

--- By default graph widget goes from left to right, so we mirror it and push up a bit
local cpu_widget = wibox.container.margin(wibox.container.mirror(cpugraph_widget, { horizontal = true }), 0, 0, 0, 2)

local total_prev = 0
local idle_prev = 0

watch([[bash -c "cat /proc/stat | grep '^cpu '"]], 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
        stdout:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s')

        local total = user + nice + system + idle + iowait + irq + softirq + steal

        local diff_idle = idle - idle_prev
        local diff_total = total - total_prev
        local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

        widget:set_color(diff_usage > 80 and beautiful.scheme.widget.foreground.red
                                          or beautiful.scheme.widget.foreground.normal)

        widget:add_value(diff_usage)

        total_prev = total
        idle_prev = idle
    end,
    cpugraph_widget
)

cpu_widget:connect_signal("button::press", function(_, _, _, button)
    if (button == 1) then
      awful.spawn(config.commands.task_manager)
    end
end)

return cpu_widget
