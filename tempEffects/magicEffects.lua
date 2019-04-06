--[[
    Calculates temperature effects of magic resistances
    resist calculations called periodically by script timer
    fire/frost damage calculated on spellTicks
]]--

local this = {}
local common = require("mer.ashfall.common")
local logger = require("mer.ashfall.logger")

--multiplier at 100% resist
local maxEffect = 0.5


function this.calculateMagicEffects()


    --Frost Resist - Reduces cold temps
    
    local resistFrost = ( tes3.mobilePlayer.resistFrost or 0 )
    resistFrost = math.clamp(resistFrost, 0, 100)
    resistFrost = math.remap(resistFrost, 0, 100, maxEffect, 1)
    common.data.resistFrostEffect = resistFrost

    --Fire Resist - Reduces hot temps

    local resistFire = ( tes3.mobilePlayer.resistFire or 0 )
    resistFire = math.clamp(resistFire, 0, 100)
    resistFire = math.remap(resistFire, 100, 0, maxEffect, 1)
    common.data.resistFireEffect = resistFire

end


--TODO: Fire and Frost Damage
local function calculateDamageTemp(e)

    --if e.target ~= tes3.player then return end
    if e.effectId == tes3.effect.fireDamage then

    elseif e.effectId == tes3.effect.frostDamage then
        tes3.messageBox("Frost dam: %s", (e.effect.magnitude))
        --logger.info("Frost dam: %s", (e.effect.magnitude))
    end
end

--event.register("spellTick", calculateDamageTemp)

return this
