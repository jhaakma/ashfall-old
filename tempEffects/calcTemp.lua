--[[

    This script runs on a timer to update the External temperature and player temperature
    This is where

]]--
local this = {}

local common = require("mer.ashfall.common")
local hud = require("mer.ashfall.ui.hud")
-------------------------------------CONFIG VALUES-------------------------------------

--Determines how fast tempLimit catches up to tempReal
local limitRate = 50

--Determines how fast tempPlayer catches up to tempLimit
local playerRate = 3.5
local minPlayerDiff = 20

--"Region" temp when inside
local interiorWeatherMultiplier = 0.4
--All effects reduced slightly when inside
local interiorRealTempMultiplier = 0.7
----------------------------------------------------------------------------------------

--temperature variables
local tempRaw
local tempReal
local tempLimit
local tempPlayer

--How slowly changes during sleep
local sleepMulti = 0.7

--GameHour variables
local gameHour

--[[------------------------------------------------------------------

    calculateTemp()
    Calculate tempLimit and tempPlayer

    called by tempTimer module

]]-------------------------------------------------------------------
function this.calculateTemp(timerInterval)
    if not common.data then return end


    tempRaw = common.data.tempRaw or 0
    tempReal = common.data.tempReal or 0
    tempLimit = common.data.tempLimit or 0
    tempPlayer = common.data.temp or 0

    if not common.data.mcmOptions.enableAshfall then
        common.data.tempRaw = 0
        common.data.tempReal = 0
        common.data.tempLimit = 0
        common.data.temp = 0
        hud.updateHUD()
        return
    end


    --Environmental Factors -- additives
    local weatherTemp = common.data.weatherTemp or 0
    local wetTemp = common.data.wetTemp or 0
    local torchTemp = common.data.torchTemp or 0
    local fireTemp = common.data.fireTemp or 0
    local hazardTemp = common.data.hazardTemp or 0
    local fireDamTemp = common.data.fireDamTemp or 0
    local frostDamTemp = common.data.frostDamTemp or 0
    local clothingTemp = common.data.clothingTemp or 0
    local armorTemp = common.data.armorTemp or 0
    local bedTemp = common.data.bedTemp or 0
    local tentTemp = common.data.tentTemp or 0
    local furTemp = common.data.furTemp or 0

    --Player Effects -- multipliers
    local hungerEffect = common.data.hungerEffect or 1
    local thirstEffect = common.data.thirstEffect or 1
    local resistFrostEffect = common.data.ResistFrostEffect or 1
    local resistFireEffect = common.data.resistFireEffect or 1
    local alcoholEffect = common.data.alcoholEffect or 1
    local vampireColdEffect = common.data.vampireColdEffect or 1
    local vampireWarmEffect = common.data.vampireWarmEffect or 1



    --Inside: region/time have significantly reduced effect, temp hovers around comfortable
    local cell = tes3.getPlayerCell()
    local intWeatherEffect = common.data.intWeatherEffect or 0
    if cell.isInterior then
        tempRaw = ( weatherTemp * interiorWeatherMultiplier ) + intWeatherEffect
    else
        tempRaw =  weatherTemp
    end
    common.data.tempRaw = tempRaw
    tempReal = (
        tempRaw  + wetTemp
                 + torchTemp
                 + fireTemp
                 + hazardTemp
                 + fireDamTemp
                 + frostDamTemp
                 + clothingTemp
                 + armorTemp
                 + furTemp
    )
    common.data.tempRaw = tempRaw
    --cold exclusive effects
    if tempReal < 0 then
        tempReal =  math.min( (tempReal + bedTemp + tentTemp ), 0 )
        tempReal = ( 
            tempReal 
            * hungerEffect
            * resistFrostEffect
            * alcoholEffect
            * vampireColdEffect
        )
    --hot exclusive effects
    elseif tempReal > 0 then
        tempReal = (
            tempReal 
            * thirstEffect
            * resistFireEffect
            * alcoholEffect
            * vampireWarmEffect
        )
    end

    --On top of minimising outside weather effects, all other effects
    -- are reduced indoors as well, for the sake of reducing annoyance
    if cell.isInterior then
        tempReal = tempReal * interiorRealTempMultiplier
    end

    common.data.tempReal = tempReal
    --[[------------------------------------
    Calculate tempLimit
            - "Environment Temp"
            - Moves towards tempReal
            - Synced to GameHour
    ]]-----------------------------------
    local limitDiff = math.abs( tempReal - tempLimit )
    local limitChange = limitDiff * limitRate * timerInterval
    limitChange = math.clamp( limitChange, 0, limitDiff )

    tempLimit = tempLimit + ( ( tempLimit < tempReal ) and limitChange or -limitChange )
    common.data.tempLimit = tempLimit

    --[[------------
    ------------------------

        Calculate tempPlayer
            - Moves towards tempLimit
            - Synced to GameHour
            - Slower while sleeping
            - warm slower while wet
            - cool faster while wet

    ]]--------------------------------------
    local playerDiff = math.abs( tempLimit - tempPlayer )
    playerDiff = ( playerDiff < minPlayerDiff ) and minPlayerDiff or playerDiff

    local playerChange = playerDiff * playerRate * timerInterval

    if tes3.menuMode() then
        playerChange = playerChange * sleepMulti
    end

    --Warmth rate 0.5x at 100 wetness. Cooling rate 2x at 100% wetness
    local wetness = common.data.wetness or 0
    local wetTempEffect = ( tempPlayer < tempLimit ) and 0.5 or 2.0
    local wetMulti = math.remap( wetness, 0, 100, 1.0, wetTempEffect )
    playerChange = playerChange * wetMulti

    --prevent overshoot
    playerChange = math.clamp( playerChange, 0, playerDiff )

    --set player temp
    tempPlayer = tempPlayer + ( ( tempPlayer < tempLimit) and playerChange or -playerChange )
    common.data.temp = tempPlayer
    -----------------------------------------------
    hud.updateHUD()
end

--Press G key to see temperature updates
local function onKeyG(e)
    if not common.data then return end
    if not tes3.menuMode() then
        if e.pressed then
            if not common.data.weatherTemp then
                tes3.messageBox("No weatherTemp")
            end

            gameHour = tes3.getGlobal("GameHour")
            --local currentTime = common.hourToClockTime(gameHour)
            tes3.messageBox(
                "Total Warmth = " .. ( common.data.armorTemp + common.data.clothingTemp )
            )
            tes3.messageBox(
                "Total Coverage = " .. ( common.data.armorCoverage + common.data.clothingCoverage )
            )

            --tes3.messageBox("TempRaw: %.2f, tempReal: %.2f, tempLimit: %.2f", tempRaw, tempReal,tempLimit )
            --tes3.messageBox("RegionTemp: %.2f \n weatherTemp: %.2f \n WetTemp: %.2f",
                --common.data.regionTemp, common.data.weatherTemp, common.data.wetTemp)
            --tes3.messageBox("Armor coverage: %.2f, Clothing coverage: %.2f",
                --common.data.armorCoverage, common.data.clothingCoverage )
            --tes3.messageBox("Weather Temp: %.2f, int Weather: %s",
                --common.data.weatherTemp, ( common.data.intWeatherEffect or "nil"  ))
            --tes3.messageBox("Thirst: %.0f", ( common.data.thirst or "nil" ) )
        end
    end
end


--event.register("key", onKeyG, {filter = 34})
return this


