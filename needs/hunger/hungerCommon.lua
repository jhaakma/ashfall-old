local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")

local defaultFoodValue = 5
 
function this.isFood(foodObject)
    local config = mwse.loadConfig("ashfall/config")
    if not config then 
        mwse.log("Error: no config found")
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

return this