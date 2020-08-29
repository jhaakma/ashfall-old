--[[
    campfire.lua

    This monster of a script handles all the logic around campfires. This includes:
    - Placing down firewood and lighting it
    - Updating switch nodes for each campfire state
    - Producing heat, using fuel, etc
    - Cooking food on grills and in cooking pots

]]

local common = require ("mer.ashfall.common.common")
local thirstController = require("mer.ashfall.needs.thirstController")

--STATIC VARS------------------------------------------------------------
local cfConfigs = {
    maxWoodInFire = 15,
    maxWaterLevel = common.staticConfigs.capacities.cookingPot,

    campfireUpdateInterval = 0.001,--Rate that fuel and water levels update in game hours
    --cooking
    stewMealCapacity = 4, --how many "meals" a stew can fit. At 4, you eat a max of 1 quarter of the stew each time
    stewCookRate = 40,
}



--Cooking pot / Kettle water heating
local waterHeatRate = 40--base water heat/cooling speed
local minFuelWaterHeat = 5--min fuel multiplier on water heating
local maxFuelWaterHeat = 10--max fuel multiplier on water heating

--Skills

--fuel
local fuelDecay = 1.0
local fuelDecayRainEffect = 1.4
local fuelDecayThunderEffect = 1.6




local function dataLoaded()
    common.data.stewWarmEffect = common.data.stewWarmEffect and common.data.stewWarmEffect or 0
end
event.register("Ashfall:dataLoaded", dataLoaded)


local function firstDataLoaded()
    --register stewTemp
    local temperatureController = require("mer.ashfall.temperatureController")
    temperatureController.registerInternalHeatSource("stewWarmEffect")
end
event.register("Ashfall:dataLoadedOnce", firstDataLoaded)



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
            event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
        end
        if campfire.data.waterHeat and campfire.data.waterHeat >= common.staticConfigs.hotWaterHeatValue then
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
            if campfire.data.waterHeat and campfire.data.waterHeat >= common.staticConfigs.hotWaterHeatValue then
                tes3.playSound{
                    sound = "ashfall_boil",
                    reference = campfire
                }
            end
        end) 
    end

    common.helper.iterateCampfires(doUpdate)
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


--Empty a cooking pot, reseting all data
local function clearCookingPot(e)
    local campfire = e.campfire
    campfire.data.stewProgress = nil
    campfire.data.stewLevels = nil
    campfire.data.waterAmount = 0
    campfire.data.waterHeat = 0
    campfire.data.waterDirty = nil
    tes3.removeSound{
        reference = campfire, 
        sound = "ashfall_boil"
    }
    event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
end
event.register("Ashfall:Campfire_clear_pot", clearCookingPot)

-- Extinguish the campfire
local function extinguish(e)
    local campfire = e.campfire
    local playSound = e.playSound ~= nil and e.playSound or true

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
    event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
end
event.register("Ashfall:Campfire_Extinguish", extinguish)


--[[
    Menu buttons
    requirements: campfire state required for button to appear
]]
local menuButtons = {
    addFirewood = require("mer.ashfall.camping.menuFunctions.addFirewood"),
    lightFire = require("mer.ashfall.camping.menuFunctions.lightFire"),
    extinguish = require("mer.ashfall.camping.menuFunctions.extinguish"),
    addSupports = require("mer.ashfall.camping.menuFunctions.addSupports"),
    removeSupports = require("mer.ashfall.camping.menuFunctions.removeSupports"),
    addGrill = require("mer.ashfall.camping.menuFunctions.addGrill"),
    removeGrill = require("mer.ashfall.camping.menuFunctions.removeGrill"),
    addKettle = require("mer.ashfall.camping.menuFunctions.addKettle"),
    removeKettle = require("mer.ashfall.camping.menuFunctions.removeKettle"),
    addWater = require("mer.ashfall.camping.menuFunctions.addWater"),
    addIngredient = require("mer.ashfall.camping.menuFunctions.addIngredient"),
    addPot = require("mer.ashfall.camping.menuFunctions.addPot"),
    removePot = require("mer.ashfall.camping.menuFunctions.removePot"),
    emptyPot = require("mer.ashfall.camping.menuFunctions.emptyPot"),
    eatStew = require("mer.ashfall.camping.menuFunctions.eatStew"),
    drink = require("mer.ashfall.camping.menuFunctions.drink"),
    fillContainer = require("mer.ashfall.camping.menuFunctions.fillContainer"),
    wait = require("mer.ashfall.camping.menuFunctions.wait"),
    destroy = require("mer.ashfall.camping.menuFunctions.destroy"),
    cancel = require("mer.ashfall.camping.menuFunctions.cancel"),
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
    { filter = common.staticConfigs.activatorConfig.types.campfire } 
)


