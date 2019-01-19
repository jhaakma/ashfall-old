
--[[
    When the player looks at a water source (fresh water, wells, etc), 
    a tooltip will display, and pressing the activate button will bring up
    a menu that allows the player to drink or fill up a container with water.
]]--


local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")
local common = require("mer.ashfall.common")
local activators = require("mer.ashfall.activators")
-- register UI Ids


local function refillContainer(bottleId)
    mwscript.removeItem({reference = tes3.player, item = bottleId})
    
    local newContainer
    if string.find(string.lower(bottleId), "flask") then
        
        newContainer = "fw_water_flask_full"
    else
        newContainer = "fw_water_bottle_full"
    end
    mwscript.addItem({reference = tes3.player, item = newContainer})
    tes3.playSound({reference = tes3.player, sound="Swim Left"})
    tes3.messageBox("%s has been added to your inventory", tes3.getObject(newContainer).name)
end



--Buttons list
local buttons = {}
local bDrink = "Drink"
local bFillBottle = "Fill bottle"
local bNothing = "Nothing"
--Menu for drinking and refilling water bottle
local function activateWaterMenu(e)
    local buttonIndex = e.button + 1
    --Drink
    if buttons[buttonIndex] == bDrink then 
        tes3.playSound({reference=tes3.getPlayerRef(), sound="Swallow"})
        thirstCommon.drinkAmount(100)

    --refill
    elseif buttons[buttonIndex] == bFillBottle then
        local filled
        --first refill semiFilled containers
        for _, bottleId in pairs(thirstCommon.containerList.partialFilled) do
            if mwscript.getItemCount({reference = tes3.player, item = bottleId}) > 0 then
                refillContainer(bottleId)
                filled = true
                break
            end
        end    

        --check bottles
        if not filled then
            for _, bottleId in ipairs(thirstCommon.containerList.bottles) do
                if mwscript.getItemCount({reference = tes3.player, item = bottleId}) > 0 then
                    refillContainer(bottleId)
                    filled = true
                    break
                end
            end
        end
        --Flasks        
        if not filled then
            for _, bottleId in ipairs(thirstCommon.containerList.flasks) do
                if mwscript.getItemCount({reference = tes3.player, item = bottleId}) > 0 then
                    refillContainer(bottleId)
                    filled = true
                    break
                end
            end            
        end
        --Nothing to fill
        if not filled then
            tes3.messageBox("You have no containers")
        end
    end
end

--Create messageBox for water menu
local function callWatermenu()
    buttons = { bDrink, bFillBottle, bNothing }
    tes3.messageBox{
        message = "What would you like to do?",
        buttons = buttons,
        callback = activateWaterMenu
    }
end
local lookingAtWater
--If player presses activate while looking at water source
--(determined by presence of tooltip), then open the water menu
local function onActivateWater()
    local thirstActive = (
        common.data and
        common.data.mcmOptions.enableThirst
    )
    local inputController = tes3.worldController.inputController
    local keyTest = inputController:keybindTest(tes3.keybind.activate)
    if (keyTest and thirstActive) then
        if lookingAtWater then
            callWatermenu()
        end
    end
end


--Use rayTest to see if the player is looking at a water source
local function checkForWater()
    local thirstActive = (
        common.data and
        common.data.mcmOptions.enableThirst
    )
    if thirstActive and not tes3.menuMode() then
        local activator = activators.currentActivator
        lookingAtWater =
        (
               activator == activators.activatorList.water 
            or activator == activators.activatorList.well
            or activator == activators.activatorList.keg
        )
    end
end

--Register events
event.register("keyDown", onActivateWater )
event.register("enterFrame", checkForWater)