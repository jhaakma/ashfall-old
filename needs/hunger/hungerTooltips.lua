local this = {}
local common = require("mer.ashfall.common")
local hungerCommon = require("mer.ashfall.needs.hunger.hungerCommon")

local function setupOuterBlock(e)
    e.flowDirection = "left_to_right"
    e.paddingTop = 0
    e.paddingBottom = 0
    e.paddingLeft = 6
    e.paddingRight = 6
    e.autoWidth = true
    e.autoHeight = true
    e.childAlignX  = 0.5
end


local function createFoodTooltip(e)
    if common.data.mcmSettings.enableHunger then
        local tooltip = e.tooltip
        if not e.tooltip then return end
        if not e.object then return end   
        if hungerCommon.isFood(e.object) then 
            local foodValue = hungerCommon.getFoodValue(e.object.id)
            if foodValue ~= 0 then
                --Get main block inside tooltip
                local partmenuID = tes3ui.registerID("PartHelpMenu_main")
                local mainBlock = tooltip:findChild(partmenuID):findChild(partmenuID):findChild(partmenuID)


                local outerBlock = mainBlock:createBlock()
                setupOuterBlock(outerBlock)

                local foodLabelText = string.format("Food Rating: %d", foodValue)
                local foodLabel = outerBlock:createLabel({text = foodLabelText})
                foodLabel.autoHeight = true
                foodLabel.autoWidth = true

                mainBlock:reorderChildren( 1, -1, 1 )
                mainBlock:updateLayout()
            end
        end
    end
end

event.register("uiObjectTooltip", createFoodTooltip)