-----------------------------
--UPDATE CAMPFIRES
-------------------------------
local function updateCampfireValues(e)
    local function doUpdate(campfire)
        campfire.data.lastFireUpdated = campfire.data.lastFireUpdated or e.timestamp
        campfire.data.lastWaterUpdated = campfire.data.lastWaterUpdated or e.timestamp

        local difference = e.timestamp - campfire.data.lastFireUpdated
        if difference > cfConfigs.campfireUpdateInterval then
            --------
            --FUEL--
            --------
            if campfire.data.isLit then
                campfire.data.lastFireUpdated = e.timestamp

                local rainEffect = 1.0
                --raining and campfire exposed
                if tes3.getCurrentWeather().index == tes3.weather.rain then
                    if not common.helper.checkRefSheltered(campfire) then
                        rainEffect = fuelDecayRainEffect
                    end
                --thunder and campfire exposed
                elseif tes3.getCurrentWeather().index == tes3.weather.thunder then
                    if not common.helper.checkRefSheltered(campfire) then
                        rainEffect = fuelDecayThunderEffect
                    end
                end

                campfire.data.fuelLevel = campfire.data.fuelLevel - ( difference * fuelDecay * rainEffect )
                if campfire.data.fuelLevel <= 0 then
                    campfire.data.fuelLevel = 0
                    local playSound = difference < 0.01
                    event.trigger("Ashfall:Campfire_Extinguish", {campfire = campfire, playSound = true})
                end

            else
                campfire.data.lastFireUpdated = nil
            end
        end
        ---------------
        --Utensil--
        ---------------
        difference = e.timestamp - campfire.data.lastWaterUpdated
        if difference > cfConfigs.campfireUpdateInterval then
            local hasFilledPot = (
                ( campfire.data.hasKettle or campfire.data.hasCookingPot ) and 
                campfire.data.waterAmount and 
                campfire.data.waterAmount > 0
            )
            if hasFilledPot then
                campfire.data.waterHeat = campfire.data.waterHeat or 0
                campfire.data.lastWaterUpdated = e.timestamp
                local heatEffect = -1--negative if cooling down
                if campfire.data.isLit then--based on fuel if heating up
                    heatEffect = math.remap(campfire.data.fuelLevel, 0, cfConfigs.maxWoodInFire, minFuelWaterHeat, maxFuelWaterHeat)
                end
                local heatBefore = campfire.data.waterHeat
                campfire.data.waterHeat = math.clamp((campfire.data.waterHeat + ( difference * waterHeatRate * heatEffect )), 0, 100)
                local heatAfter = campfire.data.waterHeat

                --add boiling sound
                if heatBefore < common.staticConfigs.hotWaterHeatValue and heatAfter > common.staticConfigs.hotWaterHeatValue then
                    tes3.playSound{
                        reference = campfire, 
                        sound = "ashfall_boil"
                    }
                end
                --remove boiling sound
                if heatBefore > common.staticConfigs.hotWaterHeatValue and heatAfter < common.staticConfigs.hotWaterHeatValue then
                    tes3.removeSound{
                        reference = campfire, 
                        sound = "ashfall_boil"
                    }
                end

                --Cook the stew
                if campfire.data.stewLevels then
                    if campfire.data.waterHeat >= common.staticConfigs.hotWaterHeatValue then
                        campfire.data.stewProgress = campfire.data.stewProgress or 0
                        local waterHeatEffect = common.helper.calculateWaterHeatEffect(campfire.data.waterHeat)
                        campfire.data.stewProgress = math.clamp((campfire.data.stewProgress + ( difference * cfConfigs.stewCookRate * waterHeatEffect )), 0, 100)
                    end
                end

                if campfire.data.waterHeat > common.staticConfigs.hotWaterHeatValue then
                    campfire.data.waterDirty = nil
                end
            else
                campfire.data.lastWaterUpdated = nil
            end
            
        end
        event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
    end
    common.helper.iterateCampfires(doUpdate)
    
end

event.register("simulate", updateCampfireValues)

