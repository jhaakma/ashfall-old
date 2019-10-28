local Activator = require("mer.ashfall.objects.Activator")
local activatorList = require("mer.ashfall.activators.activatorList")
local common = require ("mer.ashfall.common.common")
local foodTypes = require("mer.ashfall.camping.foodTypes")
local thirstController = require("mer.ashfall.needs.thirst.thirstController")
local hungerController = require("mer.ashfall.needs.hunger.hungerController")
local fastTime = require("mer.ashfall.camping.fastTime")
--STATIC VARS------------------------------------------------------------
local FIREWOOD_FUEL_AMOUNT = 2
local MAX_FIREWOOD = 15
local WATER_HEAT_HOT = 80
local WATER_HEAT_MAX = 100
local STEW_PROGRESS_MAX = 100
local WATER_LEVEL_MAX = common.config.capacities.cookingPot
local STEW_WARMTH_EFFECT_MIN = 10--warmth value from eating hot stew
local STEW_WARMTH_EFFECT_MAX = 15--warmth value from eating max hot stew

local CAMPFIRE_UPDATE_INTERVAL = 0.001--Rate that fuel and water levels update in game hours

--Cooking
local GRILL_TIME_MULTI = 500 --grill speed
local NUM_STEW_EATS = 4

local STEW_COOK_RATE = 40
local STEW_COOK_HEAT_MULTI = 10.0

local STEW_COOLDOWN_WATER = 50
local STEW_COOLDOWN_INGRED = 20

--Cooking pot / Kettle water heating
local WATER_HEAT_RATE = 40--base water heat/cooling speed
local FUEL_WATER_MULTI_MIN = 5--min fuel multiplier on water heating
local FUEL_WATER_MULTI_MAX = 10--max fuel multiplier on water heating

--Skills
local SKILL_STEW_DURATION_MIN = 4
local SKILL_STEW_DURATION_MAX = 16
local SKILL_STEW_EFFECT_MIN = 0.25
local SKILL_STEW_EFFECT_MAX = 1.0
local SKILL_INCREMENT_GRILLING = 10
local SKILL_INCREMENT_GRILLING_SURVIVAL = 4
local SKILL_INCREMENT_STEW_INGRED = 5
local SKILL_INCREMENT_STEW_INGRED_SURVIVAL  = 1
local SKILL_INCREMENT_LIGHT_FIRE = 5
--fuel
local FIRE_TIME_MULTI = 1.0
local RAIN_EFFECT_MULTI = 1.4
local THUNDER_EFFECT_MULTI = 1.6


local campfireID = "ashfall_campfire_01"
local firewoodID = "a_firewood"
local ID_COOKING_POT = "ashfall_cooking_pot"
local ID_GRILL = "ashfall_grill"

--register stewTemp
local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerInternalHeatSource("stewWarmEffect")

local function dataLoaded()
    common.data.stewWarmEffect = common.data.stewWarmEffect or 0
end
event.register("Ashfall:dataLoaded", dataLoaded)




------------------------------------------------------------------

--call a function on all currently loaded campfires
local function iterateCampfires(callback)
    for _, cell in pairs( tes3.getActiveCells() ) do
        for campfire in cell:iterateReferences(tes3.objectType.light) do
            if not campfire.disabled then
                local id = string.lower(campfire.object.id)
                for _, pattern in ipairs(activatorList.list.campfire.ids) do
                    if string.find(id, pattern) then
                        callback(campfire)
                        break
                    end
                end
            end
        end
    end
end

--Use cooking skill to determine how long a buff should last
local function getEffectDuration()
    local duration = math.remap(common.skills.cooking.value, 0, 100, SKILL_STEW_DURATION_MIN, SKILL_STEW_DURATION_MAX)
    return duration
end

--Use cooking skill to determine how strong a buff should be
local function getEffectStrength(value, min, max)
    --common.log.debug("value: %s, min: %s, max: %s", value, min, max)
    local effectValue = math.remap(value, 0, 100, min, max)
    local skillEffect = math.remap(common.skills.cooking.value, 0, 100, SKILL_STEW_EFFECT_MIN, SKILL_STEW_EFFECT_MAX)
    --common.log.debug("effectValue: %s, skillEffect: %s", effectValue, skillEffect)
    return effectValue * skillEffect
end


--Empty a cooking pot, reseting all data
local function clearCookingPot(campfire)
    campfire.data.stewProgress = nil
    campfire.data.stewLevels = nil
    campfire.data.waterAmount = 0
    campfire.data.waterHeat = 0
    campfire.data.waterDirty = nil
    tes3.removeSound{
        reference = campfire, 
        sound = "ashfall_boil"
    }
end

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
            campfire.data.waterHeat >= WATER_HEAT_HOT
        )
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
        local scale = math.min(math.remap(waterLevel, 0, WATER_LEVEL_MAX, 1, scaleMax), scaleMax )
        local height = math.min(math.remap(waterLevel, 0, WATER_LEVEL_MAX, 0, heightMax), heightMax)

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
        campfire.data.waterHeat >= WATER_HEAT_HOT
    
    )
    if hasSteam then
        local steamScale = math.min(math.remap(campfire.data.waterHeat, WATER_HEAT_HOT
    , WATER_HEAT_MAX, 0.5, 1.0), 1.0)
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

    --if campfire.data.destroyed then     
        --Remove collision node
        --local collisionNode = campfire.sceneNode:getObjectByName("COLLISION_BASE")
        --collisionNode.scale = 0
    --end
end

--[[
    Call all of the update functions to sync the visuals with the campfire state
]]
local function updateVisuals(campfire)
    updateSwitchNodes(campfire)
    updateLightingRadius(campfire)
    updateFireScale(campfire)
    updateWaterHeight(campfire)
    updateSteamScale(campfire)
    updateCollision(campfire)
    campfire:updateSceneGraph()
