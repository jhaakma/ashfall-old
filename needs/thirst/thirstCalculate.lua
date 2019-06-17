--[[
    Thirst mechanics
]]--

local common = require("mer.ashfall.common")
local this = {}
 
local heatMulti = 2.0
local thirstEffectMax = 1.5
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
    local thirstEffect = math.remap(thirst, 0, 100, 1.0, thirstEffectMax)
    common.data.thirstEffect = thirstEffect
end



return this