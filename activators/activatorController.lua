local this = {}

--[[
    This script creates tooltips when looking at Ashfall activators.
    Other scripts can see what the player is looking at by checking]
    this.currentActivator
]]--

local common = require("mer.ashfall.common")

this.currentActivator = nil
local activatorList = require("mer.Ashfall.activators.activatorList")
this.activatorList = activatorList.list
this.activatorTypes = activatorList.types


local id_indicator = tes3ui.registerID("Ashfall:activatorTooltip")
local id_label = tes3ui.registerID("Ashfall:activatorTooltipLabel")


local tabCount = tabCount or 0
local function printElementTree(e)
	tabCount = tabCount + 1
	for i=1, #e.children do
		local child = e.children[i]
		local printString = ""
		for i=1, tabCount do
			printString = "  " .. printString
		end
		printString = printString .. "- " .. child.name .. ", ID: " .. child.id
		mwse.log(printString)
		printElementTree(child)
		tabCount = tabCount - 1
	end
end

--Create water/well tooltip if it doesn't exist
local function createTooltip()
    local text = this.currentActivator.name
    local tooltip = tes3ui.findMenu(id_indicator)
    if not tooltip then
        tooltip = tes3ui.createMenu{id = id_indicator, fixedFrame = true}
        printElementTree(tooltip)
        tooltip.positionX = 200
        tooltip.absolutePosAlignY  = 0.02
        tooltip.autoHeight = true
        tooltip.autoWidth = true

        local label = tooltip.parent:createLabel{ id=id_label, text = text}
        label.autoHeight = true
        label.autoWidth = true
        label.wrapText = true
        label.justifyText = "center"
        
        lookingAtWater = true
    end
end

local function createActivatorIndicator()
    
    local menu = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    if menu then
        local mainBlock = menu:findChild(id_indicator)
        
        if (
            this.currentActivator and 
            not tes3.menuMode() and 
            common.data.mcmSettings[this.currentActivator.mcmSetting] 
        )then
            if not mainBlock then

                mainBlock = menu:createBlock({id = id_indicator })
                
                mainBlock.absolutePosAlignX = 0.5
                mainBlock.absolutePosAlignY = 0.01
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

                local text = this.currentActivator.name
                local label = labelBorder:createLabel{ id=id_label, text = text}
                label.autoHeight = true
                label.autoWidth = true
                label.wrapText = true
                label.justifyText = "center"
            end
        else
            if mainBlock then
                mainBlock:destroy()
            end
        end
    end
end


--[[
    Every frame, check whether the player is looking at 
    a static activator
]]--
local function callRayTest()
    this.currentActivator = nil

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
    oldCulledValue = tes3.player.sceneNode.appCulled
    tes3.player.sceneNode.appCulled = true
    local result = tes3.rayTest{
        position = rayPosition,
        direction = rayDirection,
    }
    tes3.player.sceneNode.appCulled = oldCulledValue
    if result then
        if (result and result.reference ) then 

            --mwse.log(result.reference.id)
            local distance = rayPosition:distance(result.intersection)

            --Look for activators from list
            if distance < 200 then
                local targetRef = result.reference
                if targetRef then
                    --mwse.log("Looking at: %s", targetRef.id)
                    for _, activator in pairs(this.activatorList) do
                        for _, pattern in ipairs(activator.ids) do
                            if string.find(string.lower(targetRef.id), pattern) then
                                --mwse.log("Returning activator")
                                this.currentActivator = activator
                            end
                        end
                    end
                end
            end
        else
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
                    this.currentActivator = this.activatorList.water
                end 
            end
        end
    end
    createActivatorIndicator()
end
event.register("simulate", callRayTest)

--[[
    triggerActivate:
    When player presses the activate key, if they are looking
    at an activator static then fire an event
]]--
local function triggerActivate(e)
    local inputController = tes3.worldController.inputController
    local keyTest = inputController:keybindTest(tes3.keybind.activate)
    if (keyTest and not tes3.menuMode() and this.currentActivator ) then
        local eventData = {
            activator = this.currentActivator
        }
        event.trigger("Ashfall:Activated", eventData, { filter = eventData.activator.type }) 
    end
end
event.register("keyDown", triggerActivate )


return this