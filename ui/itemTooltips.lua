
--Tooltips
local common = require("mer.ashfall.common.common")
local tooltipsComplete = include("Tooltips Complete.interop")
local tooltipData = {
    { id = common.staticConfigs.objectIds.firewood, description = "Fuel used at a campfire." },
    { id = common.staticConfigs.objectIds.kettle, description = "Use at a campfire to brew tea." },
    { id = common.staticConfigs.objectIds.grill, description = "Use at a campfire to cook meat and vegetables." },
    { id = common.staticConfigs.objectIds.cookingPot, description = "Use at a campfire to boil water and cook stews." }
}

for _, data in ipairs(tooltipData) do
    if tooltipsComplete then
        tooltipsComplete.addTooltip(data.id, data.description, data.itemType)
    end
end