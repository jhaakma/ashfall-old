--[[
    Wetness mechanics
]]--
local this = {}
local common = require("mer.ashfall.common")


--How much rain and thunder increase wetness per game hour (without armor
local rainEffect = 150
local thunderEffect = 300
local dryingMultiplier = 75 --dry per hour at max heat

--Boundaries for wetEffects
this.dampLevel = common.conditions.wetness.states.damp.min
this.wetLevel = common.conditions.wetness.states.wet.min
this.soakedLevel = common.conditions.wetness.states.soaked.min

--Height at which Player gets wetEfects
local dampHeight = 50
local wetHeight = 80
local soakedHeight = 110

--How Cold 100% wetness is
local wetTempMax = -25

function this.checkForShelter()
    local sheltered = common.checkRefSheltered()
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
        return
    end

    local currentWetness = common.data and common.data.wetness or 0

    
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
    if not weather then return end
    local playerTemp = common.data.temp or 0
    local tempMultiplier = 0.5 + ( ( playerTemp + 100 ) / 400 ) --between 0.5 and 1.0
    local coverage = math.remap( common.data.coverageRating, 0, 1,  0, 0.85 )    

    if weather.rainActive and not cell.isInterior then
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
        local dryCoverageEffect = 1 - ( coverage / 2 )
        local dryChange = ( tempMultiplier * timeSinceLastRan * dryingMultiplier * dryCoverageEffect )
        currentWetness = currentWetness - dryChange
    end
    --assert min/max values
    currentWetness = currentWetness < 0 and 0 or currentWetness
    currentWetness = currentWetness > 100 and 100 or currentWetness
    
    --Update wetness and wetTemp on player data
    common.data.wetness = currentWetness
    common.data.wetTemp = (currentWetness / 100) * wetTempMax

end

return this


