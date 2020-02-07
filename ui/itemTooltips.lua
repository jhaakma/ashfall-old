
--Tooltips
local common = require("mer.ashfall.common.common")
local tooltipsComplete = include("Tooltips Complete.interop")
local objectIds = common.staticConfigs.objectIds
local tooltipData = {
    { id = objectIds.firewood, description = "Fuel used at a campfire." },
    { id = objectIds.kettle, description = "Use at a campfire to brew tea." },
    { id = objectIds.grill, description = "Use at a campfire to cook meat and vegetables." },
    { id = objectIds.cookingPot, description = "Use at a campfire to boil water and cook stews." }
}

for _, data in ipairs(tooltipData) do
    if tooltipsComplete then
        tooltipsComplete.addTooltip(data.id, data.description, data.itemType)
    end
end