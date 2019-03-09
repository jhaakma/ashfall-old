local common = require("mer.ashfall.common")
local this = {}

local coldMulti = 2.0
local hungerEffectMax = 1.5
local restMultiplier = 1.0
function this.calculate(scriptInterval)
    
    --Check Ashfall disabled
    local hungerEnabled = (
        common.data.mcmSettings.enableHunger
    )
    if not hungerEnabled then
        common.data.hunger = 0
        return
    end

    local hungerRate = common.data.mcmSettings.hungerRate / 10

    local hunger = common.data.hunger or 0
    local temp = common.data.temp or 0

    --Colder it gets, the faster you grow hungry
    local coldEffect = math.clamp(temp, -100, 0) 
    
    coldEffect = math.remap( coldEffect, -100, 0, coldMulti, 1.0)

    --calculate hunger
    local resting = (
        tes3.mobilePlayer.sleeping or
        tes3.menuMode()
    )
    if resting then
        hunger = hunger + ( scriptInterval * hungerRate * coldEffect * restMultiplier )
    else
        hunger = hunger + ( scriptInterval * hungerRate * coldEffect )
    end
    hunger = math.clamp( hunger, 0, 100 )
    common.data.hunger = hunger

    --The hungrier you are, the more extreme cold temps are
    local hungerEffect = math.remap( hunger, 0, 100, 1.0, hungerEffectMax)
    common.data.hungerEffect = hungerEffect
end
return this