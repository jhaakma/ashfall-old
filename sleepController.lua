local common = require("mer.ashfall.common")
local needsUI = require("mer.ashfall.needs.needsUI")
local this = {}

local coldRestLimit = common.conditions.temp.states.veryCold.min
local hotRestLimit = common.conditions.temp.states.veryHot.max
local interruptText = ""
local isScripted
local isWaiting
local bedTemp = 20


local function setRestValues(e)
    if not common.data then return end
    --scripted means the player has activated a bed or bedroll
    isScripted = e.scripted
    isWaiting = not e.allowRest
    --Set interrupt text
    local tempText
    local temp = common.data.tempLimit
    local tempText = ( temp < 0 ) and "cold" or "hot"
    local restText = ( e.allowRest ) and "rest" or "wait"

    interruptText = string.format("It is too %s to %s, you must find shelter!", tempText, restText)

end

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

--Prevent sleep if ENVIRONMENT is too cold/hot
--We do this by tapping into the Rest Menu,
--replacing the text and removing rest/wait buttons
local function activateRestMenu (e)
    if not common.data then return end

    if isScripted then
        --manually update temp so you can see what it will be with the bedTemp added
        if common.data.tempLimit < 0 then
            common.data.bedTemp = bedTemp
            common.data.tempLimit = common.data.tempLimit + bedTemp
        end
        require("mer.ashfall.tempEffects.calcTemp").calculateTemp(0)
    end

    local temp = common.data.tempLimit + ( isScripted and common.bedTemp or 0 )
    local restMenu = e.element
    local labelText = restMenu:findChild( tes3ui.registerID("MenuRestWait_label_text") )

    if temp < ( coldRestLimit ) or temp > ( hotRestLimit - common.data.bedTemp ) then
        labelText.text = interruptText
        hideSleepItems(restMenu)
    elseif common.data.hunger > common.conditions.hunger.states.starving.min then
        labelText.text = "You are too hungry to " .. ( isWaiting and "wait." or "rest.")
        hideSleepItems(restMenu)
    elseif common.data.thirst > common.conditions.thirst.states.dehydrated.min then
        labelText.text = "You are too thirsty to " .. ( isWaiting and "wait." or "rest.")
        hideSleepItems(restMenu)
    elseif common.data.sleep < common.conditions.sleep.states.exhausted.max and isWaiting then
        labelText.text = "You are too tired to wait."
        hideSleepItems(restMenu)
    end

    local isResting = ( 
        e.element:findChild( tes3ui.registerID("MenuRestWait_rest_button") ).visible 
    )
    if isResting then
        needsUI.addNeedsBlockToMenu(e, "sleep")
    end

    restMenu:updateLayout()
end

--Wake up if sleeping and ENVIRONMENT is too cold/hot
function this.checkSleeping()
    --whether waiting or sleeping, wake up
    if tes3.menuMode() and common.data.mcmSettings.enableTemperatureEffects then
        if isScripted then
            --mwse.log("using bed")
            common.data.usingBed = true
            common.data.bedTemp = bedTemp
        --not using a bed at all
        else
           -- mwse.log("not using bed")
            common.data.usingBed = false
        end

        local temp = common.data.tempLimit
        --Temperature
        if temp < coldRestLimit or temp > hotRestLimit then
            tes3.runLegacyScript({ command = "WakeUpPC" })
            tes3.messageBox({ message = interruptText, buttons = { "Okay" } })

            --needs

        end
        local hunger = common.data.hunger or 0
        local thirst = common.data.thirst or 0
        local sleep = common.data.sleep or 100
        if hunger > common.conditions.hunger.states.starving.min then
            tes3.runLegacyScript({ command = "WakeUpPC" })
            tes3.messageBox({ message = "You are starving.", buttons = { "Okay" } }) 
        elseif thirst > common.conditions.thirst.states.dehydrated.min then
            tes3.runLegacyScript({ command = "WakeUpPC" })
            tes3.messageBox({ message = "You are dehydrated.", buttons = { "Okay" } }) 
        elseif sleep < common.conditions.sleep.states.exhausted.max and isWaiting then
            tes3.runLegacyScript({ command = "WakeUpPC" })
            tes3.messageBox({ message = "You are exhausted.", buttons = { "Okay" } }) 
        end
    else
        common.data.bedTemp = 0
    end
end





event.register("uiActivated", activateRestMenu, { filter = "MenuRestWait" })
event.register("uiShowRestMenu", setRestValues )

return this