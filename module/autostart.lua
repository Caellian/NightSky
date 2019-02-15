local awful = require('awful')

local yaml = require("yaml")

local configFiles = {"~/.config/awesome/config/autostart.yml"}
local cfg = {}

for i,cfgFile in pairs(configFiles) do
  content = io.popen("cat " .. cfgFile):read("*all")
  it = yaml.load(content)

  for k,v in pairs(it) do
    cfg[k] = v
  end
end

for i,command in ipairs(cfg.commands) do
  awful.spawn.single_instance(command)
end

-- Might be useful later
return cfg