end



local function initialiseActiveCampfires()
    local function doUpdate(campfire)
        campfire.data.fuelLevel = campfire.data.fuelLevel or 0

        if campfire.data.isLit then
            tes3.removeSound{
                sound = "Fire",
                reference = campfire,
            }
            local lightNode = campfire.sceneNode:getObjectByName("AttachLight")
            lightNode.translation.z = 25
            updateVisuals(campfire)
        end
        if campfire.data.waterHeat and campfire.data.waterHeat >= WATER_HEAT_HOT then
            tes3.removeSound{
                sound = "ashfall_boil",
                reference = campfire
            }
        end

        --Add spells a frame after they have been removed
        timer.delayOneFrame(function()
            if campfire.data.isLit then
                tes3.playSound{
                    sound = "Fire",
                    reference = campfire,
                }
            end
            if campfire.data.waterHeat and campfire.data.waterHeat >= WATER_HEAT_HOT then
                tes3.playSound{
                    sound = "ashfall_boil",
                    reference = campfire
                }
            end
        end) 
    end

    iterateCampfires(doUpdate)
end

--[[
    When a save is first loaded, it may or may not trigger a cell change,
    depending on whether the previous save was in the same cell. So to ensure we
    don't initialise twice, we block the cellChange initialise from triggering on load,
    then call it a second later.
]]
local ignorePotentialLoadedCellChange
local function cellChanged()
    if not ignorePotentialLoadedCellChange then
        initialiseActiveCampfires()
    end
end
event.register("cellChanged", cellChanged)

local function loaded()
    ignorePotentialLoadedCellChange = true
    timer.start{
        type = timer.simulate,
        duration = 1,
        callback = function()
            ignorePotentialLoadedCellChange = false
        end
    }
    initialiseActiveCampfires()
end

event.register("loaded", loaded)


-- Extinguish the campfire
local function extinguish(campfire, playSound)
    if playSound == nil then playSound = true end

    tes3.removeSound{ reference = campfire, sound = "Fire" }

    --Move the light node so it doesn't cause the unlit campfire to glow
    local lightNode = campfire.sceneNode:getObjectByName("AttachLight")
    lightNode.translation.z = 0

    --Start and stop the torchout sound if necessary
    if playSound and campfire.data.isLit then
        timer.delayOneFrame(function()
            tes3.playSound{ reference = campfire, sound = "Torch Out", loop = false }
            timer.start{
                type = timer.real,
                duration = 0.4,
                iterations = 1,
                callback = function()
                    tes3.removeSound{ reference = campfire, sound = "Torch Out" }
                end
            }
        end)

    end
    campfire.data.isLit = false
    campfire.data.burned = true
end

--Calculate how much fuel is added per piece of firewood based on Survival skill
local function getWoodFuel()
    local survivalEffect = math.min( math.remap(common.skills.survival.value, 0, 100, 1, 1.5), 1.5)
    return FIREWOOD_FUEL_AMOUNT * survivalEffect
end

