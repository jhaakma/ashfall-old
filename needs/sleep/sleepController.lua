local common = require("mer.ashfall.common.common")
local needsUI = require("mer.ashfall.needs.needsUI")
local this = {}
local statsEffect = require("mer.ashfall.needs.statsEffect")
local coldRestLimit = common.conditions.temp.states.veryCold.min
local hotRestLimit = common.conditions.temp.states.veryHot.max
local isUsingBed
local isWaiting
local bedWarmth = 10

local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerInternalHeatSource("bedTemp")

local hunger = common.conditions.hunger
local thirst = common.conditions.thirst
local tiredness = common.conditions.tiredness



local function setRestValues(e)
    if not common.data then return end
    --scripted means the player has activated a bed or bedroll
    isUsingBed = e.scripted
    isWaiting = not e.allowRest
end
event.register("uiShowRestMenu", setRestValues )



local function hideSleepItems(restMenu)
    local hiddenList = {}
    hiddenList.scrollbar = restMenu:findChild( tes3ui.registerID("MenuRestWait_scrollbar") )
    hiddenList.hourText = restMenu:findChild( tes3ui.registerID("MenuRestWait_hour_text") )
    hiddenList.hourActualText = hiddenList.hourText.parent.children[2]
    hiddenList.untilHealed = restMenu:findChild( tes3ui.registerID("MenuRestWait_untilhealed_button") )
    hiddenList.wait = restMenu:findChild( tes3ui.registerID("MenuRestWait_wait_button") )
    hiddenList.rest = restMenu:findChild( tes3ui.registerID("MenuRestWait_rest_button") )

    for _, element in pairs(hiddenList) do
        element.visible = false
    end
end

local function getTempInterruptText()
    --Set interrupt text
    local tempLimit = common.data.tempLimit
    local tempText = ( tempLimit < 0 ) and "cold" or "hot"
    local restText = ( isWaiting ) and "wait" or "rest"
    return string.format("It is too %s to %s, you must find shelter!", tempText, restText)
end

--Prevent tiredness if ENVIRONMENT is too cold/hot
--We do this by tapping into the Rest Menu,
--replacing the text and removing rest/wait buttons
local function activateRestMenu (e)
    if not common.data then return end

    if isUsingBed then
        --manually update tempLimit so you can see what it will be with the bedTemp added
        common.data.bedTemp = bedWarmth
        common.data.tempLimit = common.data.tempLimit + bedWarmth
        require("mer.ashfall.temperatureController").update()
        common.log.debug("Is Scripted: adding warmth")
    end

    local tempLimit = common.data.tempLimit + common.data.bedTemp
    local restMenu = e.element
    local labelText = restMenu:findChild( tes3ui.registerID("MenuRestWait_label_text") )

    if ( tempLimit < coldRestLimit ) or (tempLimit > (hotRestLimit + common.data.bedTemp) ) then
        common.log.debug("blocked by activateRestMenu")
        labelText.text = getTempInterruptText()
        hideSleepItems(restMenu)
    elseif hunger:getValue() > hunger.states.starving.min then
        labelText.text = "You are too hungry to " .. ( isWaiting and "wait." or "rest.")
        hideSleepItems(restMenu)
    elseif thirst:getValue() > thirst.states.dehydrated.min then
        labelText.text = "You are too thirsty to " .. ( isWaiting and "wait." or "rest.")
        hideSleepItems(restMenu)
    elseif tiredness:getValue() > tiredness.states.exhausted.min and isWaiting then
        labelText.text = "You are too tired to wait."
        hideSleepItems(restMenu)
    end
    --Hide "Rest until healed" button if health is not lower than max
    local maxHealth = statsEffect.getMaxStat("health")
    if tes3.mobilePlayer.health.current >= maxHealth then
        e.element:findChild( tes3ui.registerID("MenuRestWait_untilhealed_button") ).visible = false
    end


    local isResting = ( 
        e.element:findChild( tes3ui.registerID("MenuRestWait_rest_button") ).visible 
    )
    if isResting then
        needsUI.addNeedsBlockToMenu(e, "tiredness")
    end
    restMenu:updateLayout()

end
event.register("uiActivated", activateRestMenu, { filter = "MenuRestWait" })

local function preventNextCycle()
    common.log.debug("FISDUFhsdiujh")
    return true
