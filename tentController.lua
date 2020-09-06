local common = require("mer.ashfall.common.common")

local this = {}
local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerExternalHeatSource{ id = "tentTemp", coldOnly = true }

local skipActivate

--When sleeping in a tent, you can't be woken up by creatures
local function calcRestInterrupt(e)
    if common.helper.getInTent()  then
        e.count = 0
    end
end

event.register("calcRestInterrupt", calcRestInterrupt)


local function triggerInTent()
    common.helper.setInTent(true)
    event.trigger("Ashfall:updateTemperature", { source = "triggerInTent" } )
    common.data.isSheltered = true
    timer.delayOneFrame(function()
        common.helper.setInTent(false)
    end)
end



local function getPlacementBlocked()
    return (
        tes3.player.cell.restingIsIllegal or
        tes3.player.cell.isInterior
    )
end

local function unpackTent(miscRef)
    --Can't unpack in towns/indoors
    if getPlacementBlocked() then
        tes3.messageBox("You can't do that here, resting is illegal.")
        return
    else
        timer.delayOneFrame(function()
            tes3.createReference {
                object = common.helper.getTentActiveFromMisc(miscRef),
                position = miscRef.position:copy(),
                orientation = miscRef.orientation:copy(),
                cell = miscRef.cell
            }
        
            tes3.runLegacyScript{ command = 'Player->Drop "ashfall_resetlight" 1'}

            common.helper.yeet(miscRef)
        end)
    end
end

local function packTent(activeRef)
    timer.delayOneFrame(function()
        -- tes3.createReference {
        --     object = common.helper.getTentMiscFromActive(activeRef),
        --     position = activeRef.position:copy(),
        --     orientation = activeRef.orientation:copy(),
        --     cell = activeRef.cell
        -- }
        -- tes3.runLegacyScript{ command = 'Player->Drop "ashfall_resetlight" 1'}
        tes3.addItem{
            reference = tes3.player,
            item = common.helper.getTentMiscFromActive(activeRef),
            updateGUI = true,
            count =  1
        }
        common.helper.yeet(activeRef)
    end)
end


local function packedTentMenu(miscRef)
    local message = miscRef.object.name
    local buttons = {
        {
            text = "Unpack",
            callback = function()
                unpackTent(miscRef)
            end
        },
        {
            text = "Pick Up",
            callback = function()
                timer.delayOneFrame(function()
                    skipActivate = true
                    tes3.player:activate(miscRef)
                end)
            end
        },
        { text = "Do Nothing"}
    }
    common.helper.messageBox{
        message = message, 
        buttons = buttons
    }
end

local function activeTentMenu(activeRef)
    local message = activeRef.object.name
    local buttons = {
        -- { 
        --     text = "Sleep",
        --     callback = callRestMenu
        -- },
        {
            text = "Pack Up",
            callback = function() packTent(activeRef) end
        },
        { text = "Do Nothing"}
    }
    common.helper.messageBox{
        message = message, 
        buttons = buttons
    }
end



local function activateTent(e)
    --Check if it's a misc tent ref
    if common.helper.getTentActiveFromMisc(e.target) then
        --Skip if picking up
        if skipActivate then
            skipActivate = false
            return
        end
        --Pick up if activating while in inventory
        if tes3ui.menuMode() then
            return
        else
            packedTentMenu(e.target)
            return false
        end
    --Check if it's an activator tent ref
    elseif common.helper.getTentMiscFromActive(e.target) then
        activeTentMenu(e.target)
        return false
    end
end
event.register("activate", activateTent)



return this
