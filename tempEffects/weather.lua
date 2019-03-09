--[[

This script gets region and weather info on cell change/weather change

]]--
local this = {}
local common = require("mer.ashfall.common")

--[[
    Weather
    Determines the min and max value of weatherTemp
]]--
local currentWeather

local weatherValues = { 
    [tes3.weather.blight]    = {    min    = -40    , max =  25  },
    [tes3.weather.ash]         = {    min    = -40    , max =  20 },
    [tes3.weather.clear]     = {    min    = -45    , max =  10     },
    [tes3.weather.cloudy]     = {    min    = -50    , max =  0     },
    [tes3.weather.overcast] = {    min    = -50    , max = -5     },
    [tes3.weather.foggy]     = {    min    = -50    , max = -10 },
    [tes3.weather.rain]     = {    min    = -55    , max = -30     },
    [tes3.weather.thunder]     = {    min    = -60    , max = -35     },
    [tes3.weather.snow]     = {    min    = -65    , max = -45     },
    [tes3.weather.blizzard] = {    min    = -70    , max = -50     }
}

--Alter min/max weather values 
local regionValues = {
    ["Moesring Mountains Region"]    = {    min    = -60 , max =  -20 },
    ["Felsaad Coast Region"]        = {    min    = -60 , max =  -20 },
    ["Isinfier Plains Region"]         = {    min    = -60 , max =  -20 },
    ["Brodir Grove Region"]             = {    min    = -55 , max =  -15 },
    ["Thirsk Region"]                = {    min    = -55 , max =  -10 },
    ["Hirstaang Forest Region"]        = {    min    = -50 , max =  -10 },
    --Vvardenfell
    --Cold
    ["Sheogorad"]                     = {    min    = -45 , max =  -10 },
    ["Azura's Coast Region"]        = {    min    = -30 , max =  10 },
    --Normal
    ["Ascadian Isles Region"]        = {    min    = -20 , max =  10 }, --Perfectly normal weather here
    ["Grazelands Region"]            = {    min    = -30 , max =  20 },-- gets cold at night, warm in day
    --Hot
    ["Bitter Coast Region"]            = {    min    = -20 , max =  10 }, 
    ["West Gash Region"]             = {    min    = -20 , max =  20 },
    ["Ashlands Region"]                = {    min    = 10 , max =  25 },
    ["Molag Mar Region"]            = {    min    = 20 , max =  30 },
    ["Red Mountain Region"]            = {    min    = 20 , max =  35 },
}

--Keyword search in interior names for cold caves etc
local defaultWeatherTemp = 0
local interiorValues = {
    [" Sewers"]     = -15,
    [" Eggmine"]     = -20,
    [" Egg Mine"]     = -20,
    [" Grotto"]     = -20,
    [" Dungeon"]    = -25,
    [" Tomb"]         = -25,
    [" Crypt"]         = -30,
    [" Catacomb"]     = -30,
    [" Cave"]         = -35,
    [" Barrow"]     = -45,

    ["Addamasartus"] = -35
}

local function updateWeather(weatherObj)
    if weatherObj then
        currentWeather = weatherObj.index
    end
end

local function immediateChange(e)
    updateWeather(e.to)
end

local function transitionEnd(e)
    updateWeather(e.to)
end

function this.calculateWeatherEffect()
    currentWeather = currentWeather or tes3.weather.clear
    local regionID = tes3.player.cell.region and tes3.player.cell.region.id or ""

    local gameHour = tes3.getGlobal("GameHour") or 0
    --This puts Midnight at 0, Midday at 12, in both directions
    local convertedTime = gameHour < 12 and gameHour or ( 12 - ( gameHour - 12) ) 
    --Clamp so temp stays the same for an hour at midday and midnight
    local weatherTemp = math.clamp(convertedTime, 0.5, 11.5)
    --remap to temperature based on weather ranges and region effects
    local min =  weatherValues[currentWeather].min + ( regionValues[regionID] and regionValues[regionID].min or 0 )
    local max = weatherValues[currentWeather].max +  ( regionValues[regionID] and regionValues[regionID].max or 0 )
    weatherTemp = math.remap( weatherTemp, 0.5, 11.5, min, max )
    
    common.data.weatherTemp = weatherTemp
end


local function cellChanged(e)
    updateWeather(tes3.getCurrentWeather())
    local intWeatherEffect = defaultWeatherTemp
    common.data.interiorType = "none"
    for key, val in pairs(interiorValues) do
        if string.find(tes3.player.cell.id, key) then
            common.data.interiorType = key
            intWeatherEffect = val
        end
    end
    common.data.intWeatherEffect = intWeatherEffect
end

local registerOnce
local function dataLoaded()
    updateWeather(tes3.getCurrentWeather())
    common.data.weatherTemp = defaultWeatherTemp
    if not registerOnce then
        registerOnce = true
        cellChanged()
        event.register("cellChanged", cellChanged)
        event.register("weatherChangedImmediate", immediateChange)
        event.register("weatherTransitionFinished", transitionEnd)
    end
end

event.register("Ashfall:dataLoaded", dataLoaded)

return this



