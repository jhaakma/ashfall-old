local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")
local logger = require("mer.ashfall.logger")

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

function this.getFoodValue(thisFoodId)
    local foodValues = mwse.loadConfig("ashfall/foodValues")
    return foodValues[thisFoodId] or defaultFoodValue
end

function this.eatAmount( amount ) 
    if not common.data.mcmSettings.enableHunger then
        return
    end

    local currentHunger = common.data.hunger or  0
    common.data.hunger = math.max( (currentHunger - amount), 0 )
    conditionsCommon.updateCondition("hunger")
    needsUI.updateNeedsUI()
    hud.updateHUD()
end

function this.processMealBuffs(scriptInterval)
    --decrement buff time
    if common.data.mealTime and common.data.mealTime > 0 then
        common.data.mealTime = math.max(common.data.mealTime - scriptInterval, 0)

    --Time's up, remove buff
    elseif common.data.mealBuff then
        logger.info("Removing meal buff")
        mwscript.removeSpell({ reference = tes3.player, spell = common.data.mealBuff })
        common.data.mealBuff = nil
    end
end

return this