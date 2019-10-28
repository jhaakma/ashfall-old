
local this = {}
local common = require("mer.ashfall.common.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")

local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerBaseTempMultiplier({ id = "thirstEffect", warmOnly = true })

local heatMulti = 2.0
local THIRST_EFFECT_LOW = 1.3
local THIRST_EFFECT_HIGH = 1.0
local restMultiplier = 1.0
function this.calculate(scriptInterval)
    local thirstRate = common.data.mcmSettings.thirstRate / 10
    local thirstActive = (
        common.data and
        common.data.mcmSettings.enableThirst
    )
    if not thirstActive then
        common.data.thirst = 0
        return
    end
    if common.data.drinkingRain then
        return
    end

    local thirst = common.data.thirst or 0
    local temp = common.data.temp or 0

    --Hotter it gets the faster you become thirsty
    local heatEffect = math.clamp(temp, 0, 100 )
    heatEffect = math.remap(heatEffect, 0, 100, 1.0, heatMulti)

    --Calculate thirst
    local resting = (
        tes3.mobilePlayer.sleeping or
        tes3.menuMode()
    )
    if resting then
        thirst = thirst + ( scriptInterval * thirstRate * heatEffect * restMultiplier )
    else
        thirst = thirst + ( scriptInterval * thirstRate * heatEffect )
    end
    thirst = math.clamp(thirst, 0, 100) 

    common.data.thirst = thirst

    --The thirstier you are, the more extreme heat temps are
    local thirstEffect = math.remap(thirst, 0, 100, THIRST_EFFECT_HIGH, THIRST_EFFECT_LOW)
    common.data.thirstEffect = thirstEffect
end



function this.getBottleData(id)
    return common.config.bottleList[string.lower(id)]
end



function this.drinkAmount( amount, drinkingDirtyWater )
    if not common.config.conditions.thirst:isActive() then return end
    local currentThirst = common.data.thirst or 0
    
    if currentThirst <= 0.1 then
        tes3.messageBox("You are fully hydrated.")
        return 0
    end
    local amountDrank = math.min( currentThirst, amount )
    common.data.thirst = common.data.thirst - amountDrank
    conditionsCommon.updateCondition("thirst")
    this.calculate(0)
    temperatureController.update("drinkAmount")
    needsUI.updateNeedsUI()
    hud.updateHUD()

    tes3.playSound({reference = tes3.player, sound = "Drink"})

    if drinkingDirtyWater == true then
        common.helper.tryContractDisease("ashfall_d_dysentry")
    end
    return amountDrank
end



function this.callWaterMenuAction(callback)
    if common.data.drinkingRain then
        common.data.drinkingRain = false
        common.helper.fadeTimeOut( 0.25, 2, callback )
    else
        callback()
    end
    common.data.drinkingDirtyWater = nil
end

--Fill a bottle to max water capacity
function this.fillContainer(source, returnFunction)
    timer.delayOneFrame(function()
        tes3ui.showInventorySelectMenu{
            title = "Select Water Container",
            noResultsText = "You have no containers to fill.",
            filter = function(e)
                local bottleData = this.getBottleData(e.item.id)
                if bottleData then
                    local capacity = bottleData.capacity
                    local currentAmount = e.itemData and e.itemData.data.waterAmount or 0
                    return currentAmount < capacity
                else
                    return false
                end
            end,
            callback = function(e)

                if not e.item then 
                    return
                end
                this.callWaterMenuAction(function()
                    --initialise itemData
                    local itemData = e.itemData
                    if not itemData then
                        itemData = tes3.addItemData{ 
                            to = tes3.player, 
                            item = e.item,
                            updateGUI = true
                        }
                    end

                    --dirty container if drinking from raw water
                    if common.data.drinkingDirtyWater then
                        itemData.data.waterDirty = true
                        common.data.drinkingDirtyWater = nil
                    end
                    local fillAmount
                    local bottleData = this.getBottleData(e.item.id)

                    itemData.data.waterAmount = itemData.data.waterAmount or 0
                    if source then

                        fillAmount = math.min(
                            bottleData.capacity - itemData.data.waterAmount,
                            source.waterAmount
                        )
                        common.helper.transferQuantity(source, itemData.data, "waterAmount", "waterAmount", fillAmount)
                        --clean source if empty
                        if source.waterDirty then
                            itemData.data.waterDirty = true
                        end
                        if source.waterAmount == 0 then
                            source.waterDirty = nil
                        end
                    else
                        itemData.data.waterAmount = bottleData.capacity
                    end

                    tes3ui.updateInventoryTiles()
                    tes3.playSound({reference = tes3.player, sound = "Swim Left"})
                    tes3.messageBox(
                        "%s filled with %swater.",
                        e.item.name,
                        (itemData.data.waterDirty and "dirty " or "")
                    )

                    if returnFunction then returnFunction() end
                end)
            end
        }
    end
    )
end

return this
