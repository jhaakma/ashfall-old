local this = {}
local skillModule = include("OtherSkills.skillModule")
--[[
    Returns a human readable timestamp of the given time (or else the current time)
]]
function this.hourToClockTime ( time )
    local gameTime = time or tes3.getGlobal("GameHour")
    local formattedTime
    
    local isPM = false
    if gameTime > 12 then
        isPM = true
        gameTime = gameTime - 12
    end
    
    local hourString
    if gameTime < 10 then 
        hourString = string.sub(gameTime, 1, 1)
    else
        hourString  = string.sub(gameTime, 1, 2)
    end

    local minuteTime = ( gameTime - hourString ) * 60
    local minuteString
    if minuteTime < 10 then
        minuteString = "0" .. string.sub( minuteTime, 1, 1 )
    else
        minuteString = string.sub ( minuteTime , 1, 2)
    end
    formattedTime = hourString .. ":" .. minuteString .. (isPM and " pm" or " am")
    return ( formattedTime )
end

--[[
    Transfers an amount from the field of one object to that of another
]]
function this.transferQuantity(source, target, sourceField, targetField, amount)
    source[sourceField] = source[sourceField] - amount
    target[targetField] = target[targetField] + amount
end

--[[
    Checks if there is any static object directly above the given reference.

    This is an expensive function! To see if the player is sheltered, use common.data.isSheltered instead.
]]
function this.checkRefSheltered(reference)
    reference = reference or tes3.player

    local oldCulledValue = reference.sceneNode.appCulled
    reference.sceneNode.appCulled = true
    local result = tes3.rayTest{
        position = reference.position,
        direction = {0, 0, 1},
        --useBackTriangles = true
    }
    reference.sceneNode.appCulled = oldCulledValue

    local sheltered =  (
        result and result.reference and result.reference.object and 
        ( result.reference.object.objectType == tes3.objectType.static 
            or
        result.reference.object.objectType == tes3.objectType.activator )
    ) == true
    return sheltered
end

--[[
    Allows the creation of messageboxes using buttons that each have their own callback.
    {
        message = "Message",
        buttons = [
            { text = "Button text", callback = function() }
        ]
    }
]]
function this.messageBox(params)

    --[[
        Button = { text, callback}
    ]]--

    local message = params.message
    local buttons = params.buttons

    local function callback(e)
        --get button from 0-indexed MW param
        local button = buttons[e.button+1]
        if button.callback then
            button.callback()
        end
    end

    --Make list of strings to insert into buttons
    local buttonStrings = {}
    for _, button in ipairs(buttons) do
        table.insert(buttonStrings, button.text)
    end

    tes3.messageBox({
        message = message,
        buttons = buttonStrings,
        callback = callback
    })
end

--[[
    Create a popup with a slider that sets a table value
]]
local menuId = tes3ui.registerID("Ashfall:SliderPopup")
function this.createSliderPopup(params)
    assert(params.label)
    assert(params.varId)
    assert(params.table)
    --[[Optional params:
        jump - slider jump value
        okayCallback - function called on Okay
        cancelCallback - function called on Cancel
    ]]

    local menu = tes3ui.createMenu{ id = menuId, fixedFrame = true }
    tes3ui.enterMenuMode(menuId)

    --Slider
    local sliderBlock = menu:createBlock()
    sliderBlock.width = 500
    sliderBlock.autoHeight = true
    mwse.mcm.createSlider(
        menu,
        {
            label = params.label,
            min = params.min or 0,
            max = params.max or 100,
            jump = params.jump or 10,
            variable = mwse.mcm.createTableVariable{
                id = params.varId,
                table = params.table
            },
        }
    )
    local buttonBlock = menu:createBlock()
    buttonBlock.autoHeight = true
    buttonBlock.widthProportional = 1.0
    buttonBlock.childAlignX = 1.0

    --Okay
    local okayButton = buttonBlock:createButton{
        text = tes3.findGMST(tes3.gmst.sOK).value
    }

    okayButton:register("mouseClick",
        function()
            menu:destroy()
            tes3ui.leaveMenuMode(menuId)
            if params.okayCallback then
                timer.delayOneFrame(params.okayCallback)
            end
        end
    )

    --Cancel
    local cancelButton = buttonBlock:createButton{
        text = tes3.findGMST(tes3.gmst.sCancel).value
    }
    cancelButton:register("mouseClick",
        function()
            menu:destroy()
            tes3ui.leaveMenuMode(menuId)
            if params.cancelCallback then
                timer.delayOneFrame(params.cancelCallback)
            end
        end
    )
    menu:getTopLevelMenu():updateLayout()
