local common = require ("mer.ashfall.common.common")

local function activatedCauldron(e)

end

event.register(
    "Ashfall:ActivatorActivated", 
    activatedCauldron, 
    { filter = common.staticConfigs.activatorConfig.types.cauldron } 
)

local function updateTooltip()

end

event.register("Ashfall:Activator_tooltip_cauldron", updateTooltip)



local function onCauldronCreate(e)
    if 
end
event.register("referenceSceneNodeCreated", onCauldronCreate)