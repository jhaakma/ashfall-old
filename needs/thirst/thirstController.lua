
local this = {}
local common = require("mer.ashfall.common.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")
local statsEffect = require("mer.ashfall.needs.statsEffect")
local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerBaseTempMultiplier({ id = "thirstEffect", warmOnly = true })

local heatMulti = 5.0
local THIRST_EFFECT_LOW = 1.3
local THIRST_EFFECT_HIGH = 1.0
local restMultiplier = 1.0

local conditionConfig = common.staticConfigs.conditionConfig
local thirst = conditionConfig.thirst

function this.calculate(scriptInterval, forceUpdate)
    if not forceUpdate and scriptInterval == 0 then return end

    local thirstRate = common.data.mcmSettings.thirstRate / 10

    if not thirst:isActive() then
        thirst:setValue(0)
        return
    end
    if common.data.drinkingRain then
        return
    end
    if common.data.blockNeeds == true then
        return
    end

    local currentThirst = thirst:getValue()
    local temp = conditionConfig.temp

    --Hotter it gets the faster you become thirsty
    local heatEffect = math.clamp(temp:getValue(), temp.states.warm.min, temp.states.scorching.max )
    heatEffect = math.remap(heatEffect, temp.states.warm.min, temp.states.scorching.max, 1.0, heatMulti)
    
    --Calculate thirst
    local resting = (
        tes3.mobilePlayer.sleeping or
        tes3.menuMode()
    )
    if resting then
        currentThirst = currentThirst + ( scriptInterval * thirstRate * heatEffect * restMultiplier )
    else
        currentThirst = currentThirst + ( scriptInterval * thirstRate * heatEffect )
    end
    currentThirst = math.clamp(currentThirst, 0, 100) 

    thirst:setValue(currentThirst)

    --The thirstier you are, the more extreme heat temps are
    local thirstEffect = math.remap(currentThirst, 0, 100, THIRST_EFFECT_HIGH, THIRST_EFFECT_LOW)
    common.data.thirstEffect = thirstEffect
end

function this.update()
    this.calculate(0, true)
end


function this.getBottleData(id)
    return common.staticConfigs.bottleList[string.lower(id)]
end


function this.drinkAmount( amount, drinkingDirtyWater )
    if not conditionConfig.thirst:isActive() then return end
    local currentThirst = thirst:getValue()
    
    if currentThirst <= 0.1 then
        tes3.messageBox("You are fully hydrated.")
        return 0
    end
    local amountDrank = math.min( currentThirst, amount )

    local before = statsEffect.getMaxStat("magicka")
    thirst:setValue(currentThirst - amountDrank)
    local after = statsEffect.getMaxStat("magicka")

    --local magickaIncrease = tes3.mobilePlayer.magicka.base * ( amountDrank / 100 )
    local magickaIncrease = after - before
    tes3.modStatistic{
        reference = tes3.mobilePlayer,
        current = magickaIncrease,
        name = "magicka",
        limit = true
    }
    conditionsCommon.updateCondition("thirst")
    this.update()
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
    common.log.debug("if common.data.drinkingRain then")
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
                if e.item then 
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
                        if common.data.drinkingDirtyWater == true then
                            common.log.debug("Fill water DIRTY")
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
            end
        }
        timer.delayOneFrame(function()
            common.log.debug("common.data.drinkingRain = false fill")
            common.data.drinkingRain = false
            common.data.drinkingDirtyWater = false
        end)
    end)
end

return this
