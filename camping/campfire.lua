local common = require ("mer.ashfall.common.common")

local function initialiseCampfireSoundAndFlame()
    local function doUpdate(campfire)
        if campfire.data.isLit then
            tes3.removeSound{
                sound = "Fire",
                reference = campfire,
            }
            local lightNode = campfire.sceneNode:getObjectByName("AttachLight")
            lightNode.translation.z = 25
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

    common.helper.iterateRefType("campfire", doUpdate)
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
        initialiseCampfireSoundAndFlame()
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
    initialiseCampfireSoundAndFlame()
end

event.register("loaded", loaded)



-- Extinguish the campfire
local function extinguish(e)
    local campfire = e.fuelConsumer
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
    --event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
end
event.register("Ashfall:fuelConsumer_Extinguish", extinguish)

--[[
    Mapping of which buttons can appear for each part of the campfire selected
]]
local buttonMapping = {
    ["Grill"] = {
        "removeGrill",
        "cancel"
    },
    ["Cooking Pot"] = {
        "drink",
        "fillContainer",
        "eatStew",
        "companionEatStew",
        "addIngredient",
        "addWater",
        "emptyPot",
        "removePot",
        "cancel",
    },
    ["Kettle"] = {
        "drink",
        "brewTea",
        "addWater",
        "fillContainer",
        "emptyKettle",
        "removeKettle",
        "cancel",
    },
    ["Supports"] = {
        "addKettle",
        "addPot",
        "removeKettle",
        "removePot",
        "removeSupports",
        "cancel",
    },
    ["Campfire"] = {
        "addFirewood",
        "lightFire",
        "addSupports",
        "removeSupports",
        "addGrill",
        "removeGrill",
        "addKettle",
        "addPot",
        "removeKettle",
        "removePot",
        "wait",
        "extinguish",
        "destroy",
        "cancel"
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
                    event.trigger("Ashfall:registerReference", { reference = campfire})
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

    for _, buttonType in ipairs(buttonList) do
        local button = require(string.format("mer.ashfall.camping.menuFunctions.%s", buttonType))
        addButton(buttons, button)
    end
    common.helper.messageBox({ message = text, buttons = buttons })
end

event.register(
    "Ashfall:ActivatorActivated", 
    onActivateCampfire, 
    { filter = common.staticConfigs.activatorConfig.types.campfire } 
)