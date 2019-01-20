
--[[
    Add frosty breath to player/NPCs when it's freezing cold outside
--]]

local common = require("mer.ashfall.common")
local this = {}

local coldLevelNeeded = common.conditions.temp.veryCold.max

local function checkEnabled()
    return common.data.mcmOptions.showFrostBreath
end

local function addBreath(node, x, y, z)

    if not node:getObjectByName("smokepuffs.nif") then
        local smokepuffs = tes3.loadMesh("ashfall\\smokepuffs.nif"):clone()
        node:attachChild(smokepuffs, true)
        smokepuffs.translation.x = x
        smokepuffs.translation.y = y
        smokepuffs.translation.z = z
        smokepuffs.rotation = node.worldTransform.rotation:invert()
    end
end

local function removeBreath(node)
    if node:getObjectByName("smokepuffs.nif") then
        node:detachChild(node:getObjectByName("smokepuffs.nif"), true)
    end
end


function this.doFrostBreath()

    local temp = common.data.tempRaw
    local isCold = temp < coldLevelNeeded
    for ref in tes3.getPlayerCell():iterateReferences(tes3.objectType.npc) do
        if ( ref.mobile and ref.sceneNode ) then
            local node = ref.sceneNode:getObjectByName("Bip01 Head")
            

            local isAlive = ( ref.mobile.health.current > 0 )
            local isAboveWater = ( ref.mobile.underwater == false )
            if isCold and isAboveWater and isAlive and checkEnabled() then
                addBreath(node, 0, 11, 0)
            else
                removeBreath(node)
            end
        end
    end


    local node = tes3.player.sceneNode and tes3.player.sceneNode:getObjectByName("Bip01 Head")

    if node then
        if isCold and tes3.mobilePlayer.underwater == false and checkEnabled() then
            addBreath(node, 0, 11, 0)
        else
            removeBreath(node)
        end
    end

    node = tes3.worldController.worldCamera.cameraRoot
    if node then 
        local isAboveWater = ( tes3.mobilePlayer.underwater == false )
        if isCold and not tes3.is3rdPerson() and isAboveWater and checkEnabled() then
            addBreath(node, 0, 5, -16)
        else
            removeBreath(node)
        end
    end
end
return this


