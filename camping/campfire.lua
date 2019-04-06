local Campfire = require("mer.ashfall.objects.CampFire")
local Activator = require("mer.ashfall.objects.Activator")
local common = require ("mer.ashfall.common")
local logger = require("mer.ashfall.logger")
local function onActivateCampfire(e)
    local campingEnabled = (
        common.data and
        common.data.mcmSettings.enableCooking
    )
    if campingEnabled then
        logger.info("creating campfire")
        local campfire = Campfire:new({ reference = e.ref })
        logger.info("calling menu")
        campfire:showMenu()
    end
end

event.register(
    "Ashfall:ActivatorActivated", 
    onActivateCampfire, 
    { filter = Activator.types.campfire } 
)