--[[
    Menu buttons
    requirements: campfire state required for button to appear
]]
local menuButtons = {

    addFirewood = {
        text = "Add Firewood",
        requirements = function(campfire)
            common.log.debug("Add firewood: ")
            common.log.debug("fuelLevel = %s", campfire.data.fuelLevel )
            common.log.debug("firewood count: %s", mwscript.getItemCount{ reference = tes3.player, item = firewoodID } )
            return (
                mwscript.getItemCount{ reference = tes3.player, item = firewoodID } > 0 and
                ( campfire.data.fuelLevel < MAX_FIREWOOD or campfire.data.burned == true )
            )
        end,
        callback = function(campfire)
            tes3.playSound{ reference = tes3.player, sound = "ashfall_add_wood"  }
            campfire.data.fuelLevel = campfire.data.fuelLevel + getWoodFuel()
            campfire.data.burned = false
            mwscript.removeItem{ reference = tes3.player, item = firewoodID }
            updateVisuals(campfire)
        end,
    },

    lightFire = {
        text = "Light Fire",
        requirements = function(campfire)
            return (
                not campfire.data.isLit and
                campfire.data.fuelLevel and
                campfire.data.fuelLevel > 0.5
            )
        end,
        callback = function(campfire)
            tes3.playSound{ reference = tes3.player, sound = "ashfall_light_fire"  }
            tes3.playSound{ sound = "Fire", reference = campfire, loop = true }
            local lightNode = campfire.sceneNode:getObjectByName("AttachLight")
            lightNode.translation.z = 25
            campfire.data.fuelLevel = campfire.data.fuelLevel - 0.5
            common.skills.survival:progressSkill( SKILL_INCREMENT_LIGHT_FIRE)
            campfire.data.isLit = true
            updateVisuals(campfire)
        end,
    },
    extinguish = {
        text = "Extinguish",
        requirements = function(campfire)
            return campfire.data.isLit
        end,
        callback = function(campfire)
            extinguish(campfire)
            updateVisuals(campfire)
        end,
    },
    addSupports = {
        text = "Add Supports (requires 3 wood)",
        requirements = function(campfire)
            local numWood = mwscript.getItemCount{ reference = tes3.player, item = "a_firewood"}
            return not campfire.data.hasSupports and numWood >= 3
        end,
        callback = function(campfire)
            mwscript.removeItem{
                reference = tes3.player, 
                item = "a_firewood",
                count = 3
            }
            campfire.data.hasSupports = true
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
            updateVisuals(campfire)
        end
        ,
    },
    removeSupports = {
        text = "Remove Supports",
        requirements = function(campfire)
            return campfire.data.hasSupports and not campfire.data.hasUtensil
        end,
        callback = function(campfire)
            mwscript.addItem{
                reference = tes3.player, 
                item = "a_firewood",
                count = 3
            }
            campfire.data.hasSupports = false
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
            updateVisuals(campfire)
        end
    },
    addGrill = {
        text = "Add Grill",
        requirements = function(campfire)
            return ( 
                not campfire.data.hasGrill and
                mwscript.getItemCount{ reference = tes3.player, item = ID_GRILL } > 0
            )
        end,
        callback = function(campfire)
            mwscript.removeItem{
                reference = tes3.player, 
                item = "ashfall_grill",
                count = 1
            }
            campfire.data.hasGrill = true
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
            updateVisuals(campfire)
        end
        ,
    },
    removeGrill = {
        text = "Remove Grill",
        requirements = function(campfire)
            return ( 
                campfire.data.hasGrill
            )
        end,
        callback = function(campfire)
            mwscript.addItem{
                reference = tes3.player, 
                item = "ashfall_grill",
                count = 1
            }
            campfire.data.hasGrill = false
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
            updateVisuals(campfire)
        end
        ,
    },
    addKettle = {
        text = "Attach Kettle",
        requirements = function(campfire)
            return (
                campfire.data.hasSupports and 
                not campfire.data.hasUtensil and
                mwscript.getItemCount{ reference = tes3.player, item = "ashfall_kettle"} > 0
            )
        end,
        callback = function(campfire)
            mwscript.removeItem{ reference = tes3.player, item = "ashfall_kettle" }
            campfire.data.hasKettle = true
            campfire.data.hasUtensil = true
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Down"  }
            updateVisuals(campfire)
        end
    },
    removeKettle = {
        text = "Remove Kettle",
        requirements = function(campfire)
            return (
                campfire.data.hasKettle
            )
        end,
        callback = function(campfire)
            mwscript.addItem{ reference = tes3.player, item = "ashfall_kettle" }
            campfire.data.hasKettle = false
            campfire.data.hasUtensil = false
            campfire.data.waterAmount = nil
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
            updateVisuals(campfire)
        end
    },
    addWater = {
        text = "Add water",
        requirements = function(campfire)
            local needsWater = (
                not campfire.data.waterAmount or
                campfire.data.waterAmount < WATER_LEVEL_MAX
            )
            local hasUtensil = (
                campfire.data.hasUtensil
            )
            return needsWater and hasUtensil
        end,
        callback = function(campfire)
            timer.delayOneFrame(function()
                tes3ui.showInventorySelectMenu{
                    title = "Select Water Container:",
                    noResultsText = "You do not have any water.",
                    filter = function(e)
                        return (
                            e.itemData and 
                            e.itemData.data.waterAmount and 
                            e.itemData.data.waterAmount > 0
                        ) == true
                    end,
                    callback = function(e)
                        if e.item then
                            local maxAmount = math.min(
                                ( e.itemData.data.waterAmount or 0 ),
                                ( WATER_LEVEL_MAX - ( campfire.data.waterAmount or 0 ))
                            )
                            local t = { amount = maxAmount}
                            local function transferWater()
                                --transfer water
                                campfire.data.waterAmount = campfire.data.waterAmount or 0
                                local waterBefore = campfire.data.waterAmount
                                local waterTransferred = t.amount
                                common.log.debug("waterTransferred %s", waterTransferred)
                                e.itemData.data.waterAmount = e.itemData.data.waterAmount - waterTransferred

                                campfire.data.waterAmount = campfire.data.waterAmount + waterTransferred
                                local waterAfter = campfire.data.waterAmount
                                tes3ui.updateInventoryTiles()

                                --If dirty
                                if e.itemData.data.waterDirty then
                                    campfire.data.waterDirty = true
                                end
                                if e.itemData.data.waterAmount == 0 then
                                    e.itemData.data.waterDirty = nil
                                end

                                local ratio = waterBefore / waterAfter
                                --reduce ingredient levels
                                if campfire.data.stewLevels then
                                    for name, stewLevel in pairs( campfire.data.stewLevels) do
                                        campfire.data.stewLevels[name] = stewLevel * ratio
                                    end
                                end

                                --Cool down stew
                                campfire.data.waterHeat = campfire.data.waterHeat or 0
                                local before = campfire.data.waterHeat
                                campfire.data.waterHeat = math.max(( campfire.data.waterHeat - STEW_COOLDOWN_WATER * ratio ), 0)
                                local after = campfire.data.waterHeat
                                if before > WATER_HEAT_HOT and after < WATER_HEAT_HOT then
                                    tes3.removeSound{
                                        reference = campfire, 
                                        sound = "ashfall_boil"
                                    }
                                end

                                tes3.playSound{ reference = tes3.player, sound = "Swim Right" }
                                updateVisuals(campfire)
                            end
                            common.helper.createSliderPopup{
                                label = "Add water",
                                min = 0,
                                max = maxAmount,
                                varId = "amount",
                                table = t,
                                okayCallback = transferWater
                            }

                        end
                    end
                }
            end)

        end
    },
    addIngredient = {
        text = "Add Ingredient",
        requirements = function(campfire)
            return (
                campfire.data.hasCookingPot and
                campfire.data.waterAmount and
                campfire.data.waterAmount > 0
                --campfire.data.waterHeat and 
                --campfire.data.waterHeat > WATER_HEAT_HOT and
            )
        end,
        callback = function(campfire)
            local function ingredientSelect(foodType)
                timer.delayOneFrame(function()
                    tes3ui.showInventorySelectMenu{
                        title = "Select Ingredient:",
                        noResultsText = string.format("You do not have any %ss.", string.lower(foodType)),
                        filter = function(e)
                            return (
                                e.item.objectType == tes3.objectType.ingredient and
                                foodTypes.ingredTypes[e.item.id] == foodType
                                --Can only grill meat and veges
                            )
                        end,
                        callback = function(e)
                            if e.item then
                                --Cool down stew
                                campfire.data.stewProgress = campfire.data.stewProgress or 0
                                campfire.data.stewProgress = math.max(( campfire.data.stewProgress - STEW_COOLDOWN_INGRED ), 0)

                                --initialise stew levels
                                campfire.data.stewLevels = campfire.data.stewLevels or {}
                                campfire.data.stewLevels[foodType] = campfire.data.stewLevels[foodType] or 0

                                --Add ingredient to stew
                                campfire.data.stewLevels[foodType] = (
                                    campfire.data.stewLevels[foodType] +
                                    (
                                        (
                                            WATER_LEVEL_MAX / campfire.data.waterAmount
                                        ) / NUM_STEW_EATS
                                    ) * 100
                                )

                                common.skills.cooking:progressSkill(SKILL_INCREMENT_STEW_INGRED)
                                common.skills.survival:progressSkill(SKILL_INCREMENT_STEW_INGRED_SURVIVAL)


                                tes3.player.object.inventory:removeItem{
                                    mobile = tes3.mobilePlayer,
                                    item = e.item,
                                    itemData = e.itemData
                                }
                                tes3ui.forcePlayerInventoryUpdate()
                                --mwscript.removeItem{ reference = tes3.player, item = e.item }
                                tes3.playSound{ reference = tes3.player, sound = "Swim Right" }
                                updateVisuals(campfire)
                            end
                        end
                    }
                end)
            end
            local ingredButtons = {
                { text = foodTypes.TYPE.protein, callback = function() ingredientSelect(foodTypes.TYPE.protein) end },
                { text = foodTypes.TYPE.vegetable, callback = function() ingredientSelect(foodTypes.TYPE.vegetable) end },
                { text = foodTypes.TYPE.mushroom, callback = function() ingredientSelect(foodTypes.TYPE.mushroom) end },
                { text = foodTypes.TYPE.seasoning, callback = function() ingredientSelect(foodTypes.TYPE.seasoning) end },
                { text = foodTypes.TYPE.herb, callback = function() ingredientSelect(foodTypes.TYPE.herb) end },

            }
            local buttons = {}
            --add buttons for ingredients that can be added
            for _, button in ipairs(ingredButtons) do
                local foodType = button.text
                local canAdd = (
                    not campfire.data.stewLevels or
                    not campfire.data.stewLevels[foodType] or 
                    campfire.data.stewLevels[foodType] < 100
                )
                if canAdd then
                    table.insert(buttons, button)
                end
            end

            table.insert(buttons, { text = tes3.findGMST(tes3.gmst.sCancel).value })

            common.helper.messageBox({
                message = "Select Ingredient Type:",
                buttons = buttons
            })

        end
    },
    addPot = {
        text = "Attach Cooking Pot",
        requirements = function(campfire)
            return (
                campfire.data.hasSupports and 
                not campfire.data.hasUtensil and
                mwscript.getItemCount{ reference = tes3.player, item = ID_COOKING_POT} > 0
            )
        end,
        callback = function(campfire)
            mwscript.removeItem{ reference = tes3.player, item = ID_COOKING_POT }
            campfire.data.hasCookingPot = true
            campfire.data.hasUtensil = true
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Down"  }
            updateVisuals(campfire)
        end
    },
    removePot = {
        text = "Remove Pot",
        requirements = function(campfire)
            return (
                campfire.data.hasCookingPot and
                ( not campfire.data.waterAmount or
                campfire.data.waterAmount == 0 )
            )
        end,
        callback = function(campfire)
            mwscript.addItem{ reference = tes3.player, item = ID_COOKING_POT }
            clearCookingPot(campfire)
            campfire.data.hasCookingPot = false
            campfire.data.hasUtensil = false
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
            updateVisuals(campfire)
        end
    },
    emptyPot = {
        text = "Empty Pot",
        requirements = function(campfire)
            return (
                campfire.data.hasCookingPot and
                ( campfire.data.waterAmount and
                campfire.data.waterAmount > 0 )
            )
        end,
        callback = function(campfire)
            clearCookingPot(campfire)
            tes3.playSound{ reference = tes3.player, pitch = 0.8, sound = "Swim Left" }
            updateVisuals(campfire)
        end
    },
    eatStew = {
        text = "Eat Stew",
        requirements = function(campfire)
            return (
                campfire.data.stewLevels and 
                campfire.data.stewProgress and
                campfire.data.stewProgress == STEW_PROGRESS_MAX and
                common.data.hunger and 
                common.data.hunger > 0.01
            )
        end,
        callback = function(campfire)

            --remove old sbuffs
            for name, buff in pairs(foodTypes.stewBuffs) do
                if campfire.data.stewLevels[name] == nil then
                    mwscript.removeSpell{ reference = tes3.player, spell = buff.id }
                end
            end

            --Add buffs and set duration
            for name, ingredLevel in pairs(campfire.data.stewLevels) do
                --add spell
                local stewBuff = foodTypes.stewBuffs[name]
                local effectStrength = getEffectStrength(math.min(ingredLevel, 100), stewBuff.min, stewBuff.max)
                timer.delayOneFrame(function()
                    local spell = tes3.getObject(stewBuff.id)
                    local effect = spell.effects[1]
                    effect.min = effectStrength
                    effect.max = effectStrength
                    mwscript.addSpell{ reference = tes3.player, spell = spell }
                    common.data.stewBuffTimeLeft = getEffectDuration()
                end)
            end

            --add up ingredients, mulitplying nutrition by % in the pot
            local nutritionLevel = 0
            local maxNutritionLevel = 0
            for type, _ in pairs(foodTypes.stewBuffs) do
                nutritionLevel = nutritionLevel + ( foodTypes.nutrition[type] * ( campfire.data.stewLevels[type] or 0 ) / 100 )
                maxNutritionLevel = nutritionLevel + foodTypes.nutrition[type]
            end
            local foodRatio = nutritionLevel / maxNutritionLevel
            
            local highestNeed = math.max(common.data.hunger / foodRatio, common.data.thirst)
            local maxDrinkAmount = math.min(campfire.data.waterAmount, (WATER_LEVEL_MAX / NUM_STEW_EATS), highestNeed )

            local amountAte = hungerController.eatAmount(maxDrinkAmount * foodRatio)
            local amountDrank = thirstController.drinkAmount(maxDrinkAmount, campfire.data.waterDirty)
            

            if amountAte >= 1 or amountDrank >= 1 then
                tes3.playSound{ reference = tes3.player, sound = "Swallow" }
                campfire.data.waterAmount = math.max( (campfire.data.waterAmount - amountDrank), 0)
                
                if campfire.data.waterHeat >= WATER_HEAT_HOT then
                    common.data.stewWarmEffect = math.remap(campfire.data.waterHeat, WATER_HEAT_HOT, WATER_HEAT_MAX, STEW_WARMTH_EFFECT_MIN, STEW_WARMTH_EFFECT_MAX)
                end

                if campfire.data.waterAmount == 0 then
                    clearCookingPot(campfire)
                end
                updateVisuals(campfire)
            else
                tes3.messageBox("You are full.")
            end
            

            
        end
    },
    drink = {
        text = "Drink",
        requirements = function(campfire)
            return (
                campfire.data.waterAmount and 
                campfire.data.waterAmount > 0 and
                not campfire.data.stewLevels
            )
        end,
        callback = function(campfire)
            local function doDrink()
                --tes3.playSound{ reference = tes3.player, sound = "Swallow" }
                local amountToDrink = math.min(WATER_LEVEL_MAX / NUM_STEW_EATS, campfire.data.waterAmount)
                local amountDrank = thirstController.drinkAmount(amountToDrink, campfire.data.waterDirty)
                campfire.data.waterAmount = campfire.data.waterAmount - amountDrank
                if campfire.data.waterAmount == 0 then
                    clearCookingPot(campfire)
                end
                updateVisuals(campfire)
            end


            if campfire.data.waterDirty then
                common.helper.messageBox{
                    message = "This water is dirty.",
                    buttons = {
                        { 
                            text = "Drink", 
                            callback = function() doDrink() end 
                        },
                        { 
                            text = "Empty Cooking Pot", 
                            callback = function()
                                tes3.playSound{ reference = tes3.player, pitch = 0.8, sound = "Swim Left"} 
                                clearCookingPot(campfire)
                                updateVisuals(campfire)
                            end
                        },
                        { text = tes3.findGMST(tes3.gmst.sCancel).value }
                    }
                }
            else
                doDrink()
            end
        end
    },
    fillContainer = {
        text = "Fill Container",
        requirements = function(campfire)
            return (
                campfire.data.waterAmount and 
                campfire.data.waterAmount > 0 and
                not campfire.data.stewLevels
            )
        end,
        callback = function(campfire)
            --fill bottle
            thirstController.fillContainer(
                campfire.data,
                function()
                    if campfire.data.waterAmount == 0 then
                        clearCookingPot(campfire)
                    end
                end
            )

        end
    },
    wait = {
        text = tes3.findGMST(tes3.gmst.sWait).value,
        requirements = function()
            return true
        end,
        callback = function()
            fastTime.showFastTimeMenu()
        end,
    },
    destroy = {
        text = "Destroy Campfire",
        requirements = function(campfire)
            return (
                not campfire.data.hasGrill and 
                not campfire.data.hasCookingPot and
                not campfire.data.isLit
            )
        end,
        callback = function(campfire)
            campfire.data.destroyed = true
            local recoveredFuel =  math.floor(campfire.data.fuelLevel / 2)
            if campfire.data.hasSupports then
                recoveredFuel = recoveredFuel + 3
            end
            if not campfire.data.isLit and recoveredFuel >= 1 then
                mwscript.addItem{
                    reference = tes3.player, 
                    item = "a_firewood",
                    count = recoveredFuel
                }
                tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
                tes3.messageBox(tes3.findGMST(tes3.gmst.sNotifyMessage61).value, recoveredFuel, tes3.getObject("a_firewood").name)
            end

            extinguish(campfire)
            updateVisuals(campfire)
            tes3.setEnabled({
                reference = campfire,
                enabled = false
            })
            --[[timer.delayOneFrame(function()
                mwscript.setDelete{
                    reference = campfire
                }
            end)]]
        end
    },
    cancel = {
        text = tes3.findGMST(tes3.gmst.sCancel).value,
        requirements = function()
            return true
        end,
        callback = function() return true end,
    }
}

