--[[ Timer function for weather updates]]--

local temperatureController = require("mer.ashfall.temperatureController")

local weather = require("mer.ashfall.tempEffects.weather")
local wetness = require("mer.ashfall.tempEffects.wetness")
local conditions = require("mer.ashfall.conditionController")
local torch = require("mer.ashfall.tempEffects.torch")
local raceEffects = require("mer.ashfall.tempEffects.raceEffects")
local fireEffect = require("mer.ashfall.tempEffects.fireEffect")
local magicEffects = require("mer.ashfall.tempEffects.magicEffects")
local hazardEffects = require("mer.ashfall.tempEffects.hazardEffects")
local survivalEffect = require("mer.ashfall.survival")
local sunEffect = require("mer.ashfall.tempEffects.sunEffect")
local frostBreath = require("mer.ashfall.effects.frostBreath")


--Survival stuff
local sleepController = require("mer.ashfall.sleepController")    
local tentController = require("mer.ashfall.tentController")
local activators = require("mer.ashfall.activators.activatorController")

--Needs
local needsUI = require("mer.ashfall.needs.needsUI")
local needs = {
    thirst = require("mer.ashfall.needs.thirst.thirstController"),
    hunger = require("mer.ashfall.needs.hunger.hungerController"),
    sleep = require("mer.ashfall.needs.sleep.sleepCalculate")
}
local hungerController = require("mer.ashfall.needs.hunger.hungerController")
--How often the script should run in gameTime

local lastTime
local function callUpdates()
    
    local hoursPassed = ( tes3.worldController.daysPassed.value * 24 ) + tes3.worldController.hour.value
    lastTime = lastTime or hoursPassed
    local interval = hoursPassed - lastTime
    lastTime = hoursPassed
   
    
    weather.calculateWeatherEffect(interval)
    sunEffect.calculate(interval)
    wetness.calculateWetTemp(interval)
    sleepController.checkSleeping()
    hungerController.processMealBuffs(interval)
   
    --Needs:
    for _, script in pairs(needs) do
        script.calculate(interval)
    end

    --Heavy scripts
    activators.callRayTest()
    tentController.checkTent()
    --temp effects
    raceEffects.calculateRaceEffects()
    torch.calculateTorchTemp()
    fireEffect.calculateFireEffect()
    magicEffects.calculateMagicEffects()
    hazardEffects.calculateHazards()
    survivalEffect.calculate()
    wetness.checkForShelter() 
    conditions.updateConditions()
    
    --visuals
    frostBreath.doFrostBreath()

    temperatureController.calculate(interval)
    needsUI.updateNeedsUI()
end

event.register("simulate", callUpdates)



local function dataLoaded()
    
    timer.delayOneFrame(
        function()
            --Use game timer when sleeping
            timer.start({
                duration =  1, 
                callback = function()
                    if tes3.player and tes3.menuMode() then
                        callUpdates()
                    end 
                end, 
                type = timer.game, 
                iterations = -1
            })

            timer.start({
                callback = conditions.checkExtremeConditions,
                type = timer.real,
                iterations = -1,
                duration = 2
            })
        end
        
    )
end


--Register functions
event.register("Ashfall:dataLoaded", dataLoaded)

local function resetTime()
    lastTime = nil
end
event.register("loaded", resetTime)