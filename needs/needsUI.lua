--[[
    Needs displayed in stats menu
]]--
local this = {}
local common = require("mer.ashfall.common")

local UIData = {
    hunger = {
        blockID = tes3ui.registerID("Ashfall:hungerUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:hungerFillBar"),
        conditionID = tes3ui.registerID("Ashfall:hungerConditionId"),
        mcmEnable = common.MCMOptionIds.enableHunger,
        conditionTypes = common.conditions.hunger,
        defaultCondition = "satiated",
        conditionValueDataField = "hunger",
    },
    thirst = {
        blockID = tes3ui.registerID("Ashfall:thirstUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:thirstFillBar"),
        conditionID = tes3ui.registerID("Ashfall:thirstConditionId"),
        mcmEnable = common.MCMOptionIds.enableThirst,
        conditionTypes = common.conditions.thirst,
        defaultCondition = "hydrated",
        conditionValueDataField = "thirst",
    },
    sleep = {
        blockID = tes3ui.registerID("Ashfall:sleepUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:sleepFillBar"),
        conditionID = tes3ui.registerID("Ashfall:sleepConditionId"),
        mcmEnable = common.MCMOptionIds.enableSleep,
        conditionTypes = common.conditions.sleep,
        defaultCondition = "rested",
        conditionValueDataField = "sleep",
        reverseDirection = true,
    },
    needsBlock = tes3ui.registerID("Ashfall:needsBlock"),
}

local barColors = {
    hunger = {(135/255), (6/255), (6/255)},
    thirst = {(0/255), (65/255), (95/255)},
    sleep = {(4/255), (114/255), (43/255)}
}

local function updateNeedsBlock(menu, data)

    local block = menu:findChild(data.blockID)
    
    if not common.data.mcmOptions[data.mcmEnable] then
        block.visible = false
    else
        if block and block.visible == false then
            block.visible = true
        end
    end
    --Update Hunger
    local fillBar = menu:findChild(data.fillBarID)

    local conditionLabel = menu:findChild(data.conditionID)
    if fillBar and conditionLabel then

        --update condition
        local condition = common.data.currentConditions[data.conditionValueDataField] or data.defaultCondition
        conditionLabel.text = (
            data.conditionTypes[ condition ] and data.conditionTypes[ condition ].text or 
            data.conditionTypes[data.defaultCondition].text
        )
            
        --update fillBar
        local needsLevel
        if data.reverseDirection then
            needsLevel = common.data[data.conditionValueDataField] or 100
            fillBar.widget.current = needsLevel
        else
            needsLevel = common.data[data.conditionValueDataField] or 0
            fillBar.widget.current = 100 - needsLevel
        end
    end
end

function this.updateNeedsUI()
    if not common.data then return end
    local inventoryMenu = tes3ui.findMenu(tes3ui.registerID("MenuInventory"))

    if inventoryMenu then   
        --Check Ashfall active
        local needsBlock = inventoryMenu:findChild(UIData.needsBlock)
        local needsActive = (
            common.data.mcmOptions.enableHunger or
            common.data.mcmOptions.enableThirst or
            common.data.mcmOptions.enableSleep 
        )
        needsBlock.visible = needsActive
        --Update UIs
        updateNeedsBlock(inventoryMenu, UIData.hunger)
        updateNeedsBlock(inventoryMenu, UIData.thirst)
        updateNeedsBlock(inventoryMenu, UIData.sleep)

        inventoryMenu:updateLayout()
    end
end

local function setupNeedsBlock(element)
    element.borderAllSides = 4
    element.borderTop = 0
    element.paddingTop = 0
    element.paddingLeft = 0
    element.paddingRight = 0
    element.paddingBottom = 0
    element.autoHeight = true
    element.autoWidth = true
    element.widthProportional = 1
    element.flowDirection = "top_to_bottom"
end


local function setupNeedsElementBlock(element)
    element.autoHeight = true
    element.autoWidth = true

    element.paddingBottom = 1
    element.widthProportional = 1
    element.flowDirection = "left_to_right"