--[[
    Mapping of which buttons can appear for each part of the campfire selected
]]
local buttonMapping = {
    ["Grill"] = {
        menuButtons.removeGrill,
        menuButtons.cancel
    },
    ["Cooking Pot"] = {
        menuButtons.drink,
        menuButtons.addWater,
        menuButtons.fillContainer,
        menuButtons.eatStew,
        menuButtons.addIngredient,
        menuButtons.emptyPot,
        menuButtons.removePot,
        menuButtons.cancel,
    },
    ["Kettle"] = {
        menuButtons.drink,
        menuButtons.addWater,
        menuButtons.fillContainer,
        menuButtons.removeKettle,
        menuButtons.cancel,
    },
    ["Supports"] = {
        menuButtons.addKettle,
        menuButtons.addPot,
        menuButtons.removeKettle,
        menuButtons.removePot,
        menuButtons.removeSupports,
        menuButtons.cancel,
    },
    ["Campfire"] = {
        menuButtons.addFirewood,
        menuButtons.lightFire,
        menuButtons.addSupports,
        menuButtons.removeSupports,
        menuButtons.addGrill,
        menuButtons.removeGrill,
        menuButtons.addKettle,
        menuButtons.addPot,
        menuButtons.removeKettle,
        menuButtons.removePot,
        menuButtons.wait,
        menuButtons.extinguish,
        menuButtons.destroy,
        menuButtons.cancel
    }
}

