-- local common = require("mer.ashfall.common.common")
-- local this = {}

-- local coldMulti = 2.0
-- local hungerEffectMax = 0.5
-- local restMultiplier = 1.0

-- local temperatureController = require("mer.ashfall.temperatureController")
-- temperatureController.registerBaseTempMultiplier({ id = "hungerEffect", coldOnly = true })
-- function this.calculate(scriptInterval)
    
--     --Check Ashfall disabled
--     local hungerEnabled = (
--         common.data.mcmSettings.enableHunger
--     )
--     if not hungerEnabled then
--         common.data.hunger = 0
--         return
--     end

--     local hungerRate = common.data.mcmSettings.hungerRate / 10

--     local hunger = common.data.hunger or 0
--     local temp = common.data.temp or 0

--     --Colder it gets, the faster you grow hungry
--     local coldEffect = math.clamp(temp, -100, 0) 
    
--     coldEffect = math.remap( coldEffect, -100, 0, coldMulti, 1.0)

--     --calculate hunger
--     local resting = (
--         tes3.mobilePlayer.sleeping or
--         tes3.menuMode()
--     )
--     if resting then
--         hunger = hunger + ( scriptInterval * hungerRate * coldEffect * restMultiplier )
--     else
--         hunger = hunger + ( scriptInterval * hungerRate * coldEffect )
--     end
--     hunger = math.clamp( hunger, 0, 100 )
--     common.data.hunger = hunger

--     --The hungrier you are, the more extreme cold temps are
--     local hungerEffect = math.remap( hunger, 100, 0, hungerEffectMax, 1.0)
--     common.log.debug("Hunger effect: %s", hungerEffect)
--     common.data.hungerEffect = hungerEffect
-- end


-- return this