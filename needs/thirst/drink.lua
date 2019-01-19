
local thirstCommon = require("mer.ashfall.needs.thirst.thirstCommon")
local common = require("mer.ashfall.common")

local function onEquip(e)
    local doDrink = (
        common.data.mcmOptions.enableThirst and
        e.item.objectType == tes3.objectType.alchemy
    )
    if doDrink then
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
