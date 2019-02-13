local result = {}

local awful = require("awful")
local yaml = require("yaml")

local configFile = "~/.config/awesome/config/tags.yml"
local tags = yaml.load(io.popen("cat " .. configFile):read("*all"))

local layouts = {}

layouts["awful.layout.suit.tile"] = awful.layout.suit.tile
layouts["awful.layout.suit.tile.left"] = awful.layout.suit.tile.left
layouts["awful.layout.suit.tile.bottom"] = awful.layout.suit.tile.bottom
layouts["awful.layout.suit.tile.top"] = awful.layout.suit.tile.top
layouts["awful.layout.suit.floating"] = awful.layout.suit.floating
layouts["awful.layout.suit.fair"] = awful.layout.suit.fair
layouts["awful.layout.suit.fair.horizontal"] = awful.layout.suit.fair.horizontal
layouts["awful.layout.suit.spiral"] = awful.layout.suit.spiral
layouts["awful.layout.suit.spiral.dwindle"] = awful.layout.suit.spiral.dwindle
layouts["awful.layout.suit.max"] = awful.layout.suit.max
layouts["awful.layout.suit.max.fullscreen"] = awful.layout.suit.max.fullscreen
layouts["awful.layout.suit.magnifier"] = awful.layout.suit.magnifier
layouts["awful.layout.suit.corner.nw"] = awful.layout.suit.corner.nw
layouts["awful.layout.suit.corner.ne"] = awful.layout.suit.corner.ne
layouts["awful.layout.suit.corner.sw"] = awful.layout.suit.corner.sw
layouts["awful.layout.suit.corner.se"] = awful.layout.suit.corner.se

function handleLayout(id)
  return layouts[id]
end

for k,v in pairs(tags) do
  local filled = v
  filled["layout"] = handleLayout(v["layout"])
  result[k] = filled
end

return result
