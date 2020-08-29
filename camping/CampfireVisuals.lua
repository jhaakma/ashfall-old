local common = require ("mer.ashfall.common.common")

--[[
    Mapping of campfire states to switch node states.
]]
local switchNodeValues = {
    SWITCH_BASE = function()
        local state = { OFF = 0, ON = 1, }
        return state.ON
    end,
    SWITCH_FIRE = function(campfire)
        local state = { OFF = 0, LIT = 1, UNLIT = 2 }
        return campfire.data.isLit and state.LIT or state.UNLIT
    end,
    SWITCH_WOOD = function(campfire)
        local state = { OFF = 0, UNBURNED = 1, BURNED = 2 }
        return campfire.data.burned and state.BURNED or state.UNBURNED
    end,
    SWITCH_SUPPORTS = function(campfire)
        local state = { OFF = 0, ON = 1 }  
        return campfire.data.hasSupports and state.ON or state.OFF
    end,
    SWITCH_GRILL = function(campfire)
        local state = { OFF = 0, ON = 1 }  
        return campfire.data.hasGrill and state.ON or state.OFF
    end,
    SWITCH_COOKING_POT = function(campfire)
        local state = { OFF = 0, ON = 1 }
        return campfire.data.hasCookingPot and state.ON or state.OFF
    end,
    SWITCH_KETTLE = function(campfire)
        local state = { OFF = 0, ON = 1 }  
        return campfire.data.hasKettle and state.ON or state.OFF
    end,
    SWITCH_POT_STEAM = function(campfire)
        local state = { OFF = 0, ON = 1 } 
        local showSteam = ( 
            campfire.data.hasCookingPot and 
            campfire.data.waterHeat and
            campfire.data.waterHeat >= common.staticConfigs.hotWaterHeatValue
        )
        return showSteam and state.ON or state.OFF
    end,
    SWITCH_KETTLE_STEAM = function(campfire)
        local state = { OFF = 0, ON = 1 } 
        local showSteam = ( 
            campfire.data.hasKettle and 
            campfire.data.waterHeat and
            campfire.data.waterHeat >= common.staticConfigs.hotWaterHeatValue
        )
        --if showSteam then mwse.log("Showing steam") end
        return showSteam and state.ON or state.OFF
    end,
    SWITCH_STEW = function(campfire)
        local state = { OFF = 0, WATER = 1, STEW = 2}
        if not campfire.data.hasCookingPot then return state.OFF end

        return campfire.data.stewLevels and state.STEW or state.WATER
    end
}


--Iterate over switch nodes and update them based on the current state of the campfire
local function updateSwitchNodes(campfire)
    local sceneNode = campfire.sceneNode
    local switchNode

    if campfire.data.destroyed then
        for nodeName, _ in pairs(switchNodeValues) do
            switchNode = sceneNode:getObjectByName(nodeName)
            if switchNode then
                switchNode.switchIndex = 0
            end
        end
    else
        for nodeName, getIndex in pairs(switchNodeValues) do
            switchNode = sceneNode:getObjectByName(nodeName)
            if switchNode then
                switchNode.switchIndex = getIndex(campfire)
            end
        end
    end
end

--As fuel levels change, update the radius of light given off by the campfire
local function updateLightingRadius(campfire)
    if campfire.light then
        local radius = campfire.object.radius
        if not campfire.data.isLit then
            campfire.light:setAttenuationForRadius(0)
        else
            local newRadius = math.clamp( ( campfire.data.fuelLevel / 10 ), 0, 1) * radius
            campfire.light:setAttenuationForRadius(newRadius)
        end
    end
end


--As fuel levels change, update the size of the flame
local function updateFireScale(campfire)
    local multiplier = 1 + ( campfire.data.fuelLevel * 0.05 )
    multiplier = math.clamp( multiplier, 0.5, 1.5)
    local fireNode = campfire.sceneNode:getObjectByName("FIRE_PARTICLE_NODE")
    fireNode.scale = multiplier
end

--Update the water level of the cooking pot
local function updateWaterHeight(campfire)
    local scaleMax = 1.3
    local heightMax = 28
    if campfire.data.hasCookingPot and campfire.data.waterAmount then
        local waterLevel = campfire.data.waterAmount or 0
        local scale = math.min(math.remap(waterLevel, 0, common.staticConfigs.capacities.cookingPot, 1, scaleMax), scaleMax )
        local height = math.min(math.remap(waterLevel, 0, common.staticConfigs.capacities.cookingPot, 0, heightMax), heightMax)

        local waterNode = campfire.sceneNode:getObjectByName("POT_WATER")
        waterNode.translation.z = height
        waterNode.scale = scale
        local stewnode = campfire.sceneNode:getObjectByName("POT_STEW")
        stewnode.translation.z = height
        stewnode.scale = scale
        
    end
end

--Update the size of the steam coming off a cooking pot
local function updateSteamScale(campfire)
    local hasSteam = ( 
        campfire.data.hasCookingPot and 
        campfire.data.waterHeat and
        campfire.data.waterHeat >= common.staticConfigs.hotWaterHeatValue
    
    )
    if hasSteam then
        local steamScale = math.min(math.remap(campfire.data.waterHeat, common.staticConfigs.hotWaterHeatValue
    , 100, 0.5, 1.0), 1.0)
        local steamNode = campfire.sceneNode:getObjectByName("POT_STEAM").children[1]
        steamNode.scale = steamScale
    end
end

--Update the collision box of the campfire
local function updateCollision(campfire)
    local collisionSwitch = campfire.sceneNode:getObjectByName("COLLISION_SUPPORTS")
    if campfire.data.hasSupports then
        collisionSwitch.flags = 32
    else
        collisionSwitch.flags = 0
    end

    if campfire.data.destroyed then     
        --Remove collision node
        local collisionNode = campfire.sceneNode:getObjectByName("COLLISION_BASE")
        collisionNode.scale = 0
    end
end




local function updateVisuals(e)
    local campfire = e.campfire
    if e.all or e.nodes then
        updateSwitchNodes(campfire)
    end
    if e.all or e.lighting then
        updateLightingRadius(campfire)
    end
    if e.all or e.fire then
        updateFireScale(campfire)
    end
    if e.all or e.water then
        updateWaterHeight(campfire)
    end
    if e.all or e.steam then
        updateSteamScale(campfire)
    end
    if e.all or e.collision then
        updateCollision(campfire)
    end
    campfire:updateSceneGraph()
end

event.register("Ashfall:Campfire_Update_Visuals", updateVisuals)