local function onActivateCampfire(e)

    local campfire = e.ref
    local node = e.node

    local addButton = function(tbl, button)
        if button.requirements(campfire) then
            table.insert(tbl, {
                text = button.text, 
                callback = function()
                    button.callback(campfire)
                end
            })
        end
    end

    local buttons = {}
    --Add contextual buttons
    local buttonList = buttonMapping.Campfire
    local text = "Campfire"
    --If looking at an attachment, show buttons for it instead
    if buttonMapping[node.name] then
        buttonList = buttonMapping[node.name]
        text = node.name
    end

    for _, button in ipairs(buttonList) do
        addButton(buttons, button)
    end
    common.helper.messageBox({ message = text, buttons = buttons })
end

event.register(
    "Ashfall:ActivatorActivated", 
    onActivateCampfire, 
    { filter = Activator.types.campfire } 
)

----------------------
--FIREWOOD
----------------------
local function placeCampfire(e)

    
    mwscript.disable({ reference = e.target })

    local newRef = tes3.createReference{
        object = campfireID,
        position = e.target.position,
        orientation = e.target.orientation,
    }
    newRef.data.fuelLevel = e.target.stackSize
    updateVisuals(newRef)
    
    --[[timer.start({
        type = timer.real,
        duration = 0.5,
        callback = function()
            mwscript.drop({reference = tes3.player, item = "a__lightreset"})
        end
    })]]

