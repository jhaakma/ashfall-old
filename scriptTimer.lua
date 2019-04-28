local common = require("mer.ashfall.common")
local logger = require("mer.ashfall.logger")
--[[ Timer function for weather updates]]--

local calcTemp = require("mer.ashfall.tempEffects.calcTemp")

local weather = require("mer.ashfall.tempEffects.weather")
local wetness = require("mer.ashfall.tempEffects.wetness")
--[[local conditions = {
    tempCondition = require("mer.ashfall.conditions.tempCondition"),
    wetCondition = require("mer.ashfall.conditions.wetCondition"),
    thirstCondition = require("mer.ashfall.conditions.thirstCondition"),
    hungerConditiion = require("mer.ashfall.conditions.hungerCondition"),
    sleepCondition = require("mer.ashfall.conditions.sleepCondition")
}]]--
local conditions = require("mer.ashfall.conditionController")
local torch = require("mer.ashfall.tempEffects.torch")
local raceEffects = require("mer.ashfall.tempEffects.raceEffects")
local fireEffect = require("mer.ashfall.tempEffects.fireEffect")
local magicEffects = require("mer.ashfall.tempEffects.magicEffects")
local hazardEffects = require("mer.ashfall.tempEffects.hazardEffects")

local frostBreath = require("mer.ashfall.effects.frostBreath")


--Survival stuff
local sleepController = require("mer.ashfall.sleepController")    
local tentController = require("mer.ashfall.tentController")
local activators = require("mer.ashfall.activators.activatorController")

--Needs
local needsUI = require("mer.ashfall.needs.needsUI")
local needs = {
    thirst = require("mer.ashfall.needs.thirst.thirstCalculate"),
    hunger = require("mer.ashfall.needs.hunger.hungerCalculate"),
    sleep = require("mer.ashfall.needs.sleep.sleepCalculate")
}
local hungerCommon = require("mer.ashfall.needs.hunger.hungerCommon")
local config = mwse.loadConfig("Ashfall/config")
--How often the script should run in gameTime

local heavyScriptInterval = 0.2 --seconds
local scriptInterval = 0.0005
local function callUpdates()
    
    calcTemp.calculateTemp(scriptInterval)
    weather.calculateWeatherEffect()
    wetness.calcaulateWetTemp(scriptInterval)
    sleepController.checkSleeping()
    hungerCommon.processMealBuffs(scriptInterval)
    --Needs:
    for _, script in pairs(needs) do
        script.calculate(scriptInterval)
    end
end

local function callHeavyUpdates()
    
    --For heavy scripts and those that aren't dependent on time keeping
    if tes3.menuMode() == false then
        activators.callRayTest()
        tentController.checkTent()
        --temp effects
        raceEffects.calculateRaceEffects()
        torch.calculateTorchTemp()
        fireEffect.calculateFireEffect()
        magicEffects.calculateMagicEffects()
        hazardEffects.calculateHazards()


        conditions.updateConditions()
        
        --visuals
        frostBreath.doFrostBreath()
        needsUI.updateNeedsUI()
    end
end

local function dataLoaded()
    callUpdates()
    timer.delayOneFrame(
        function()
            timer.start({
                duration =  scriptInterval, 
                callback = callUpdates, 
                type = timer.game, 
                iterations = -1})
            timer.start({ 
                duration = heavyScriptInterval,
                callback = callHeavyUpdates, 
                type = timer.real,
                iterations = -1
            })

        end
    )
end

--Register functions
event.register("Ashfall:dataLoaded", dataLoaded)
--event.register("loaded", dataLoaded)