--[[
    Wetness mechanics
]]--
local this = {}
local common = require("mer.ashfall.common.common")
local wetness = common.staticConfigs.conditionConfig.wetness

--register temp effects
local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerExternalHeatSource("wetTemp")
temperatureController.registerRateMultiplier{ id = "wetCoolingRate", coolingOnly = true }
temperatureController.registerRateMultiplier{ id = "wetWarmingRate", warmingOnly = true }



--How much rain and thunder increase wetness per game hour (without armor
local rainEffect = 150
local thunderEffect = 300
local DRYING_MULTI = 125 --dry per hour at max heat

--Boundaries for wetEffects
this.dampLevel = common.staticConfigs.conditionConfig.wetness.states.damp.min
this.wetLevel = common.staticConfigs.conditionConfig.wetness.states.wet.min
this.soakedLevel = common.staticConfigs.conditionConfig.wetness.states.soaked.min

--Height at which Player gets wetEfects
local dampHeight = 50
local wetHeight = 80
local soakedHeight = 110

--How Cold 100% wetness is
local wetTempMax = -25

function this.checkForShelter()
    local sheltered = common.helper.checkRefSheltered()
    if sheltered ~= nil then
        common.data.isSheltered = sheltered  
    end
end



--[[ 
    Called by tempTimer
]]--
function this.calculateWetTemp(timeSinceLastRan)
    if not common.data then return end

    --Check if Ashfall is disabled
    if not common.data.mcmSettings.enableTemperatureEffects then
        common.data.wetness = 0
        common.data.wetTemp = 0
        common.data.wetCoolingRate = 1
        common.data.wetWarmingRate = 1
        return
    end
    local currentWetness = wetness:getValue()

    --Check if player is submerged 
    -- does not care about coverage
    local cell = tes3.getPlayerCell()
    if cell.hasWater then
        local waterLevel = cell.waterLevel or 0
        local playerHeight = tes3.getPlayerRef().position.z
        --soaked
        if waterLevel > ( playerHeight + soakedHeight ) then
            currentWetness = 100
    
        --wet
        elseif waterLevel > ( playerHeight + wetHeight ) then
            if currentWetness < ( this.wetLevel + 10 ) then 
                currentWetness = ( this.wetLevel + 10 )
            end
            
        --damp:
        elseif waterLevel > ( playerHeight + dampHeight ) then
            if currentWetness < ( this.dampLevel + 10 ) then 
                currentWetness = ( this.dampLevel + 10 )
            end
        end
    end
    
    --increase wetness if it's raining, otherwise reduce wetness over time
    -- wetness decreased by coverage
    local weather = tes3.getCurrentWeather()
    local playerTemp = common.data.temp or 0
    
    local coverage = math.remap( common.data.coverageRating, 0, 1,  0, 0.85 )    

    if weather and weather.rainActive and not cell.isInterior then
        --Raining
        if weather.index == tes3.weather.rain and common.data.isSheltered == false then
            currentWetness = currentWetness + rainEffect * timeSinceLastRan * ( 1.0 - coverage )
    
        --Thunder
        elseif weather.index == tes3.weather.thunder and common.data.isSheltered == false then
            currentWetness = currentWetness + thunderEffect * timeSinceLastRan * ( 1.0 - coverage )
        end
    else
        common.data.isSheltered = true
    end
    --Drying off (indoors or clear weather)
    if common.data.isSheltered then
        local dryCoverageEffect = math.remap(common.data.coverageRating, 0, 1.0, 1.0, 0.5)
        local tempMultiplier = math.remap(math.max(playerTemp, 0), 0, 100, 1.0, 3.0)
        local dryChange = ( tempMultiplier * timeSinceLastRan * dryCoverageEffect * DRYING_MULTI )
        currentWetness = currentWetness - dryChange
    end
    --assert min/max values
    currentWetness = currentWetness < 0 and 0 or currentWetness
    currentWetness = currentWetness > 100 and 100 or currentWetness
    
    --Update wetness and wetTemp on player data
    common.data.wetness = currentWetness
    common.data.wetTemp = (currentWetness / 100) * wetTempMax

    common.data.wetCoolingRate = math.remap( currentWetness, 0, 100, 1.0, 2 )
    common.data.wetWarmingRate = math.remap( currentWetness, 0, 100, 1.0, 0.5 )
end



return this