end

local simulateCheck
local skipActivate
local function onActivateFirewood(e)
    if skipActivate then return end
    if tes3.menuMode() then return end

    local function pickupFirewood(ref)
        simulateCheck = true
        timer.delayOneFrame(function()
            simulateCheck = false
            skipActivate = true
            tes3.player:activate(ref)
            skipActivate = false
        end)
    end

    if string.lower(e.target.object.id) == firewoodID then
        local cell =tes3.getPlayerCell()
        if cell.restingIsIllegal or cell.isInterior then
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

local function checkSimulate()
    if simulateCheck then
        common.log.debug("A simulation frame went by in a delayOneFrame")
    end
end
event.register("simulate", checkSimulate)

-----------------------------
--UPDATE CAMPFIRES
-------------------------------
local function updateCampfireValues(e)
    local function doUpdate(campfire)
        campfire.data.lastFireUpdated = campfire.data.lastFireUpdated or e.timestamp
        campfire.data.lastWaterUpdated = campfire.data.lastWaterUpdated or e.timestamp

        local difference = e.timestamp - campfire.data.lastFireUpdated
        if difference > CAMPFIRE_UPDATE_INTERVAL then
            --------
            --FUEL--
            --------
            if campfire.data.isLit then
                campfire.data.lastFireUpdated = e.timestamp

                local rainEffect = 1.0
                --raining and campfire exposed
                if tes3.getCurrentWeather().index == tes3.weather.rain then
                    if not common.helper.checkRefSheltered(campfire) then
                        rainEffect = RAIN_EFFECT_MULTI
                    end
                --thunder and campfire exposed
                elseif tes3.getCurrentWeather().index == tes3.weather.thunder then
                    if not common.helper.checkRefSheltered(campfire) then
                        rainEffect = THUNDER_EFFECT_MULTI
                    end
                end

                campfire.data.fuelLevel = campfire.data.fuelLevel - ( difference * FIRE_TIME_MULTI * rainEffect )
                if campfire.data.fuelLevel <= 0 then
                    campfire.data.fuelLevel = 0
                    local playSound = difference < 0.01
                    extinguish(campfire, playSound)
                    updateVisuals(campfire)
                end

            else
                campfire.data.lastFireUpdated = nil
            end
        end
        ---------------
        --Utensil--
        ---------------
        difference = e.timestamp - campfire.data.lastWaterUpdated
        if difference > CAMPFIRE_UPDATE_INTERVAL then
            local hasFilledPot = (
                campfire.data.hasUtensil and 
                campfire.data.waterAmount and 
                campfire.data.waterAmount > 0
            )
            if hasFilledPot then
                campfire.data.waterHeat = campfire.data.waterHeat or 0
                campfire.data.lastWaterUpdated = e.timestamp
                local heatEffect = -1--negative if cooling down
                if campfire.data.isLit then--based on fuel if heating up
                    heatEffect = math.remap(campfire.data.fuelLevel, 0, MAX_FIREWOOD, FUEL_WATER_MULTI_MIN, FUEL_WATER_MULTI_MAX)
                end
                local heatBefore = campfire.data.waterHeat
                campfire.data.waterHeat = math.clamp((campfire.data.waterHeat + ( difference * WATER_HEAT_RATE * heatEffect )), 0, WATER_HEAT_MAX)
                local heatAfter = campfire.data.waterHeat

                --add boiling sound
                if heatBefore < WATER_HEAT_HOT and heatAfter > WATER_HEAT_HOT then
                    tes3.playSound{
                        reference = campfire, 
                        sound = "ashfall_boil"
                    }
                end
                --remove boiling sound
                if heatBefore > WATER_HEAT_HOT and heatAfter < WATER_HEAT_HOT then
                    tes3.removeSound{
                        reference = campfire, 
                        sound = "ashfall_boil"
                    }
                end

                --Cook the stew
                if campfire.data.stewLevels then
                    if campfire.data.waterHeat >= WATER_HEAT_HOT then
                        campfire.data.stewProgress = campfire.data.stewProgress or 0
                        local waterHeatEffect = math.remap(campfire.data.waterHeat, WATER_HEAT_HOT, WATER_HEAT_MAX, 1, STEW_COOK_HEAT_MULTI)
                        --common.log.debug("waterHeatEffect: %s", waterHeatEffect)
                        campfire.data.stewProgress = math.clamp((campfire.data.stewProgress + ( difference * STEW_COOK_RATE * waterHeatEffect )), 0, STEW_PROGRESS_MAX)
                    end
                end

                if campfire.data.waterHeat > WATER_HEAT_HOT then
                    campfire.data.waterDirty = nil
                end
            else
                campfire.data.lastWaterUpdated = nil
            end
            
        end
        updateVisuals(campfire)
    end
    iterateCampfires(doUpdate)
    
