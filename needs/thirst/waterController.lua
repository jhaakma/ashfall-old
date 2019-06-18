
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

--Fill a bottle to max water capacity
local function fillContainer(e)
    callWaterMenuAction(function()
        tes3.playSound({reference = tes3.player, sound = "Swim Left"})
        e.itemData.data.currentWaterAmount = e.amount
        tes3.messageBox("%s filled with water.", e.object.name)
        tes3ui.updateInventoryTiles()
    end)
end

--Find a container to fill in the player inventory
local function iterateBottles()
    --First pass: check for partially filled
    for stack in tes3.iterate(tes3.player.object.inventory.iterator) do
        local object = stack.object
        if object then
            local bottleData = thirstCommon.getBottleData(object.id)
            if bottleData then
                if stack.variables then
                    for _, itemData in ipairs(stack.variables) do
                        local capacity = bottleData.capacity
                        local currentAmount = itemData.data.currentWaterAmount
                        if not currentAmount or currentAmount < capacity then
                            
                            fillContainer{
                                object = object, 
                                itemData = itemData,
                                amount = capacity
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
            local bottleData = thirstCommon.getBottleData(object.id)
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
                        amount = capacity
                    }
                    return true
                end
            end
        end
    end
    tes3.messageBox("You have no empty bottles.")
    common.data.drinkingRain = false
end


local buttons = {}
local bDrink = "Drink"
local bFillBottle = "Fill bottle"
local bNothing = "Nothing"
local function menuButtonPressed(e)
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
        callback = menuButtonPressed
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


--Look straight up at the rain and activate to bring up water menu
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



--Player activates a bottle with water in it
local function drinkFromContainer(e)
    local standardSipSize = 100
    local itemData = e.itemData and e.itemData.data
    local liquidLevel = (
        itemData and
        itemData.currentWaterAmount
    )
    local doDrink = (
        common.data.mcmOptions.enableThirst and
        liquidLevel
    )
    if doDrink then

        local thisSipSize = standardSipSize

        --Only drink as much in bottle
        thisSipSize = math.min( thisSipSize, liquidLevel )

        --Only drink as much as player needs
        local hydrationNeeded = common.data.thirst
        thisSipSize = math.min( hydrationNeeded, thisSipSize)

        --Reduce liquid in bottle
        itemData.currentWaterAmount = liquidLevel - thisSipSize
        if itemData.currentWaterAmount <= 0 then
            itemData.currentWaterAmount = nil
            timer.frame.delayOneFrame(function()
                mwscript.removeItem{ 
                    reference = tes3.player, 
                    item = e.item
                }
                timer.frame.delayOneFrame(function()
                    mwscript.addItem{ 
                        reference = tes3.player, 
                        item = e.item
                    }
                end)
            end)
        end

        thirstCommon.drinkAmount(thisSipSize)
    end
end
event.register("equip", drinkFromContainer, { filter = tes3.player } )


--First time entering a cell, add water to random bottles/containers
local chanceToFill = 0.2
local fillMin = 5
local function addWaterToWorld(e)
    local wateredCells = common.data.wateredCells
    if not wateredCells[string.lower(e.cell.id)] then
        --mwse.log("Adding water to bottles")
        wateredCells[string.lower(e.cell.id)] = true

        for ref in e.cell:iterateReferences(tes3.objectType.miscItem) do
            local bottleData = thirstCommon.getBottleData(ref.object.id)
            if bottleData and not ref.data.currentWaterAmount then
                if math.random() < chanceToFill then
                    local fillAmount = math.random(fillMin, bottleData.capacity)
                    ref.data.currentWaterAmount = fillAmount
                    ref.modified = true
                    --mwse.log("Filled %s will %d water", ref.object.id, fillAmount )
                end
            end
        end
    end
end

event.register("cellChanged", addWaterToWorld)