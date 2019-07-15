

local this = {}
this.externalHeatSources = {}
this.internalHeatSources = {}
this.baseTempMultipliers = {} --flag: coldOnly and warmOnly
this.rateMultipliers = {} --flags: coolingOnly and warmingOnly

function this.registerExternalHeatSource(heatSource)
    if type(heatSource) == "string" then
        heatSource = { id = heatSource }
    end

    if type(heatSource) == "table" and heatSource.id then
        table.insert(this.externalHeatSources, heatSource)
    else
        mwse.log("ERROR: incorrect formatting of externalHeatSource")
    end
end

function this.registerInternalHeatSource(heatSource)
    if type(heatSource) == "string" then
        heatSource = { id = heatSource }
    end
    if type(heatSource) == "table" and heatSource.id then
        table.insert(this.internalHeatSources, { id = heatSource.id })
    else
        mwse.log("ERROR: incorrect formatting of internalHeatSource")
    end
end

function this.registerBaseTempMultiplier(multiplier)
    if type(multiplier) == "string" then
       multiplier = { id = multiplier }
    end
    if type(multiplier) == "table" and multiplier.id then
        table.insert(this.baseTempMultipliers, 
        {
            id = multiplier.id,
            coolingOnly = multiplier.coldOnly,
            warmingOnly = multiplier.warmOnly
        }
    )
    else
        mwse.log("ERROR: incorrect formatting of baseTempMultiplier")
    end
end




--move to common---------------------------------
--Also... refactor all temps to point to this----
local data = require("mer.ashfall.common").data
data.temp = data.temp or {
    ext = { base = 0, real = 0 },
    int = { base = 0, real = 0 },
}
-------------------------------------------------
--Move to Config file
local EXT_MULTI = 0.5
local INT_MULTI = 0.2
-----------------------------------------------

local temp = data.temp


local function isTempIncreasing()
    return temp.int.real < temp.ext.real
end

local function getWeather()
    --Move to weather controller, register as external heat source
    local weatherTemp = data.weatherTemp or 0
    local interiorWeatherMultiplier = 0.4
    local cell = tes3.getPlayerCell()
    local interiorTemp = data.intWeatherEffect or 0
    if cell.isInterior then
        return ( weatherTemp * interiorWeatherMultiplier) + interiorTemp
    else
        return weatherTemp
    end
end

local function getExternalHeat()
    local heat = 0
    for _, heatSource in ipairs(this.externalHeatSources) do
        heat = heat + data[heatSource.id]
    end
    return heat
    --[[
        data.fireTemp
        data.hazardTemp
        data.fireDamTemp
        data.frostDamTemp
    ]]
end

local function getInternalHeat()
    local result = 0
    for _, heatSource in ipairs(this.internalHeatSources) do
        result = result + data[heatSource.id]
    end
    return result
    --[[
        data.wetTemp
        data.warmthRating
        data.bedTemp
        data.tentTemp
        data.furTemp
    ]]
end

local function getBaseTempMultiplier()
    --[[
        both:
            data.alcoholEffect
            data.hungerEffect
            data.thirstEffect
        coldOnly:
            data.ResistFrostEffect
            data.vampireColdEffect
        warmOnly:
            data.resistFireEffect
            data.vampireWarmEffect
    ]]

    --multipliers that directly affect temperature
    local result = 1
    for _, multiplier in ipairs(this.baseTempMultipliers) do
        local addMultiplier = (
            ( temp.int.real < 0 and not multiplier.warmOnly ) or 
            ( temp.int.real > 0 and not multiplier.coldOnly )
        )
        if addMultiplier then
            result = result * data[multiplier.id]
        end
    end
end



local function getExternalChangeMultiplier(interval)
    return interval * EXT_MULTI
end


local function getInternalChangeMultiplier(interval)
    --wetness
    --coverage
    --Sleeping?
    local multipliers
    if isTempIncreasing() then
        --addWarmingMultipliers
    else
        --addCoolingMultipliers
    end

    return interval * multipliers * INT_MULTI
end

function this.calculate(interval)

    temp.ext.base = getWeather() + getExternalHeat()
    temp.ext.real = temp.ext.real + ( temp.ext.real - temp.ext.base ) * getExternalChangeMultiplier(interval)

    --subtract previous base temp before adding new base temp
    temp.int.real = temp.int.real - temp.int.base
    temp.int.base = getInternalHeat() * getBaseTempMultiplier()
    temp.int.real = temp.int.real + temp.int.base
    
    --Move towards external temp
    temp.int.real = temp.int.real + ( temp.int.real - temp.ext.real ) * getInternalChangeMultiplier(interval)

end

return this