end

event.register("weatherCycled", preventNextCycle)
local function checkSleeping(interval)
    --whether waiting or sleeping, wake up
    local restingOrWaiting = (
        interval > 0 and
        tes3.menuMode() and 
        common.data.mcmSettings.enableTemperatureEffects and 
        tes3.player.data.Ashfall.fadeBlock ~= true and 
        not common.data.blockNeeds
    )
    if restingOrWaiting then
        --Temperature
        local tempLimit = common.data.tempLimit
        
        common.log.debug("tempLimit: %s", tempLimit)
        common.log.debug("coldRestLimit: %s", coldRestLimit)
        common.log.debug("hotRestLimit: %s", hotRestLimit)
        if tempLimit < coldRestLimit or tempLimit > (hotRestLimit + common.data.bedTemp) then
            common.log.debug("blocked by checkSleeping")
            mwscript.wakeUpPC()
            
            tes3.messageBox({ message = getTempInterruptText(), buttons = { "Okay" } })
            --needs
        end
        if hunger:getValue() > hunger.states.starving.min then
            --Cap the hunger loss
            hunger:setValue(hunger.states.starving.min)
            --Wake PC
            mwscript.wakeUpPC()
            
            --Message PC
            tes3.messageBox({ message = "You are starving.", buttons = { "Okay" } }) 
        elseif thirst:getValue() > thirst.states.dehydrated.min then
            --Cap the thirst loss
            mwscript.wakeUpPC()
            
            --Wake PC
            thirst:setValue(thirst.states.dehydrated.min)
            --Message PC
            tes3.messageBox({ message = "You are dehydrated.", buttons = { "Okay" } }) 
        elseif tiredness:getValue() > tiredness.states.exhausted.min and isWaiting then
            --Cap the tiredness loss
            tiredness:setValue(tiredness.states.exhausted.min)
            --Rouse PC
            mwscript.wakeUpPC()
            
            --Message PC
            tes3.messageBox({ message = "You are exhausted.", buttons = { "Okay" } }) 
        end
    end
    
    if tes3.mobilePlayer.sleeping and isUsingBed then
        common.data.usingBed = true
        common.data.bedTemp = bedWarmth
    end 
end


function this.calculate(scriptInterval)
    checkSleeping(scriptInterval)

    --if not forceUpdate and scriptInterval == 0 then return end
    if not common.data.mcmSettings.enableTiredness then
        tiredness:setValue(100)
    end
    if common.data.blockNeeds == true then
        return
    end

    local currentTiredness = tiredness:getValue()
    local loseSleepRate = common.data.mcmSettings.loseSleepRate / 10
    local loseSleepWaiting = common.data.mcmSettings.loseSleepWaiting / 10
    local gainSleepRate = common.data.mcmSettings.gainSleepRate / 10  
    local gainSleepBed = common.data.mcmSettings.gainSleepBed / 10
    

    if tes3.mobilePlayer.sleeping then
        local usingBed = common.data.usingBed or false
        if usingBed then
            currentTiredness = currentTiredness - ( scriptInterval * gainSleepBed )
        else
            --Not using bed, gain tiredness slower and can't get below "Rested"
            local newTiredness = currentTiredness - ( scriptInterval * gainSleepRate )
            if newTiredness > tiredness.states.rested.min then
                currentTiredness = newTiredness
            end
        end
    --TODO: traveling isn't working for some reason
    elseif tes3.mobilePlayer.travelling then
        --Traveling: getting some rest but can't get below "Rested"
        if currentTiredness > tiredness.states.rested.min then
            currentTiredness = currentTiredness - ( scriptInterval * gainSleepRate )
        end
    --Waiting
    elseif tes3.menuMode() then
        currentTiredness = currentTiredness + ( scriptInterval * loseSleepWaiting )
    else
        currentTiredness = currentTiredness + ( scriptInterval * loseSleepRate )
    end
    currentTiredness = math.clamp(currentTiredness, 0, 100)
    tiredness:setValue(currentTiredness)
end


--Reset the bedTemp when player wakes up
event.register("simulate", function()
    if not tes3.mobilePlayer.sleeping and common.data.bedTemp ~= 0 then
        common.data.usingBed = false
        common.data.bedTemp = 0
    end    
end)

return this