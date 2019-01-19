local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")

local defaultFoodValue = 5

function this.getFoodValue(thisFoodId)
    local foodValues = mwse.loadConfig("ashfall/foodValues")
    if foodValues then 
        for foodId, value in pairs( foodValues ) do
            if thisFoodId == foodId then
                return value
            end
        end
    else
        mwse.log("[Ashfall ERROR] hungerCommon.lua: Food values table missing!")
    end
    return defaultFoodValue
end

function this.eatAmount( amount ) 
    if not common.data.mcmOptions.enableHunger then
        return
    end

    local currentHunger = common.data.hunger or  0
    common.data.hunger = math.max( (currentHunger - amount), 0 )
    conditionsCommon.updateCondition("hunger")
    needsUI.updateNeedsUI()
end

return this