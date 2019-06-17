
local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")
local common = require("mer.ashfall.common")
local logger = require("mer.ashfall.logger")
local standardSipSize = 35

local function onEquip(e)
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
        end

        thirstCommon.drinkAmount(thisSipSize)
    end
end
event.register("equip", onEquip, { filter = tes3.player } )

--[[
    If player is outside, with nothing above them, 
    look straight up and press activate to take a drink
]]--
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
        common.fadeTimeOut( 0.25, 2, 
            function()
                common.data.drinkingRain = false
                thirstCommon.drinkAmount(30)
            end
        )
    end
end
--event.register("keyDown", checkDrinkRain )


