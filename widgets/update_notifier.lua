local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local yaml = require("yaml")

local config = require("module.config")

local shouldUpdate = false

local indicator = wibox.widget {
  {
    id = "icon",
    image = "/home/caellian/.config/awesome/theme/icons/no-update.svg", --beautiful.icons.widget.updater.no,
    widget = wibox.widget.imagebox
  },
  layout = wibox.container.margin
}

local update_notifier_widget = wibox.widget {
  indicator,
  layout = wibox.layout.fixed.horizontal,
}

function updateInfo()
  awful.spawn.easy_async("curl " .. config.versions_url, function(stdout, stderr, exitreason, exitcode)
    local versions = yaml.load(stdout)
    local latestVersion = versions.latestVersion

    -- Find the latest version object.
    -- This for loop should only need to iterate over the first element because
    -- the latest version is on top of the list.
    for i,version in ipairs(versions.versionHistory) do
      if latestVersion == math.floor(version.major) .. "." .. math.floor(version.minor) .. "." .. math.floor(version.patch) then
        latestVersion = version
      end
    end

    if type(latestVersion) == "string" then
      -- Badly formatted versions file - latest update isn't in version history.
      -- TODO: Tell user to change versions_url in config.
      naughty.notify({ preset = naughty.config.presets.warning,
                       title = "BAD FORMAT",
                       text = "Versions file is badly formatted." })
    else
      if config.version.major < latestVersion.major then
        indicator.icon.image = "/home/caellian/.config/awesome/theme/icons/update.svg"
        showUpdateNotification(latestVersion, "major")
        shouldUpdate = true
      elseif config.version.major == latestVersion.major then
        if config.version.minor < latestVersion.minor then
          indicator.icon.image = "/home/caellian/.config/awesome/theme/icons/update.svg"
          showUpdateNotification(latestVersion, "minor")
          shouldUpdate = true
        elseif config.version.minor == latestVersion.minor then
          if config.version.patch < latestVersion.patch then
            showUpdateNotification(latestVersion, "patch")
            shouldUpdate = true
          elseif config.version.patch == latestVersion.patch then
            showUpdateNotification({
              main = "Up to date!",
              description = "Version: " .. math.floor(latestVersion.major) .. "." .. math.floor(latestVersion.minor) .. "." .. math.floor(latestVersion.patch)
            }, "none")
            -- else -- Dev version - don't notify
          end
          -- else -- Dev version - don't notify
        end
        -- else -- Dev version - don't notify
      end
      if shouldUpdate then
        indicator.icon.image = "/home/caellian/.config/awesome/theme/icons/update.svg"
      end
    end
  end)
end

update_notifier_widget:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    updateInfo()
    if shouldUpdate then
      awful.spawn.easy_async("git pull ~/.config/awesome/", function(stdout, stderr, exitreason, exitcode)
        awful.spawn.easy_async("awesome -r")
        indicator.icon.image = "/home/caellian/.config/awesome/theme/icons/no-update.svg"
      end)
      shouldUpdate = false
    end
  end
end)


function showUpdateNotification(update, update_type)
  if update_type == nil or update_type == "none" then
    naughty.notify {
      text = update.description,
      title = update.main,
      timeout = 5,
      hover_timeout = 0.5,
      position = "bottom_right",
      bg = beautiful.scheme.background.green,
      fg = beautiful.scheme.foreground.green,
      width = 100,
    }
  elseif update_type == "patch" then
    naughty.notify {
      text = update.description,
      title = update.main .. " (v" .. math.floor(update.major) .. "." .. math.floor(update.minor) .. "." .. math.floor(update.patch) .. ")",
      timeout = 5,
      hover_timeout = 0.5,
      position = "bottom_right",
      bg = beautiful.scheme.background.purple,
      fg = beautiful.scheme.foreground.purple,
      width = 300,
    }
  elseif update_type == "minor" then
    naughty.notify {
      text = update.description,
      title = update.main .. " (v" .. math.floor(update.major) .. "." .. math.floor(update.minor) .. "." .. math.floor(update.patch) .. ")",
      timeout = 5,
      hover_timeout = 0.5,
      position = "bottom_right",
      bg = beautiful.scheme.background.yellow,
      fg = beautiful.scheme.foreground.yellow,
      width = 300,
    }
  elseif update_type == "major" then
    naughty.notify {
      text = update.description,
      title = update.main .. " (v" .. math.floor(update.major) .. "." .. math.floor(update.minor) .. "." .. math.floor(update.patch) .. ")",
      timeout = 5,
      hover_timeout = 0.5,
      position = "bottom_right",
      bg = beautiful.scheme.background.red,
      fg = beautiful.scheme.foreground.red,
      width = 300,
    }
  end
end

-- updateInfo() -- Uncomment to enable checking for updates on start

return update_notifier_widget
