local Campfire = require("mer.ashfall.objects.CampFire")
local Activator = require("mer.ashfall.objects.Activator")

local function onActivateCampfire(e)
    mwse.log("creating campfire")
    local campfire = Campfire:new({ reference = e.ref })
    mwse.log("calling menu")
    campfire:showMenu()
end

event.register(
    "Ashfall:ActivatorActivated", 
    onActivateCampfire, 
    { filter = Activator.types.campfire } 
)