end

event.register("simulate", updateCampfireValues)

-------------------------------------------------------
--COOKING----------------------------------------------
-------------------------------------------------------

----------------------------
--Grilling
-----------------------------

--Checks if the ingredient has been placed on a campfire
local function findCampfireForCooking(ingredient, cookingType)
    local distance
    local minHeight
    local maxHeight
    if cookingType == "grilling" then
        minHeight = 21
        maxHeight = 35
        distance = 40
    elseif cookingType == "boiling" then
        minHeight = 50
        maxHeight = 500
        distance = 500
    else
        common.log.error("findCampfireForCooking: invalid cooking type")
        return
    end
    local campfire
    local function checkDistance(ref)
        --food sitting on grill
        local heightDistance = ingredient.position.z - ref.position.z
        if heightDistance < maxHeight and heightDistance > minHeight then
            
            local thisDistance = ingredient.position:distance(ref.position)
            if thisDistance < distance then
                distance = thisDistance
                campfire = ref
            end
        end
    end
    iterateCampfires(checkDistance)
    return campfire
end

--update any food that is currently grilling
local function grillFood(e)
    for _, cell in pairs( tes3.getActiveCells() ) do
        for ingredient in cell:iterateReferences(tes3.objectType.ingredient) do
            local foodType = foodTypes.ingredTypes[ingredient.object.id]
            --Can only grill meat and veges
            if foodType == foodTypes.TYPE.protein or foodType == foodTypes.TYPE.vegetable then

                local campfire = findCampfireForCooking(ingredient, "grilling")
                if campfire then
                    if campfire.data.hasGrill and campfire.data.isLit then
                        ingredient.data.lastCookUpdated = ingredient.data.lastCookUpdated or e.timestamp
                        ingredient.data.cookedAmount = ingredient.data.cookedAmount or 0

                        local difference = e.timestamp - ingredient.data.lastCookUpdated
                        if difference > 0.008 then
                            ingredient.data.lastCookUpdated = e.timestamp
                            local before = ingredient.data.cookedAmount

                            local thisCookMulti = (
                                GRILL_TIME_MULTI * 
                                math.min(math.remap(campfire.data.fuelLevel, 0, 10, 0.5, 1.5), 1.5)
                            )


                            ingredient.data.cookedAmount = ingredient.data.cookedAmount + ( difference * thisCookMulti )
                            local after = ingredient.data.cookedAmount

                            

                            --Only play sounds/messages if not transitioning from cell
                            if difference < 0.01 then
                                --Cooked your food
                                if before < 100 and after > 100 then
                                    tes3.messageBox("%s is fully cooked.", ingredient.object.name)
                                    tes3.playSound{ sound = "potion fail", pitch = 0.7, reference = e.reference }
                                    common.skills.cooking:progressSkill(SKILL_INCREMENT_GRILLING)
                                    common.skills.survival:progressSkill(SKILL_INCREMENT_GRILLING_SURVIVAL)
                                end
                                --burned your food
                                local burnLevel = hungerController.getBurnLimit()
                                if before < burnLevel and after > burnLevel then
                                    tes3.messageBox("%s has become burnt.", ingredient.object.name)
                                    tes3.playSound{ sound = "potion fail", pitch = 0.9, reference = e.reference }
                                end
                            end
                            if tes3ui.findHelpLayerMenu(tes3ui.registerID("HelpMenu")).visible == true then
                                tes3ui.refreshTooltip()
                            end
                        end
                    else
                        --reset grill time if campfire is unlit
                        ingredient.data.lastCookUpdated = nil
                    end
                end
            end
        end
    end
end

event.register("simulate", grillFood)

--Reset grill time when item is placed
local function ingredientPlaced(e)
    if e.reference and e.reference.object then
        local foodType = foodTypes.ingredTypes[e.reference.object.id]
        if foodType == foodTypes.TYPE.protein or foodType == foodTypes.TYPE.vegetable then
                --Reset grill time for meat and veges
            timer.frame.delayOneFrame(function()
                local ingredient = e.reference
                local campfire = findCampfireForCooking(ingredient, "grilling")
                if campfire and campfire.data.hasGrill and campfire.data.isLit then
                    local count = ingredient.attachments.variables and ingredient.attachments.variables.count or 1
                    if count > 1 then
                        mwscript.addItem{ reference = tes3.player, item = ingredient.object, count = (count - 1) }
                        ingredient.attachments.variables.count = 1
                    end

                    ingredient.data.lastCookUpdated = e.timestamp
                    tes3.messageBox("%s begins to cook.", ingredient.object.name)
                    tes3.playSound{ sound = "potion fail", pitch = 0.8, reference = ingredient }
                end
            end)
        end
    end
    grillFood({ timestamp = tes3.getSimulationTimestamp() })
