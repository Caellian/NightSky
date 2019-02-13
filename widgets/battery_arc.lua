

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local HOME = os.getenv("HOME")

local battery_text = wibox.widget.textbox(" POW: ")

local batteryarc = wibox.widget {
    max_value = 1,
    thickness = 4,
    start_angle = 4.71238898, -- 2pi*3/4
    forced_height = 20,
    forced_width = 20,
    bg = beautiful.scheme.background.normal,
    paddings = 2,
    widget = wibox.container.arcchart,
    set_value = function(self, value)
        self.value = value
    end,
}

local batteryarc_widget = wibox.widget {
  battery_text,
  wibox.container.mirror(batteryarc, { horizontal = true }),
  layout = wibox.layout.fixed.horizontal,
}

local last_battery_check = os.time()

watch("acpi -i", 5,
    function(widget, stdout, stderr, exitreason, exitcode)
        local batteryType

        local battery_info = {}
        local capacities = {}
        for s in stdout:gmatch("[^\r\n]+") do
            local status, charge_str, time = string.match(s, '.+: (%a+), (%d?%d?%d)%%,?.*')
            if string.match(s, 'rate information') then
                -- ignore such line
            elseif status ~= nil then
                table.insert(battery_info, {status = status, charge = tonumber(charge_str)})
            else
                local cap_str = string.match(s, '.+:.+last full capacity (%d+)')
                table.insert(capacities, tonumber(cap_str))
            end
        end

        local capacity = 0
        for i, cap in ipairs(capacities) do
            capacity = capacity + cap
        end

        local charge = 0
        local status
        for i, batt in ipairs(battery_info) do
            if batt.charge >= charge then
                status = batt.status -- use most charged battery status
                -- this is arbitrary, and maybe another metric should be used
            end

            charge = charge + batt.charge * capacities[i]
        end
        charge = charge / capacity

        widget.value = charge / 100

        if status == 'Charging' then
          batteryarc.colors = { beautiful.scheme.widget.background.green }
        elseif charge < 15 then
            batteryarc.colors = { beautiful.scheme.widget.background.red }
            if status ~= 'Charging' and os.difftime(os.time(), last_battery_check) > 300 then
                -- if 5 minutes have elapsed since the last warning
                last_battery_check = time()

                show_battery_warning()
            end
        elseif charge > 15 and charge < 40 then
            batteryarc.colors = { beautiful.scheme.widget.background.yellow }
        else
            batteryarc.colors = { beautiful.scheme.preset.primary }
        end
    end,
    batteryarc)

-- Popup with battery info
local notification
function show_battery_status()
    awful.spawn.easy_async([[bash -c 'acpi']],
        function(stdout, _, _, _)
            notification = naughty.notify {
                text = stdout,
                title = "Battery status",
                timeout = 5,
                hover_timeout = 0.5,
                width = 200,
            }
        end)
end

batteryarc_widget:connect_signal("mouse::enter", function() show_battery_status() end)
batteryarc_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)

function show_battery_warning()
    naughty.notify {
        text = "Please save your progress and begin approaching the nearest power socket.",
        title = "Battery is dying!",
        timeout = 5,
        hover_timeout = 0.5,
        position = "bottom_right",
        bg = beautiful.scheme.background.red,
        fg = beautiful.scheme.foreground.red,
        width = 300,
    }
end

return batteryarc_widget