end

local function setupNeedsBar(element)
    element.widget.showText = false
    element.height = 20
    element.widthProportional = 1.0
end

local function setupConditionLabel(element)
    element.absolutePosAlignX = 0.5
    element.borderLeft = 2
    element.absolutePosAlignY = 0.0
    element.widthProportional = 1.0
end

local function createNeedsUI(e)
    local startingBlock = e.element:findChild(tes3ui.registerID("MenuInventory_character_box")).parent
    ---Needs Block
    local needsBlock = startingBlock:findChild(UIData.needsBlock)
    if needsBlock then
        needsBlock:destroyChildren()
    else
        needsBlock = startingBlock:createThinBorder({id = UIData.needsBlock})
    end  

    setupNeedsBlock(needsBlock)

    --Hunger
    local hungerBlock = needsBlock:createBlock({id = UIData.hunger.blockID})
    setupNeedsElementBlock(hungerBlock)

    local hungerBar = hungerBlock:createFillBar({ id = UIData.hunger.fillBarID, current = 100, max = 100 })
    setupNeedsBar(hungerBar)
    hungerBar.widget.fillColor = barColors.hunger

    local hungerConditionLabel = hungerBlock:createLabel({ id = UIData.hunger.conditionID, text = "Satiated"})
    setupConditionLabel(hungerConditionLabel)


    --Thirst
    local thirstBlock = needsBlock:createBlock({id = UIData.thirst.blockID})
    setupNeedsElementBlock(thirstBlock)

    local thirstBar = thirstBlock:createFillBar({ id = UIData.thirst.fillBarID, current = 100, max = 100 })
    setupNeedsBar(thirstBar)
    thirstBar.widget.fillColor = barColors.thirst


    local thirstConditionLabel = thirstBlock:createLabel({ id = UIData.thirst.conditionID, text = "Hydrated"})
    setupConditionLabel(thirstConditionLabel)


    --Sleep
    local sleepBlock = needsBlock:createBlock({id = UIData.sleep.blockID})
    setupNeedsElementBlock(sleepBlock)

    local sleepBar = sleepBlock:createFillBar({ id = UIData.sleep.fillBarID, current = 100, max = 100})
    setupNeedsBar(sleepBar)
    sleepBar.widget.fillColor = barColors.sleep

    local sleepConditionLabel = sleepBlock:createLabel({ id = UIData.sleep.conditionID, text = "Rested"})
    setupConditionLabel(sleepConditionLabel)

    this.updateNeedsUI()
end


function this.addNeedsBlockToMenu(e, need)
    local data = UIData[need]
    if not common.data.mcmOptions[data.mcmEnable] then
        --this need is disabled
        return
    end

    local block = e.element:createBlock()
    setupNeedsElementBlock(block)
    block.maxWidth = 250
    block.borderTop = 10

    local fillBar = block:createFillBar({current = 100, max = 100})
    setupNeedsBar(fillBar)

    fillBar.widget.fillColor = barColors[need]

    local conditionText = common.conditions[need].text

end

function this.addRestMenuSleepBlock(e)

    if common.data.mcmOptions.enableSleep  then


        local sleepBlock = e.element:createBlock()
        setupNeedsElementBlock(sleepBlock)

        sleepBlock.maxWidth = 250
        sleepBlock.borderTop = 10

        local sleepBar = sleepBlock:createFillBar({ id = UIData.sleep.fillBarID, current = 100, max = 100})
        setupNeedsBar(sleepBar)

        sleepBar.widget.fillColor = barColors.sleep

        local conditionText =  common.conditions.sleep[common.data.currentCondition.sleep].text
        local sleepConditionLabel = sleepBlock:createLabel({ id = UIData.sleep.conditionID, text = conditionText})
        setupConditionLabel(sleepConditionLabel)

        updateNeedsBlock(e.element, UIData.sleep)
    end
end

event.register("uiCreated", createNeedsUI, { filter = "MenuInventory" } )


return this
