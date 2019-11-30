local common = require("mer.ashfall.common.common")
local hungerController = require('mer.ashfall.needs.hunger.hungerController')
local thirstController = require('mer.ashfall.needs.thirst.thirstController')
local foodTypes = require("mer.ashfall.camping.foodTypes")
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
local tabCount = 0
local function printElementTree(e)
    tabCount = tabCount + 1
    for i = 1, #e.children do
        local child = e.children[i]
        local printString = ''
        for _ = 1, tabCount do
            printString = '  ' .. printString
        end
        printString = printString .. '- ' .. child.name .. ', ID: ' .. child.id
        mwse.log(printString)
        printElementTree(child)
        tabCount = tabCount - 1
    end
end



--Adds fillbar showing how much water is left in a bottle. 
--Height of fillbar border based on capacity of bottle.
local function updateWaterIndicatorValues(e)
    if common.data and not common.data.mcmSettings.enableThirst then return end

    local bottleData = thirstController.getBottleData(e.item.id)

    if bottleData then
        local liquidLevel =  e.itemData and e.itemData.data.waterAmount or 0
        local capacity = bottleData.capacity
        local maxHeight = 32 * ( capacity / common.staticConfigs.capacities.MAX)

        local indicatorBlock = e.element:createThinBorder()
        indicatorBlock.consumeMouseEvents = false
        indicatorBlock.absolutePosAlignX = 0.1
        indicatorBlock.absolutePosAlignY = 1.0
        indicatorBlock.width = 8
        indicatorBlock.height = maxHeight
        indicatorBlock.paddingAllSides = 2

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

    local doFoodToolTip = (
        common.data.mcmSettings.enableHunger and 
        e.object.objectType == tes3.objectType.ingredient
    )
    local labelText
    if doFoodToolTip then

        --hunger value
        local foodValue = hungerController.getFoodValue(e.object, e.itemData)
        if foodValue and foodValue ~= 0 then
            labelText = string.format('Food Value: %d', foodValue)
            createTooltip(tooltip, labelText)
        end


        --cook state
        local thisFoodType = foodTypes.ingredTypes[e.object.id]
        if thisFoodType then
            local cookedLabel = ""
            if thisFoodType == foodTypes.TYPE.protein or thisFoodType == foodTypes.TYPE.vegetable then
                local cookedAmount = e.itemData and e.itemData.data.cookedAmount
                if not cookedAmount  then
                    cookedLabel = " (Raw)"
                elseif cookedAmount < 100 then
                    cookedLabel = string.format(" (%d%% Cooked)", cookedAmount)
                elseif cookedAmount < hungerController.getBurnLimit() then
                    cookedLabel = " (Cooked)"
                else
                    cookedLabel = " (Burnt)"
                end
            end

            local foodTypeLabel = string.format("%s%s", thisFoodType, cookedLabel)
            createTooltip(tooltip, foodTypeLabel)

        end
    end

    if common.data.mcmSettings.enableThirst then
        local bottleData = thirstController.getBottleData(e.object.id)
        if bottleData then
            local liquidLevel = e.itemData and e.itemData.data.waterAmount or 0
            labelText = string.format('Water: %d/%d', math.ceil(liquidLevel), bottleData.capacity)
            if e.itemData and e.itemData.data.waterDirty then
                labelText = labelText .. " (Dirty)"
            end
            createTooltip(tooltip, labelText)

            local icon = e.tooltip:findChild(tes3ui.registerID("HelpMenu_icon"))
            if icon then
                updateWaterIndicatorValues{
                    itemData = e.itemData,
                    element = icon, 
                    item = e.object
                }
            end
            
        end
        
    end

end

event.register('uiObjectTooltip', createNeedsTooltip)


---------------
--Effect indicators-
--------------------
local function getWarmEffects()
    if not common.data then return {} end
    return {
        { text = "Warm Meal", value = common.data.stewWarmEffect },
        { text = "Clothing/Armor", value = common.data.warmthRating },
        { text = "Torch", value = common.data.torchTemp },
        { text = "Tent", value = common.data.tentTemp },
    }
end

local function warmthTooltip()
    local tooltip = tes3ui.createTooltipMenu()

    local topBlock = tooltip:createBlock()
    topBlock.flowDirection = "left_to_right"
    topBlock.autoHeight = true
    topBlock.autoWidth = true


    local iconBlock = topBlock:createBlock()
    iconBlock.autoHeight = true
    iconBlock.autoWidth = true
    iconBlock.borderRight = 10

    local icon = iconBlock:createImage{path = "Icons/ashfall/spell/Warmth.dds" }
    icon.height = 16
    icon.width = 16
    icon.scaleMode = true

    local header = topBlock:createLabel{ text = "Warmth" }
    header.color = tes3ui.getPalette("header_color")

    for _, warmEffect in ipairs(getWarmEffects()) do
        if warmEffect.value and warmEffect.value > 0 then
            local text = string.format("%s: %d pts", warmEffect.text, warmEffect.value)
            tooltip:createLabel{ text = text}
       end
    end
end


local warmthBlockID = tes3ui.registerID("Ashfall_WarmthIcon")
local function updateBuffIcons()
    if not common.data then return end

    timer.frame.delayOneFrame(function()

        local menu = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
        if menu then
            
            local iconsBlock = menu:findChild(tes3ui.registerID("MenuMulti_magic_icons_box")).parent
            
            local warmthBlock = menu:findChild(warmthBlockID)
            if not common.data.mcmSettings.enableTemperatureEffects then 
                if warmthBlock then warmthBlock:destroy() end
                return 
            end
            if not warmthBlock then

                warmthBlock = iconsBlock:createThinBorder({ id = warmthBlockID})
                warmthBlock.autoHeight = true
                warmthBlock.autoWidth = true


                local warmthIcon = warmthBlock:createImage{path = "Icons/ashfall/spell/Warmth.dds" }
                warmthIcon.height = 16
                warmthIcon.width = 16
                warmthIcon.scaleMode = true
                warmthIcon.borderAllSides = 2

                warmthIcon:register( "help", warmthTooltip )
                
            end

            warmthBlock.visible = false
            for _, warmEffect in ipairs(getWarmEffects()) do
                if warmEffect.value and warmEffect.value > 0 then
                    warmthBlock.visible = true
                end
            end
        end
    end)
end

event.register("simulate", updateBuffIcons)
event.register("unequipped", updateBuffIcons)
event.register("equipped", updateBuffIcons)
