
--[[
    When the player looks at a water source (fresh water, wells, etc), 
    a tooltip will display, and pressing the activate button will bring up
    a menu that allows the player to drink or fill up a container with water.
]]--
 

local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")
local common = require("mer.ashfall.common")
local Activator = require("mer.ashfall.objects.Activator")

local function callWaterMenuAction(callback)
    if common.data.drinkingRain then
        common.data.drinkingRain = false
        common.fadeTimeOut( 0.25, 2, callback )
    else
        callback()
    end
end

local function fillContainer(e)
    callWaterMenuAction(function()
        tes3.playSound({reference = tes3.player, sound = "Swim Left"})
        e.itemData.data.currentWaterAmount = e.capacity
        tes3.messageBox("%s filled with water.", e.object.name)
        tes3ui.updateInventoryTiles()
    end)
end

local function iterateBottles()
    --First pass: check for partially filled
    for stack in tes3.iterate(tes3.player.object.inventory.iterator) do
        local object = stack.object
        if object then
            local bottleData = thirstCommon.bottleList[object.id]
            if bottleData then
                if stack.variables then
                    for _, itemData in ipairs(stack.variables) do
                        local capacity = bottleData.capacity
                        local currentAmount = itemData.data.currentWaterAmount
                        if not currentAmount or currentAmount < capacity then
                            
                            fillContainer{
                                object = object, 
                                itemData = itemData,
                                capacity = capacity
                            }
                            
                            return true
                        end
                    end
                end
            end
        end
    end
    --second pass: check for empty (no item data)
    for stack in tes3.iterate(tes3.player.object.inventory.iterator) do
        local object  = stack.object
        if object then
            local bottleData = thirstCommon.bottleList[object.id]
            if bottleData then
                if not stack.variables or stack.count > #stack.variables then
                    local capacity = bottleData.capacity
                    local itemData = tes3.addItemData{ 
                        to = tes3.player, 
                        item = object,
                        updateGUI = true
                    }
                    fillContainer{
                        object = object, 
                        itemData = itemData, 
                        capacity = capacity
                    }
                    return true
                end
            end
        end
    end
    tes3.messageBox("You have no empty bottles.")
    common.data.drinkingRain = false
end

--Buttons list
local buttons = {}
local bDrink = "Drink"
local bFillBottle = "Fill bottle"
local bNothing = "Nothing"
local function activateWaterMenu(e)
    local buttonIndex = e.button + 1

    --Drink
    if buttons[buttonIndex] == bDrink then
        if common.data.thirst <= 0.1 then
            tes3.messageBox("You are fully hydrated.")
            return
        end
        callWaterMenuAction(function()
            thirstCommon.drinkAmount(100)
        end)

    --refill
    elseif buttons[buttonIndex] == bFillBottle then
        iterateBottles()
    else
        common.data.drinkingRain = false
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

--If player presses activate while looking at water source
--(determined by presence of tooltip), then open the water menu
local function onActivateWater(e)
    local thirstActive = (
        common.data and
        common.data.mcmSettings.enableThirst
    )
    if ( thirstActive ) then
        callWatermenu()
    end
end

--Register events
event.register(
    "Ashfall:ActivatorActivated", 
    callWatermenu, 
    { filter = Activator.types.waterSource } 
)



local function checkDrinkRain()
    --thirst active
    local thirstActive = common.data and common.data.mcmSettings.enableThirst
    --activate button
    local inputController = tes3.worldController.inputController
    local pressedActivate = inputController:keybindTest(tes3.keybind.activate)
    --raining
    local weather = tes3.getCurrentWeather()
    local raining = (
            weather and weather.index == tes3.weather.rain or 
            weather and weather.index == tes3.weather.thunder
            
    )
    --looking up
    local lookingUp = (
        tes3.getCameraVector().z > 0.99
    )
    --uncovered
    local uncovered = common.data and not common.data.isSheltered


    local doDrink = (
        thirstActive and
        pressedActivate and 
        raining and 
        lookingUp and 
        uncovered
    )
    if doDrink then
        common.data.drinkingRain = true
        callWatermenu()
    end
end
event.register("keyDown", checkDrinkRain )
