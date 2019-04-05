local common = require("mer.ashfall.common")

local Activator = {}
Activator.types = {
    waterSource = "waterSource",
    cookingUtensil = "cookingUtensil",
    fire = "fire",
    campfire = "campfire",
    woodSource = "woodSource",
}
Activator.type = nil
Activator.name = ""
Activator.mcmSetting = nil
Activator.ids = {}

function Activator:new(data)
    local t = data or {}
    setmetatable(t, self)
    self.__index = self
    return t
end

return Activator