
local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")
local common = require("mer.ashfall.common")

local function onEquip(e)
    if common.data.mcmSettings.enableThirst and thirstCommon.isDrink(e.item) then
        local newContainerId 
        --bottles
        local bottles = thirstCommon.containerList.filledBottles
        local flasks = thirstCommon.containerList.filledFlasks
        if e.item.id == bottles.bottleFull then
            newContainerId = bottles.bottleHalf
        elseif e.item.id == bottles.bottleHalf then
            newContainerId = bottles.bottleLow
        elseif e.item.id == bottles.bottleLow then
            newContainerId = thirstCommon.containerList.bottles[ math.random( #thirstCommon.containerList.bottles) ]

        --flasks
        elseif e.item.id == flasks.flaskFull then
            newContainerId = flasks.flaskHalf
        elseif e.item.id == flasks.flaskHalf then
            newContainerId = flasks.flaskLow
        elseif e.item.id == flasks.flaskLow then
            newContainerId = thirstCommon.containerList.flasks[ math.random( #thirstCommon.containerList.flasks) ]
        end
        --water
        if newContainerId then
            thirstCommon.drinkAmount(35)
            timer.frame.delayOneFrame(
                function ()
                    mwscript.addItem({reference = tes3.player, item = newContainerId})
                    --tes3.messageBox("%s has been added to your inventory", tes3.getObject(newContainerId).name)
                end
            )
        --not water but still a drink
        else   
            thirstCommon.drinkAmount(10)
        end
    end
end
event.register("equip", onEquip, {filter = tes3.player } )


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
                tes3.playSound({ reference=tes3.player, sound="Swallow" })
                common.data.drinkingRain = false
                thirstCommon.drinkAmount(10)
            end
        )
    end
end
event.register("keyDown", checkDrinkRain )