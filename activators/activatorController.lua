local this = {}

--[[
    This script creates tooltips when looking at Ashfall activators.
    Other scripts can see what the player is looking at by checking]
    this.current
]]--

local common = require("mer.ashfall.common.common")
local activatorList = require("mer.Ashfall.activators.activatorList")
this.list = activatorList.list
this.current = nil
this.currentRef = nil
this.parentNode = nil

function this.getCurrentActivator()
    return this.list[this.current]
end

local id_indicator = tes3ui.registerID("Ashfall:activatorTooltip")
local id_label = tes3ui.registerID("Ashfall:activatorTooltipLabel")

--[[
    Create a tooltip when looking at an activator
]]--

function this.getActivatorTooltip()
    local menu = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    if menu then
        return menu:findChild(id_indicator)
    end
end

local function centerText(element)
    element.autoHeight = true
    element.autoWidth = true
    element.wrapText = true
    element.justifyText = "center" 
end

local function doActivate()
    return (
        this.current and 
        not tes3.menuMode() and 
        common.data.mcmSettings[this.list[this.current].mcmSetting] ~= false
    )
end

local function createActivatorIndicator()
    
    local menu = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    if menu then
        local mainBlock = menu:findChild(id_indicator)
        
        if doActivate() then
            if mainBlock then
                mainBlock:destroy()
            end

            mainBlock = menu:createBlock({id = id_indicator })
            
            mainBlock.absolutePosAlignX = 0.5
            mainBlock.absolutePosAlignY = 0.03
            mainBlock.autoHeight = true
            mainBlock.autoWidth = true

            
            local labelBackground = mainBlock:createRect({color = {0, 0, 0}})
            --labelBackground.borderTop = 4
            labelBackground.autoHeight = true
            labelBackground.autoWidth = true

            local labelBorder = labelBackground:createThinBorder({})
            labelBorder.autoHeight = true
            labelBorder.autoWidth = true
            labelBorder.paddingAllSides = 10
            labelBorder.flowDirection = "top_to_bottom"

            local text = this.list[this.current].name
            local label = labelBorder:createLabel{ id=id_label, text = text}
            label.color = tes3ui.getPalette("header_color")
            centerText(label)

            
            if this.current == "campfire" then
                local eventData = {
                    label = label,
                    parentNode = this.parentNode,
                    labelBorder = labelBorder,
                    campfire = this.currentRef
                }
                event.trigger("Ashfall:CampfireTooltip", eventData)
            end

        else
            if mainBlock then
                mainBlock.visible = false
            end
        end
    end
end


--[[
    Every frame, check whether the player is looking at 
    a static activator
]]--
function this.callRayTest()
    this.current = nil
    this.currentRef = nil
    --Figure out camera position
    local rayPosition
    local rayDirection
    
    if tes3.is3rdPerson() then
        local head = tes3.player.sceneNode:getObjectByName("Bip01 Head")
        rayPosition = head.worldTransform.translation
        rayDirection = tes3vector3.new (
            tes3.player.orientation.x,
            --tes3.player.orientation.y,
            tes3.getCameraVector().y,
            tes3.player.orientation.z
        )
    else
        rayPosition = tes3.getCameraPosition()
        rayDirection = tes3.getCameraVector()
    end
    local oldCulledValue = tes3.player.sceneNode.appCulled
    tes3.player.sceneNode.appCulled = true
    local result = tes3.rayTest{
        position = rayPosition,
        direction = rayDirection,
    }
    tes3.player.sceneNode.appCulled = oldCulledValue
    if result then
        
        if (result and result.reference ) then 
            
            local distance = rayPosition:distance(result.intersection)

            --Look for activators from list
            if distance < 200 then
                local targetRef = result.reference
                if targetRef then
                    for activatorId, activator in pairs(this.list) do
                        for _, pattern in ipairs(activator.ids) do
                            if string.find(string.lower(targetRef.id), pattern) then
                                this.current = activatorId
                                this.currentRef = targetRef
                                this.parentNode = result.object.parent
                            end
                        end
                    end
                    createActivatorIndicator()
                    return
                end
            end
        end

        --Special case for looking at water
        local cell =  tes3.player.cell
        local waterLevel = cell.waterLevel or 0
        local intersection = result.intersection
        local adjustedIntersection = tes3vector3.new( intersection.x, intersection.y, waterLevel )
        local adjustedDistance = rayPosition:distance(adjustedIntersection)
        if adjustedDistance < 300 and cell.hasWater then
            local blockedBySomething =
                result.reference and
                result.reference.object.objectType ~= tes3.objectType.static
            local cameraIsAboveWater = rayPosition.z > waterLevel
            local isLookingAtWater = intersection.z < waterLevel
            if cameraIsAboveWater and isLookingAtWater and not blockedBySomething then
                this.current = "water"
            end 
        end
    end
    createActivatorIndicator()
end
--event.register("simulate", callRayTest)

--[[
    triggerActivate:
    When player presses the activate key, if they are looking
    at an activator static then fire an event
]]--
local function triggerActivate()
    local inputController = tes3.worldController.inputController
    local keyTest = inputController:keybindTest(tes3.keybind.activate)
    if (keyTest and doActivate() ) then
        local eventData = {
            activator = this.list[this.current],
            ref = this.currentRef,
            node = this.parentNode
        }
        event.trigger("Ashfall:ActivatorActivated", eventData, { filter = eventData.activator.type }) 
    end
end
event.register("keyDown", triggerActivate )


return this