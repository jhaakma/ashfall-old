local common = require("mer.ashfall.common")
local this = {}
local loseSleepRateWaiting = 3.0
local loseSleepRate = 3.5
local gainSleepRate = 3.5
local bedMultiplier = 3.0

function this.calculate(scriptInterval)
    if not common.data.mcmOptions.enableSleep then
        common.data.sleep = 100
    end
    local sleep = common.data.sleep or 100

    if tes3.mobilePlayer.sleeping then
        
        local usingBed = common.data.usingBed or false
        if usingBed then
            --mwse.log("Using bed")
            sleep = sleep + ( scriptInterval * gainSleepRate * bedMultiplier )
        else
            --mwse.log("Not using bed")
            --Not using bed, gain sleep slower and can't get above "Rested"
            if sleep < common.conditions.sleep.rested.max then
                sleep = sleep + ( scriptInterval * gainSleepRate )
            end
        end
    --TODO: traveling isn't working for some reason
    elseif tes3.mobilePlayer.travelling then
        mwse.log("travelling")
        --Traveling: getting some rest but can't get above "Rested"
        if sleep < common.conditions.sleep.rested.max then
            sleep = sleep + ( scriptInterval * gainSleepRate )
        end
    --Waiting
    elseif tes3.menuMode() then
        sleep = sleep - ( scriptInterval * loseSleepRateWaiting )
    else
        sleep = sleep - ( scriptInterval * loseSleepRate )
    end
    sleep = math.clamp(sleep, 0, 100)
    common.data.sleep = sleep
end

return this