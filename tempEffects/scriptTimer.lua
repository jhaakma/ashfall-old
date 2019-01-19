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

local frostBreath = require("mer.ashfall.frostBreath")


--Survival stuff
local sleepController = require("mer.ashfall.sleepController")    
local tentController = require("mer.ashfall.tentController")

--Needs
local needsUI = require("mer.ashfall.needs.needsUI")
local needs = {
    thirst = require("mer.ashfall.needs.thirst.thirstCalculate"),
    hunger = require("mer.ashfall.needs.hunger.hungerCalculate"),
    sleep = require("mer.ashfall.needs.sleep.sleepCalculate")
}


--How often the script should run in gameTime
local scriptInterval = 0.0005

local function callUpdates()

    calcTemp.calculateTemp(scriptInterval)
    weather.calculateWeatherEffect()
    wetness.calcaulateWetTemp(scriptInterval)
    
    sleepController.checkSleeping()
    

    --Needs:
    for _, script in pairs(needs) do
        script.calculate(scriptInterval)
    end

    --For heavy scripts and those that don't need to be run while sleeping
    if tes3.menuMode() == false then
        tentController.checkTent()
        --temp effects
        raceEffects.calculateRaceEffects()
        torch.calculateTorchTemp()
        fireEffect.calculateFireEffect()
        magicEffects.calculateMagicEffects()
        hazardEffects.calculateHazards()

        --conditions
        --[[for _, script in pairs(conditions) do
            script.updateCondition()
        end]]--

        conditions.updateConditions()
        --visuals
        frostBreath.doFrostBreath()
        needsUI.updateNeedsUI()
    end
    
end

local function dataLoaded()
    callUpdates()
    timer.delayOneFrame(function()
        timer.start({duration = scriptInterval, callback = callUpdates, type = timer.game, iterations = -1})
    end)
end

--Register functions
event.register("Ashfall:dataLoaded", dataLoaded)
--event.register("loaded", dataLoaded)