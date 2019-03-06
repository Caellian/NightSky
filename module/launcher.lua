local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")

local utils = require("module.utils")

local hotkeys_popup = require("awful.hotkeys_popup").widget

local yaml = require("yaml")

local configFiles = {"~/.config/awesome/config/general.yml", "~/.config/awesome/config/launcher.yml"}
local cfg = {}

for i,cfgFile in pairs(configFiles) do
  content = io.popen("cat " .. cfgFile):read("*all")
  it = yaml.load(content)

  for k,v in pairs(it) do
    cfg[k] = v
  end
end

function getMacro(id)
  local result = nil
  if id == "#hotkeys" then
    result = function() return false, hotkeys_popup.show_help end
  elseif id == "#restart" then
    result = awesome.restart
  end

  return result
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function traverseNode(node)
  local items = {}
  local itemCount = 1

  for k,v in spairs(node) do
    if type(v) == "table" then
      items[itemCount] = {k, traverseNode(v)}
      itemCount = itemCount + 1
    elseif type(v) == "string" then
      local macro = getMacro(v)
      if macro == nil then
        local command = v
        for k,v in pairs(cfg.commands) do
          command = command:gsub("%$" .. k, v)
        end
        items[itemCount] = {k, command}
      else
        items[itemCount] = {k, macro}
      end
      itemCount = itemCount + 1
    end
  end

  return items
end

mainmenu = awful.menu({ items = traverseNode(cfg.children) })

launcher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mainmenu })

return launcher
