local this = {}
local common = require("mer.ashfall.common.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")
local foodTypes = require("mer.ashfall.camping.foodTypes")
local temperatureController = require("mer.ashfall.temperatureController")

function this.isFood(foodObject)
    local config = mwse.loadConfig("ashfall")
    if not config then 
        common.log.info("Error: no config found")
    end
    local mod = foodObject.sourceMod and foodObject.sourceMod:lower()
    return (
        foodObject.objectType == tes3.objectType.ingredient and
        not config.blocked[foodObject.id] and
        not config.blocked[mod]
    )
end

function this.getBurnLimit()
    --TODO: Use cooking skill to determine
    local cooking = common.skills.cooking.value
    if not cooking then
        common.log.error("No cooking skill found")
        return 150
    end
    
    local burnLimit = math.remap(cooking, common.skillStartValue, 100, 120, 160)
    return burnLimit
end

function this.getFoodValue(object, itemData)

    if not foodTypes.nutrition[foodTypes.ingredTypes[object.id]] then
        common.log.error("No value found for %s", object.id)
    end

    local value = foodTypes.nutrition[foodTypes.ingredTypes[object.id]] or foodTypes.nutrition[foodTypes.TYPE.misc]

    local cookedAmount = itemData and itemData.data.cookedAmount
    if cookedAmount then
        local cooking = common.skills.cooking.value
        local cookingEffect = math.remap(
            cooking,
            common.skillStartValue, 100, 
            foodTypes.cookedMultiMin, foodTypes.cookedMultiMax
        )

        local min = value
        local max = math.ceil(value * cookingEffect)

        if cookedAmount < this.getBurnLimit() then
            --value based on how cooked it is
            cookedAmount = math.min(cookedAmount, 100)
            value = math.remap(cookedAmount, 0, 100, min, max)
        else
            --half value when burned
            value = ( ( max - min ) / 2 ) + min
        end
    end

    return value
end


function this.eatAmount( amount ) 
    local hunger = common.conditions.hunger
    if not hunger:isActive() then
        return
    end
    local currentHunger = hunger:getValue()
    local amountAte = math.min(amount, currentHunger)
    hunger:setValue(currentHunger - amountAte)
    conditionsCommon.updateCondition("hunger")
    temperatureController.update("eatAmount")
    needsUI.updateNeedsUI()
    hud.updateHUD()
    return amountAte
end



function this.processMealBuffs(scriptInterval)
    --decrement buff time
    if common.data.mealTime and common.data.mealTime > 0 then
        common.data.mealTime = math.max(common.data.mealTime - scriptInterval, 0)

    --Time's up, remove buff
    elseif common.data.mealBuff then
        mwscript.removeSpell({ reference = tes3.player, spell = common.data.mealBuff })
        common.data.mealBuff = nil
    end
end

return this