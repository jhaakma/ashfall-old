
--Tooltips
local tooltipsComplete = include("Tooltips Complete.interop")
local tooltipData = {
    { id = "a_firewood", description = "Fuel used at a campfire." },
    { id = "ashfall_kettle", description = "Use at a campfire to brew tea." },
    { id = "ashfall_grill", description = "Use at a campfire to cook meat and vegetables." }
}

for _, data in ipairs(tooltipData) do
    if tooltipsComplete then
        tooltipsComplete.addTooltip(data.id, data.description, data.itemType)
    end
end