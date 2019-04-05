local common = require ("mer.ashfall.common")
local activators = require("mer.ashfall.activators.activatorController")
local Activator = require("mer.ashfall.objects.Activator")
local utensils = require("mer.ashfall.cooking.utensils")
local recipes = require("mer.ashfall.cooking.recipes")
local CookingMenu = require("mer.ashfall.cooking.cookingMenu")


local function onActivate(e)
    local inputController = tes3.worldController.inputController
    local pressedActivateKey = inputController:keybindTest(tes3.keybind.activate)
    if pressedActivateKey then
        local hungerActive = (
            common.data and
            common.data.mcmSettings.enableHunger
        )
        if hungerActive then
            local currentActivator = activators.getCurrentActivator()
            local lookingAtUtensil = ( 
                currentActivator and
                currentActivator.type == Activator.types.cookingUtensil
            )
            if lookingAtUtensil then
                mwse.log("Creating %s menu", currentActivator.name)
                menu = CookingMenu:new({
                    name = currentActivator.name
                })
                menu:create()
                return
            else
                --mwse.log("Not looking at a utensil")
            end
        end
    end
end
 
event.register("keyDown", onActivate )

