local common = require("mer.ashfall.common.common")

local this = {}

function this.calculate(scriptInterval)
    if not common.data.mcmSettings.enableSleep then
        common.data.sleep = 100
    end
    local sleep = common.data.sleep or 100
    local loseSleepRate = common.data.mcmSettings.loseSleepRate / 10
    local loseSleepWaiting = common.data.mcmSettings.loseSleepWaiting / 10
    local gainSleepRate = common.data.mcmSettings.gainSleepRate / 10  
    local gainSleepBed = common.data.mcmSettings.gainSleepBed / 10
    

    if tes3.mobilePlayer.sleeping then


        local usingBed = common.data.usingBed or false
        if usingBed then
            sleep = sleep + ( scriptInterval * gainSleepBed )
        else
            --Not using bed, gain sleep slower and can't get above "Rested"
            local newSleep = sleep + ( scriptInterval * gainSleepRate )
            if newSleep < common.config.conditions.sleep.states.rested.max then
                sleep = newSleep
            end
        end
    --TODO: traveling isn't working for some reason
    elseif tes3.mobilePlayer.travelling then
        --Traveling: getting some rest but can't get above "Rested"
        if sleep < common.config.conditions.sleep.states.tired.max then
            sleep = sleep + ( scriptInterval * gainSleepRate )
        end
    --Waiting
    elseif tes3.menuMode() then
        sleep = sleep - ( scriptInterval * loseSleepWaiting )
    else
        sleep = sleep - ( scriptInterval * loseSleepRate )
    end
    sleep = math.clamp(sleep, 0, 100)
    common.data.sleep = sleep
end

return this