end
event.register("referenceSceneNodeCreated" , ingredientPlaced)


--Update Stew buffs
local function updateBuffs(e)
    if common.data.stewBuffTimeLeft and common.data.stewBuffTimeLeft > 0 then

        common.data.lastStewBuffUpdated = common.data.lastStewBuffUpdated or e.timestamp

        local interval = e.timestamp - common.data.lastStewBuffUpdated
        common.data.stewBuffTimeLeft = math.max((common.data.stewBuffTimeLeft - interval), 0)
        --time's up, remove spells and heat
        if common.data.stewBuffTimeLeft == 0 then

            common.data.stewWarmEffect = 0 

            for _, stewBuff in pairs(foodTypes.stewBuffs) do
                mwscript.removeSpell({ reference = tes3.player, spell = stewBuff.id})
            end

            common.helper.restoreFatigue()
        end
    end

    common.data.lastStewBuffUpdated = e.timestamp
end

event.register("simulate", updateBuffs)

------------------
--Tooltips
-----------------
local function updateTooltip(e)
    local function centerText(element)
        element.autoHeight = true
        element.autoWidth = true
        element.wrapText = true
        element.justifyText = "center" 
    end
    local label = e.label
    local labelBorder = e.labelBorder
    local campfire = e.campfire
    local parentNode = e.parentNode

    --Do some fancy campfire stuff
    local attachments = {
        "Grill",
        "Kettle",
        "Cooking Pot",
        "Supports",
    }
    local attachment = parentNode.name
    if table.find(attachments, attachment) then
        label.text = attachment
    end

    --Add special fields
    if label.text == "Campfire" then
        local fuelLevel = ( campfire.data.fuelLevel or 0 )
        if fuelLevel and fuelLevel > 0 then
            local fuelLabel = labelBorder:createLabel{
                text = string.format("Fuel: %.1f hours", fuelLevel )
            }
            centerText(fuelLabel)
        end
    elseif label.text == "Kettle" or label.text == "Cooking Pot" then
        local waterAmount = campfire.data.waterAmount
        if waterAmount then
            --WATER
            local waterHeat = campfire.data.waterHeat or 0
            local waterLabel = labelBorder:createLabel{
                text = string.format(
                    "Water: %d/%d %s| Heat: %d/100", 
                    math.ceil(waterAmount), 
                    common.config.capacities.cookingPot, 
                    ( campfire.data.waterDirty and "(Dirty) " or ""),
                    waterHeat)
            }
            centerText(waterLabel)

            if campfire.data.stewLevels then

                labelBorder:createDivider()

                local progress = ( campfire.data.stewProgress or 0 ) / STEW_PROGRESS_MAX * 100
                local progressText

                if campfire.data.waterHeat < WATER_HEAT_HOT then
                    progressText = "Stew (Cold)"
                elseif progress < 100 then
                    progressText = string.format("Stew (%d%% Cooked)", progress ) 
                else 
                    progressText = "Stew (Cooked)"
                end
                local stewProgressLabel = labelBorder:createLabel({ text = progressText })
                stewProgressLabel.color = tes3ui.getPalette("header_color")
                centerText(stewProgressLabel)

                
                for name, ingredLevel in pairs(campfire.data.stewLevels) do
                    local value = math.min(ingredLevel, 100)
                    local stewBuff = foodTypes.stewBuffs[name]
                    local spell = tes3.getObject(stewBuff.id)
                    local effect = spell.effects[1]

                    local ingredText = string.format("(%d%% %s)", value, name )
                    local ingredLabel

                    if progress >= 100 then
                        local block = labelBorder:createBlock{}
                        block.autoHeight = true
                        block.autoWidth = true
                        block.childAlignX = 0.5

                        
                        local image = block:createImage{path=("icons\\" .. effect.object.icon)}
                        image.wrapText = false
                        image.borderLeft = 4

                        --"Fortify Health"
                        local statName
                        if effect.attribute ~= -1 then
                            local stat = effect.attribute
                            statName = tes3.findGMST(888 + stat).value
                        elseif effect.skill ~= -1 then
                            local stat = effect.skill
                            statName = tes3.findGMST(896 + stat).value
                        end
                        local effectNameText
                        local effectName = tes3.findGMST(1283 + effect.id).value
                        if statName then
                            effectNameText = effectName:match("%S+") .. " " .. statName
                        else
                            effectNameText = effectName
                        end
                        --points " 25 points "
                        local pointsText = string.format("%d pts", getEffectStrength(value, stewBuff.min, stewBuff.max) )
                        --for X hours
                        local duration = getEffectDuration()
                        local hoursText = string.format("for %d hour%s", duration, (duration >= 2 and "s" or "") )

                        ingredLabel = block:createLabel{text = string.format("%s %s: %s %s %s", spell.name, ingredText, effectNameText, pointsText, hoursText) }
                        ingredLabel.wrapText = false
                        ingredLabel.borderLeft = 4
                    else
                        ingredLabel = labelBorder:createLabel{text = ingredText }
                        centerText(ingredLabel)
                    end
                end
            end
        end
    end
end

event.register("Ashfall:CampfireTooltip", updateTooltip)