local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")
local logger = require("mer.ashfall.logger")
local skillModule = require("OtherSkills.skillModule")
local foodTypes = require("mer.ashfall.camping.foodTypes")
local defaultFoodValue = 5 


function this.isFood(foodObject)
    local config = mwse.loadConfig("ashfall/config")
    if not config then 
        logger.info("Error: no config found")
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
    local cooking = skillModule.getSkill("Ashfall:Cooking").value
    if not cooking then
        mwse.log("No cooking?")
        return 150
    end
    
    local burnLimit = math.remap(cooking, common.skillStartValue, 100, 120, 160)
    return burnLimit
end

function this.getFoodValue(object, itemData)

    if not foodTypes.nutrition[foodTypes.ingredTypes[object.id]] then
        mwse.log("No value found for %s", object.id)
    end

    local value = foodTypes.nutrition[foodTypes.ingredTypes[object.id]] or foodTypes.nutrition[foodTypes.TYPE.misc]

    local cookedAmount = itemData and itemData.data.cookedAmount
    if cookedAmount then
        local cooking = skillModule.getSkill("Ashfall:Cooking").value
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
    if not common.data.mcmSettings.enableHunger then
        return
    end

    local currentHunger = common.data.hunger or  0
    local amountAte = math.min(amount, currentHunger)
    common.data.hunger = currentHunger - amountAte
    conditionsCommon.updateCondition("hunger")
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