local common = require("mer.ashfall.common")
local this = {}
local hungerRate = 3.0
local coldMulti = 2.0
local hungerEffectMax = 1.5

function this.calculate(scriptInterval)
    --Check Ashfall disabled
    local hungerEnabled = (
        common.data.mcmOptions.enableHunger
    )
    if not hungerEnabled then
        common.data.hunger = 0
        return
    end

    local hunger = common.data.hunger or 0
    local temp = common.data.temp or 0

    --Colder it gets, the faster you grow hungry
    local coldEffect = math.clamp(temp, -100, 0)
    coldEffect = math.remap( coldEffect, -100, 0, coldMulti, 1.0)

    --calculate hunger
    hunger = hunger + ( scriptInterval * hungerRate * coldEffect )
    hunger = math.clamp( hunger, 0, 100 )
    common.data.hunger = hunger

    --The hungrier you are, the more extreme cold temps are
    local hungerEffect = math.remap( hunger, 0, 100, 1.0, hungerEffectMax)
    common.data.hungerEffect = hungerEffect
end
return this