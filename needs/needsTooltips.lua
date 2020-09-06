local common = require("mer.ashfall.common.common")
local teaConfig = common.staticConfigs.teaConfig
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
local function updateFoodAndWaterTile(e)
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
        --Add brown tinge to dirty water
        if e.itemData.data.waterDirty then
            levelIndicator.color = { 0.8, 0.6, 0.5 }
        end
        --Add green tinge to Tea
        if e.itemData.data.teaType then
            levelIndicator.color = { 0.4, 0.8, 0.4 }
        end
        levelIndicator.consumeMouseEvents = false
        levelIndicator.width = 6
        levelIndicator.height = maxHeight * ( liquidLevel / capacity )
        levelIndicator.scaleMode = true
        levelIndicator.absolutePosAlignY = 1.0
    end


    local isCookable = (
        foodConfig.grillValues[foodConfig.ingredTypes[e.item.id]]
    )
    if isCookable then
        local maxHeight = 32

        local indicatorBlock = e.element:createThinBorder()
        indicatorBlock.consumeMouseEvents = false
        indicatorBlock.absolutePosAlignX = 0.1
        indicatorBlock.absolutePosAlignY = 1.0
        indicatorBlock.width = 8
        indicatorBlock.height = maxHeight
        indicatorBlock.paddingAllSides = 2

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




            local indicatorImage = "textures/menu_bar_red.dds"
            if e.itemData.data.grillState == "burnt" then
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
end

event.register( "itemTileUpdated", updateFoodAndWaterTile )

local function onMenuInventorySelectMenu(e)
    local scrollpane = e.menu:findChild(tes3ui.registerID("MenuInventorySelect_scrollpane"))
    local itemList = e.menu:findChild(tes3ui.registerID("PartScrollPane_pane"))
    
    --Disable UI EXP filtering for tea brewing and grilling
    if common.data.inventorySelectTeaBrew or common.data.inventorySelectStew then
        local uiEXPFilterID = tes3ui.registerID("UIEXP:FiltersearchBlock")
        local filterBlock = e.menu:findChild(uiEXPFilterID)
        if filterBlock then filterBlock.parent.parent.visible = false end
    end

    for _, block in pairs(itemList.children) do

        local obj = block:getPropertyObject("MenuInventorySelect_object")
        local itemData = block:getPropertyObject("MenuInventorySelect_extra", "tes3itemData")

        local tileID = tes3ui.registerID("MenuInventorySelect_icon_brick")
        local iconBlock = block:findChild(tileID)
        local textID = tes3ui.registerID("MenuInventorySelect_item_brick")
        local textBlock = block:findChild(textID)


        updateFoodAndWaterTile{ item = obj, itemData = itemData, element = iconBlock}

        -- if common.data.inventorySelectTeaBrew then
        --     local teaData = teaConfig.teaTypes[obj.id:lower()]
        --     local itemText = block:findChild(tes3ui.registerID("MenuInventorySelect_item_brick"))
        --     itemText.text = teaData.teaName
        -- end

    end
    timer.frame.delayOneFrame(function()
        e.menu:updateLayout()
    end)
end
event.register("menuEnter", onMenuInventorySelectMenu, { filter = "MenuInventorySelect"})

local function createNeedsTooltip(e)
    local tooltip = e.tooltip
    if not e.tooltip then
        return
    end
    if not e.object then
        return
    end

    --Food tooltips
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
            local thisFoodType = foodConfig.ingredTypes[e.object.id]
            if thisFoodType then
                local cookedLabel = ""
                if foodConfig.grillValues[thisFoodType] then
                    local cookedAmount = e.itemData and e.itemData.data.cookedAmount
                    if cookedAmount and e.itemData.data.grillState == nil then
                        cookedLabel = string.format(" (%d%% Cooked)", cookedAmount)
                    elseif e.itemData and e.itemData.data.grillState == "cooked"  then
                        cookedLabel = " (Cooked)"
                    elseif  e.itemData and e.itemData.data.grillState == "burnt" then
                        cookedLabel = " (Burnt)"
                    else
                        cookedLabel = " (Raw)"
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

    --Water tooltips
    if common.config.getConfig().enableThirst then
        local bottleData = thirstController.getBottleData(e.object.id)
        if bottleData then
            local liquidLevel = e.itemData and e.itemData.data.waterAmount or 0

            --Tea
            if e.itemData and e.itemData.data.teaType then
                local teaName = teaConfig.teaTypes[e.itemData.data.teaType].teaName
                labelText = string.format('%s: %d/%d', teaName, math.ceil(liquidLevel), bottleData.capacity)
            --Dirty Water
            elseif e.itemData and e.itemData.data.waterDirty then
                labelText = string.format('Water: %d/%d (Dirty)', math.ceil(liquidLevel), bottleData.capacity)
            --Regular Water
            else
                labelText = string.format('Water: %d/%d', math.ceil(liquidLevel), bottleData.capacity)
            end

            if e.itemData and e.itemData.data.teaType then
                local effectText = teaConfig.teaTypes[e.itemData.data.teaType].effectDescription
                createTooltip(tooltip, effectText , tes3ui.getPalette("positive_color"))
            end

            createTooltip(tooltip, labelText)


            local icon = e.tooltip:findChild(tes3ui.registerID("HelpMenu_icon"))
            if icon then
                updateFoodAndWaterTile{
                    itemData = e.itemData,
                    element = icon, 
                    item = e.object
                }
            end
        end
    end



end

event.register('uiObjectTooltip', createNeedsTooltip)


local function teaBrewingTooltip(e)
    local tooltip = e.tooltip:getContentElement()

    --Tea brewing tooltips
    if common.data.inventorySelectTeaBrew then
        local teaData = teaConfig.teaTypes[e.object.id:lower()]
        if teaData then
            for i = 2, #tooltip.children do
                tooltip.children[i].visible = false
            end
            tooltip.children[1].text = teaData.teaName or tooltip.children[1].text

            local textBlock = tooltip:createBlock{ id = tes3ui.registerID("Ashfall:TeaDescription")}
            textBlock.flowDirection = "top_to_bottom"
            textBlock.maxWidth = 310
            textBlock.paddingAllSides = 6
            textBlock.autoHeight = true
            textBlock.autoWidth = true
            local teaDescription = textBlock:createLabel{ text = teaData.teaDescription }
            teaDescription.wrapText = true
            local effectLabelText = teaData.effectDescription
            -- if teaData.duration then 
            --     effectLabelText = string.format("%s for %d hour%s",
            --         teaData.effectDescription,
            --         teaData.duration,
            --         teaData.duration > 1 and "s" or ""
            --     )
            -- end

            local teaEffects = textBlock:createLabel{ text = effectLabelText }
            teaEffects.borderTop = 5
            teaEffects.color = tes3ui.getPalette("positive_color")
        end
    end
end

event.register("uiObjectTooltip", teaBrewingTooltip, { priority = -101})
