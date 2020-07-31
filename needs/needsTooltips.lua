local common = require("mer.ashfall.common.common")
local hungerController = require('mer.ashfall.needs.hungerController')
local thirstController = require('mer.ashfall.needs.thirstController')
local foodConfig = common.staticConfigs.foodConfig

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

local function createTooltip(tooltip, labelText, color)
    --Get main block inside tooltip
    local partmenuID = tes3ui.registerID('PartHelpMenu_main')
    local mainBlock = tooltip:findChild(partmenuID):findChild(partmenuID):findChild(partmenuID)

    local outerBlock = mainBlock:createBlock()
    setupOuterBlock(outerBlock)

    local label = outerBlock:createLabel({text = labelText})
    label.autoHeight = true
    label.autoWidth = true
    if color then label.color = color end
    mainBlock:reorderChildren(1, -1, 1)
    mainBlock:updateLayout()
end

--Adds fillbar showing how much water is left in a bottle. 
--Height of fillbar border based on capacity of bottle.
local function updateFoodAndWaterTiles(e)
    if not common.data then return end
    if not common.config.getConfig().enableThirst then return end

    --bottles show water amount
    local bottleData = thirstController.getBottleData(e.item.id) 
    if e.itemData and bottleData then
        local liquidLevel = e.itemData.data.waterAmount or 0
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
        --Add a greenish tinge to dirty water
        if e.itemData.data.waterDirty then
            levelIndicator.color = { 0.8, 0.6, 0.5 }
        end
        levelIndicator.consumeMouseEvents = false
        levelIndicator.width = 6
        levelIndicator.height = maxHeight * ( liquidLevel / capacity )
        levelIndicator.scaleMode = true
        levelIndicator.absolutePosAlignY = 1.0
    end

    --Food shows cooked amount
    local hasCookedValue = (
        e.itemData and 
        e.itemData.data and 
        e.itemData.data.cookedAmount and 
        e.itemData.data.cookedAmount > 0
    )
    if hasCookedValue then
        local cookedAmount =  e.itemData.data.cookedAmount
        local capacity = 100
        local maxHeight = 32

        local indicatorBlock = e.element:createThinBorder()
        indicatorBlock.consumeMouseEvents = false
        indicatorBlock.absolutePosAlignX = 0.1
        indicatorBlock.absolutePosAlignY = 1.0
        indicatorBlock.width = 8
        indicatorBlock.height = maxHeight
        indicatorBlock.paddingAllSides = 2


        local indicatorImage = "textures/menu_bar_red.dds"
        if e.itemData.data.cookedAmount > hungerController.getBurnLimit() then
            indicatorImage = "textures/menu_bar_gray.dds"
        end
        local levelIndicator = indicatorBlock:createImage({ path = indicatorImage })

        levelIndicator.consumeMouseEvents = false
        levelIndicator.width = 6
        levelIndicator.height = maxHeight * ( cookedAmount / capacity )
        levelIndicator.scaleMode = true
        levelIndicator.absolutePosAlignY = 1.0


    end
end

event.register( "itemTileUpdated", updateFoodAndWaterTiles )





local function createNeedsTooltip(e)
    local tooltip = e.tooltip
    if not e.tooltip then
        return
    end
    if not e.object then
        return
    end

    local labelText
    if e.object.objectType == tes3.objectType.ingredient then
        if common.config.getConfig().enableHunger  then
            --hunger value
            local foodValue = hungerController.getFoodValue(e.object, e.itemData)
            if foodValue and foodValue ~= 0 then
                labelText = string.format('Food Value: %d', foodValue)
                createTooltip(tooltip, labelText)
            end

            --cook state
            local thisFoodType = foodConfig.ingredTypes[e.object.id] or foodConfig.TYPE.misc
            if thisFoodType then
                local cookedLabel = ""
                if foodConfig.grillValues[thisFoodType] then
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

        --Meat disease/blight
        if common.config.getConfig().enableDiseasedMeat then
            if e.itemData and e.itemData.data.mer_disease then
                local diseaseLabel
                local diseaseType = e.itemData.data.mer_disease.spellType
                if diseaseType == tes3.spellType.disease then
                    diseaseLabel = "Diseased"
                elseif diseaseType == tes3.spellType.blight then
                    diseaseLabel = "Blighted"
                end
                if diseaseLabel then
                    createTooltip(tooltip, diseaseLabel, tes3ui.getPalette("negative_color"))
                end
            end
        end
    end

    if common.config.getConfig().enableThirst then
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
                updateFoodAndWaterTiles{
                    itemData = e.itemData,
                    element = icon, 
                    item = e.object
                }
            end
            
        end
        
    end

end

event.register('uiObjectTooltip', createNeedsTooltip)

