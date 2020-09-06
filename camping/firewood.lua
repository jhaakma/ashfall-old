----------------------
--FIREWOOD
----------------------

local common = require ("mer.ashfall.common.common")

local skipActivate
local function pickupFirewood(ref)
    timer.delayOneFrame(function()
        skipActivate = true
        tes3.player:activate(ref)
        skipActivate = false
    end)
end

local function registerCampfire(reference)
    reference.data.fuelLevel = reference.stackSize
    reference.data.isStewer = true
    reference.data.isFuelConsumer = true
    reference.data.isGriller = true
    reference.data.grillMinHeight = 21
    reference.data.grillMaxHeight = 50
    reference.data.grillDistance = 40
    event.trigger("Ashfall:registerReference", { reference = reference})
end

local function placeCampfire(e)
    --Check how steep the land is
    local maxSteepness = 0.3
    local ground = common.helper.getGroundBelowRef(e.target)
    local tooSteep = (
        ground.normal.x > maxSteepness or
        ground.normal.x < -maxSteepness or
        ground.normal.y > maxSteepness or
        ground.normal.y < -maxSteepness
    ) 
    if tooSteep then 
        tes3.messageBox{ message = "The ground is too steep here.", buttons = {tes3.findGMST(tes3.gmst.sOK).value}}
        return
    end
    
    mwscript.disable({ reference = e.target })

    local newRef = tes3.createReference{
        object = common.staticConfigs.objectIds.campfire,
        position = e.target.position,
        orientation = e.target.orientation,
        cell = e.target.cell
    }
    registerCampfire(newRef)
    newRef.light:setAttenuationForRadius(0)
    event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = newRef, all = true})
end


local function onActivateFirewood(e)
    if skipActivate then return end
    if tes3.menuMode() then return end
    if string.lower(e.target.object.id) == common.staticConfigs.objectIds.firewood then
        local cell =tes3.getPlayerCell()
        if cell.restingIsIllegal then
            return
        end

        common.helper.messageBox({
            message = string.format("You have %d %s.", e.target.stackSize, e.target.object.name),
            buttons = {
                { text = "Create Campfire", callback = function() placeCampfire(e) end },
                { text = "Pick Up", callback = function() pickupFirewood(e.target) end },
                { text = "Cancel" }
            }
        })
        return true
    end
end
event.register("activate", onActivateFirewood )