local common = require('mer.ashfall.common')
local hungerCommon = require('mer.ashfall.needs.hunger.hungerCommon')
local thirstCommon = require('mer.ashfall.needs.thirst.thirstCommon')

local function setupOuterBlock(e)
    e.flowDirection = 'left_to_right'
    e.paddingTop = 0
    e.paddingBottom = 2
    e.paddingLeft = 6
    e.paddingRight = 6
    e.autoWidth = 1.0
    e.autoHeight = true
    e.childAlignX = 0.5
end

local function createTooltip(tooltip, labelText)
    --Get main block inside tooltip
    local partmenuID = tes3ui.registerID('PartHelpMenu_main')
    local mainBlock = tooltip:findChild(partmenuID):findChild(partmenuID):findChild(partmenuID)

    local outerBlock = mainBlock:createBlock()
    setupOuterBlock(outerBlock)

    local label = outerBlock:createLabel({text = labelText})
    label.autoHeight = true
    label.autoWidth = true

    mainBlock:reorderChildren(1, -1, 1)
    mainBlock:updateLayout()
end


--Recursively prints the children of an element to the logs
local tabCount = tabCount or 0
local function printElementTree(e)
    tabCount = tabCount + 1
    for i = 1, #e.children do
        local child = e.children[i]
        local printString = ''
        for i = 1, tabCount do
            printString = '  ' .. printString
        end
        printString = printString .. '- ' .. child.name .. ', ID: ' .. child.id
        mwse.log(printString)
        printElementTree(child)
        tabCount = tabCount - 1
    end
end



--Adds fillbar showing how much water is left in a bottle. 
local function updateWaterIndicatorValues(e)

    local bottleData = thirstCommon.bottleList[e.item.id]

    if bottleData then
        local liquidLevel =  e.itemData and e.itemData.data.currentWaterAmount or 0

        local capacity = bottleData.capacity

        local maxHeight = 32 * ( capacity / thirstCommon.capacities.MAX)

        local indicatorBlock = e.element:createThinBorder()
        indicatorBlock.consumeMouseEvents = false
        indicatorBlock.absolutePosAlignX = 0.1
        indicatorBlock.absolutePosAlignY = 1.0
        indicatorBlock.width = 8
        indicatorBlock.height = maxHeight
        indicatorBlock.paddingAllSides = 2
        --mwse.log("capacity = %s", capacity)
        --mwse.log("height = %d", indicatorBlock.height)

        local levelIndicator = indicatorBlock:createImage({ path = "textures/menu_bar_blue.dds" })
        levelIndicator.consumeMouseEvents = false
        levelIndicator.width = 6
        levelIndicator.height = maxHeight * ( liquidLevel / capacity )
        levelIndicator.scaleMode = true
        levelIndicator.absolutePosAlignY = 1.0
    end
end

event.register( "itemTileUpdated", updateWaterIndicatorValues )





local function createNeedsTooltip(e)
    local tooltip = e.tooltip
    if not e.tooltip then
        return
    end
    if not e.object then
        return
    end

    local doFoodToolTip = (common.data.mcmOptions.enableHunger and e.object.objectType == tes3.objectType.ingredient)
    local labelText
    if doFoodToolTip then
        local foodValue = hungerCommon.getFoodValue(e.object.id)
        if foodValue and foodValue ~= 0 then
            labelText = string.format('Food: %d', foodValue)
        end
    end

    if common.data.mcmOptions.enableThirst then
        local bottleData = thirstCommon.bottleList[e.object.id]
        if bottleData then
            local liquidLevel = e.itemData and e.itemData.data.currentWaterAmount or 0
            labelText = string.format('Water: %d / %d', liquidLevel, bottleData.capacity)
        end
        local icon = e.tooltip:findChild(tes3ui.registerID("HelpMenu_icon"))
        if icon then
            updateWaterIndicatorValues{
                itemData = e.itemData,
                element = icon, 
                item = e.object
            }
        end
    end

    if (labelText) then
        createTooltip(tooltip, labelText)
    end
end

event.register('uiObjectTooltip', createNeedsTooltip)