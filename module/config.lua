local yaml = require("yaml")

local configFiles = {"~/.config/awesome/config/general.yml"}
local cfg = {}

for i,cfgFile in pairs(configFiles) do
  content = io.popen("cat " .. cfgFile):read("*all")
  it = yaml.load(content)

  for k,v in pairs(it) do
    cfg[k] = v
  end
end

return cfg
