local this = {}
local common = require("mer.ashfall.common.common")



local function getMaxHealth()
    local minHeath = common.data and common.data.mcmSettings.needsCanKill and 0 or 1
    local multiplier = common.conditions.hunger:getStatMultiplier()
    return math.max( minHeath, math.floor(tes3.mobilePlayer.health.base * multiplier ) )
end
local function getMaxMagicka()
    local minMagicka = 0
    local multiplier = common.conditions.thirst:getStatMultiplier()
    return math.max(minMagicka, math.floor(tes3.mobilePlayer.magicka.base * multiplier) )
end
local function getMaxFatigue()
    local minFatigue = 0
    local multiplier = common.conditions.tiredness:getStatMultiplier()
    return math.max(minFatigue, math.floor(tes3.mobilePlayer.fatigue.base * multiplier ) )
end


local baseHealthCache

local function calcHealth()
    --Health, including rest until healed bullshit
    if baseHealthCache then
        tes3.setStatistic({
            reference = tes3.mobilePlayer,
            base = baseHealthCache,
            name = "health"
        })
        baseHealthCache = nil
    else
        if not tes3.menuMode() then
            local max =  getMaxHealth()
            if tes3.mobilePlayer.health.current > max then
                tes3.setStatistic({
                    reference = tes3.mobilePlayer,
                    current = max,
                    name = "health"
                })
            end
        end
    end
end

local function calcMagicka()
    local max = getMaxMagicka()
    if tes3.mobilePlayer.magicka.current > max then
        tes3.setStatistic({
            reference = tes3.mobilePlayer,
            current = max,
            name = "magicka"
        })
    end
end

local function calcFatigue()
    local max = getMaxFatigue() 
    if tes3.mobilePlayer.fatigue.current > max then
        tes3.setStatistic({
            reference = tes3.mobilePlayer,
            current = max,
            name = "fatigue"
        })
    end 
end

local doBlockNeeds
local function unblockNeeds()
    common.log.debug("unblocking")
    doBlockNeeds = false
    common.data.blockNeeds = false
end

local function checkInJail()
    if not doBlockNeeds then
        if tes3.mobilePlayer.inJail then
            common.log.debug("In Jail")
            doBlockNeeds = true
        end
        if doBlockNeeds == true then
            common.data.blockNeeds = true
            timer.start{
                type = timer.real,
                duration = 2,
                callback = unblockNeeds
            }
        end
    end
end


function this.calculate()
    calcHealth()
    calcMagicka()
    calcFatigue()
    checkInJail()
end

local function checkTravel()
    if not doBlockNeeds  then
        doBlockNeeds = true
        common.log.debug("Travelling")
        common.data.blockNeeds = true
        timer.start{
            type = timer.real,
            duration = 2,
            callback = unblockNeeds
        }
    end
end
event.register("calcTravelPrice", checkTravel )

function this.getMaxStat(stat)
    if stat == "health" then return getMaxHealth() end
    if stat == "magicka" then return getMaxMagicka() end
    if stat == "fatigue" then return getMaxFatigue() end
end

--For "Rest until healed", we need to set base to max while resting
local function enterRestMenu()
    local maxHealth = getMaxHealth()
    baseHealthCache = tes3.mobilePlayer.health.base
    tes3.setStatistic({
        reference = tes3.mobilePlayer,
        base = maxHealth,
        name = "health"
    })
end
event.register("uiActivated", enterRestMenu, { filter = "MenuRestWait"})




return this