end


--[[
    Fades out, passes time then runs callback when finished
]]--
function this.fadeTimeOut( hoursPassed, secondsTaken, callback )
    local function fadeTimeIn()
        tes3.runLegacyScript({command = "EnablePlayerControls"})
        callback()
        tes3.player.data.Ashfall.muteConditionMessages = false
    end

    tes3.player.data.Ashfall.muteConditionMessages = true
    tes3.fadeOut({ duration = 0.5 })
    tes3.runLegacyScript({command = "DisablePlayerControls"})
    --Halfway through, advance gamehour
    local iterations = 10
    timer.start({
        type = timer.real,
        iterations = iterations,
        duration = ( secondsTaken / iterations ),
        callback = (
            function()
                local gameHour = tes3.findGlobal("gameHour")
                gameHour.value = gameHour.value + (hoursPassed/iterations)
            end
        )
    })
    --All the way through, fade back in
    timer.start({
        type = timer.real,
        iterations = 1,
        duration = secondsTaken,
        callback = (
            function()
                local fadeBackTime = 1
                tes3.fadeIn({ duration = fadeBackTime })
                timer.start({
                    type = timer.real,
                    iterations = 1,
                    duration = fadeBackTime, 
                    callback = fadeTimeIn
                })
            end
        )
    })
end


--[[
    Restore lost fatigue to prevent collapsing
]]
function this.restoreFatigue()
    local previousFatigue = tes3.mobilePlayer.fatigue.current
    timer.start{
        type = timer.real,
        iterations = 1,
        duration = 0.01,

        callback = function()
            local newFatigue = tes3.mobilePlayer.fatigue.current
            if previousFatigue >= 0 and newFatigue < 0 then
                tes3.mobilePlayer.fatigue.current = previousFatigue
            end
        end
    }
end

--[[
    Attempt to contract a disease
]]


function this.tryContractDisease(spellID)

    local resistDisease = tes3.mobilePlayer.resistCommonDisease 
    local survival = skillModule.getSkill("Ashfall:Survival").value

    local resistEffect = math.remap( math.min(resistDisease, 100), 0, 100, 1.0, 0.0 )
    local survivalEffect =  math.remap( math.min(survival, 100), 0, 100, 1.0, 0.5 )

    local defaultChance = 0.3

    local catchChance = defaultChance * resistEffect * survivalEffect
    
    if math.random() < catchChance then
        local spell = tes3.getObject(spellID)
        tes3.messageBox(tes3.findGMST(tes3.gmst.sMagicContractDisease).value, spell.name)
        mwscript.addSpell{ reference = tes3.player, spell = spell  }
    end
end

--[[
    Get a number between 0 and 1 based on the current day of the year, 
    where 0 is the middle of Winter and 1 is the middle of Summer
]]
local day
local month
function this.getSeasonMultiplier()
    day = day or tes3.worldController.day
    month = month or tes3.worldController.month
    local dayOfYear = day.value + tes3.getCumulativeDaysForMonth(month.value)

    local dayAdjusted = dayOfYear < 196 and dayOfYear  or ( 196 - ( dayOfYear - 196 ) ) 
    
    local seasonMultiplier = math.remap(dayAdjusted, 0, 196, 0, 1)
    return seasonMultiplier
end

return this