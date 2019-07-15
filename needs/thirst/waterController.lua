
--[[
    When the player looks at a water source (fresh water, wells, etc), 
    a tooltip will display, and pressing the activate button will bring up
    a menu that allows the player to drink or fill up a container with water.
]]--
 

local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")
local common = require("mer.ashfall.common")
local Activator = require("mer.ashfall.objects.Activator")



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
        thirstCommon.callWaterMenuAction(function()
            thirstCommon.drinkAmount(100, common.data.drinkingDirtyWater)

        end)

    --refill
    elseif buttons[buttonIndex] == bFillBottle then
        thirstCommon.fillContainer()
    else
        common.data.drinkingRain = false
        common.data.drinkingDirtyWater = false
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


--Register events
event.register(
    "Ashfall:ActivatorActivated", 
    callWatermenu, 
    { filter = Activator.types.waterSource } 
)

event.register(
    "Ashfall:ActivatorActivated", 
    function()
        common.data.drinkingDirtyWater = true
        callWatermenu()
    end, 
    { filter = Activator.types.dirtyWaterSource } 
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


local function handleEmpties(e)
    if e.itemData.data.waterAmount <= 0 then
        e.itemData.data.waterDirty = nil
        e.itemData.data.waterAmount = nil
        --restack
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
end


--Player activates a bottle with water in it
local function doDrinkWater(e)

    local thisSipSize = 100

    --Only drink as much in bottle
    thisSipSize = math.min( thisSipSize, e.itemData.data.waterAmount )

    --Only drink as much as player needs
    local hydrationNeeded = common.data.thirst
    thisSipSize = math.min( hydrationNeeded, thisSipSize)

    --Reduce liquid in bottle
    e.itemData.data.waterAmount = e.itemData.data.waterAmount - thisSipSize
    handleEmpties(e)
    thirstCommon.drinkAmount(thisSipSize, e.itemData.data.waterDirty)
end

local function drinkFromContainer(e)
    local potionSipSize = 15
    
    --First check potions, gives a little hydration
    if e.item.objectType == tes3.objectType.alchemy then
        local thisSipSize = potionSipSize
        thisSipSize = math.min( common.data.thirst, thisSipSize)
        thirstCommon.drinkAmount(thisSipSize)
    end


    
    local itemData = e.itemData and e.itemData.data
    local liquidLevel = (
        itemData and
        itemData.waterAmount
    )
    local doDrink = (
        common.data.mcmSettings.enableThirst and
        liquidLevel
    )
    if doDrink then
        if itemData.waterDirty then
            common.messageBox{
                message = "This water is dirty.",
                buttons = {
                    { 
                        text = "Drink Dirty Water", 
                        callback = function() doDrinkWater(e) end 
                    },
                    { 
                        text = "Empty Container", 
                        callback = function()
                            e.itemData.data.waterAmount = 0
                            handleEmpties(e)
                            tes3.playSound({reference = tes3.player, sound = "Swim Left"})
                        end
                    },
                    { text = tes3.findGMST(tes3.gmst.sCancel).value }
                }
            }
        else
            doDrinkWater(e)
        end

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
            if bottleData and not ref.data.waterAmount then
                if math.random() < chanceToFill then
                    local fillAmount = math.random(fillMin, bottleData.capacity)
                    ref.data.waterAmount = fillAmount
                    ref.modified = true
                    --mwse.log("Filled %s will %d water", ref.object.id, fillAmount )
                end
            end
        end
    end
end

event.register("cellChanged", addWaterToWorld)