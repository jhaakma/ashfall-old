local common = require ("mer.ashfall.common.common")
local activators = require("mer.ashfall.activators.activatorController")
local Activator = require("mer.ashfall.objects.Activator")
local CookingMenu = require("mer.ashfall.cooking.cookingMenu")

local function onActivate(e)
    local inputController = tes3.worldController.inputController
    local pressedActivateKey = inputController:keybindTest(tes3.keybind.activate)
    if pressedActivateKey and cookingEnabled then
        local cookingActive = (
            common.data and
            common.data.mcmSettings.enableHunger and
            common.data.mcmSettings.enableCooking
        )
        if cookingActive then
            local currentActivator = activators.getCurrentActivator()
            local lookingAtUtensil = ( 
                currentActivator and
                currentActivator.type == Activator.types.cookingUtensil
            )
            if lookingAtUtensil then
                common.log.info("Creating %s menu", currentActivator.name)
                menu = CookingMenu:new({
                    name = currentActivator.name
                })
                menu:create()
                return
            else
                common.log.info("Not looking at a utensil")
            end
        end
    end
end
 
event.register("keyDown", onActivate )

