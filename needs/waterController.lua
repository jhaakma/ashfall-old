
--[[
    When the player looks at a water source (fresh water, wells, etc), 
    a tooltip will display, and pressing the activate button will bring up
    a menu that allows the player to drink or fill up a container with water.
]]--
 

local thirstController = require("mer.ashfall.needs.thirstController")
local common = require("mer.ashfall.common.common")
local activatorConfig = common.staticConfigs.activatorConfig

local thirst = common.staticConfigs.conditionConfig.thirst

local buttons = {}
local bDrink = "Drink"
local bFillBottle = "Fill bottle"
local bNothing = "Nothing"

local function menuButtonPressed(e)
    local buttonIndex = e.button + 1
    --Drink
    if buttons[buttonIndex] == bDrink then
        if thirst:getValue() <= 0.1 then
            tes3.messageBox("You are fully hydrated.")
        else
            thirstController.callWaterMenuAction(function()
                thirstController.drinkAmount(100, common.data.drinkingDirtyWater)
            end)
        end
    --refill
    elseif buttons[buttonIndex] == bFillBottle then
        thirstController.fillContainer()
        return
    end
    common.data.drinkingRain = false
    common.data.drinkingDirtyWater = false
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
    function()
        common.log:debug("CLEAN water")
        common.data.drinkingDirtyWater = false
        callWatermenu()
    end,
    { filter = activatorConfig.types.waterSource } 
)

event.register(
    "Ashfall:ActivatorActivated", 
    function()
        common.log:debug("DIRTY water")
        common.data.drinkingDirtyWater = true
        callWatermenu()
    end, 
    { filter = activatorConfig.types.dirtyWaterSource } 
)


--Look straight up at the rain and activate to bring up water menu
local function checkDrinkRain()
    --thirst active
    local thirstActive = common.data and common.config.getConfig().enableThirst
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
        common.log:debug("common.data.drinkingRain = true")
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
        tes3ui.updateInventoryTiles()
    end
end


--Player activates a bottle with water in it
local function doDrinkWater(e)
    --Only drink as much in bottle
    local thisSipSize = math.min( 100, e.itemData.data.waterAmount )

    --Only drink as much as player needs
    local hydrationNeeded = thirst:getValue()
    thisSipSize = math.min( hydrationNeeded, thisSipSize)

    --Reduce liquid in bottle
    e.itemData.data.waterAmount = e.itemData.data.waterAmount - thisSipSize
    handleEmpties(e)
    local amountDrank = thirstController.drinkAmount(thisSipSize, e.itemData.data.waterDirty)
    if e.itemData.data.teaType and hydrationNeeded > 0.1 then
        event.trigger("Ashfall:DrinkTea", { teaType = e.itemData.data.teaType, amountDrank = amountDrank})
    end
end


local function drinkFromContainer(e)
    
    if common.getIsBlocked(e.item) then return end
    --First check potions, gives a little hydration
    if e.item.objectType == tes3.objectType.alchemy then
        local thisSipSize = common.staticConfigs.capacities.potion
        thisSipSize = math.min( thirst:getValue(), thisSipSize)
        thirstController.drinkAmount(thisSipSize)
    
    else

        local itemData = e.itemData and e.itemData.data
        local liquidLevel = (
            itemData and
            itemData.waterAmount
        )
        local doDrink = (
            common.config.getConfig().enableThirst and
            liquidLevel
        )
        if doDrink then
            if itemData.waterDirty then
                common.helper.messageBox{
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
end
event.register("equip", drinkFromContainer, { filter = tes3.player, priority = -100 } )


--First time entering a cell, add water to random bottles/containers
local chanceToFill = 0.2
local fillMin = 5
local function addWaterToWorld(e)
    local wateredCells = common.data.wateredCells
    if not wateredCells[string.lower(e.cell.id)] then
        wateredCells[string.lower(e.cell.id)] = true

        for ref in e.cell:iterateReferences(tes3.objectType.miscItem) do
            local bottleData = thirstController.getBottleData(ref.object.id)
            if bottleData and not ref.data.waterAmount then
                if math.random() < chanceToFill then
                    local fillAmount = math.random(fillMin, bottleData.capacity)
                    ref.data.waterAmount = fillAmount
                    ref.modified = true
                end
            end
        end
    end
end

event.register("cellChanged", addWaterToWorld)