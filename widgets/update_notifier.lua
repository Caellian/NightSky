local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local yaml = require("yaml")

local config = require("module.config")

local current_icon = beautiful.icons.widget.updater.no

local indicator = wibox.widget {
    image = function() return current_icon end,
    resize = false,
    widget = wibox.widget.imagebox,
    set_value = function(self, value)
        self.value = value
    end,
}

local update_notifier_widget = wibox.widget {
  indicator,
  layout = wibox.layout.fixed.horizontal,
}

function updateInfo()
  spawn.easy_async("curl " .. config.versions_url, function(stdout, stderr, exitreason, exitcode)
    local versions = yaml.load(stdout)
    local latestVersion = versions.latestVersion

    -- Find the latest version object.
    -- This for loop should only need to iterate over the first element because
    -- the latest version is on top of the list.
    for i,version in ipairs(versions.versionHistory) do
      if (latestVersion == version.major .. "." .. version.minor .. "." .. version.patch) {
        latestVersion = version
      }
    end

    if type(latestVersion) == "string" then
      -- Badly formatted versions file - latest update isn't in version history.
      -- TODO: Tell user to change versions_url in config.
    else
      if config.version.major < latestVersion.major then
        showUpdateNotification(latestVersion, "major")
      elseif config.version.major == latestVersion.major then
        if config.version.minor < latestVersion.minor then
          showUpdateNotification(latestVersion, "minor")
        elseif config.version.minor == latestVersion.minor then
          if config.version.patch < latestVersion.patch then
            showUpdateNotification(latestVersion, "patch")
          elseif config.version.patch == latestVersion.patch then
            showUpdateNotification({
              name = "Up to date!",
              description = "Version: " .. latestVersion.major .. "." .. latestVersion.minor .. "." .. latestVersion.patch
            }, "generic")
            -- else -- Dev version - don't notify
          end
          -- else -- Dev version - don't notify
        end
        -- else -- Dev version - don't notify
      end
    end
  end)
end

update_notifier_widget:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    updateInfo()
  end
end)


function showUpdateNotification(update, update_type)
  if update_type == "generic" then
    naughty.notify {
      text = update.description,
      title = update.name,
      timeout = 5,
      hover_timeout = 0.5,
      position = "bottom_right",
      bg = beautiful.scheme.background.yellow,
      fg = beautiful.scheme.foreground.yellow,
      width = 300,
    }
  end
end

return update_notifier_widget
