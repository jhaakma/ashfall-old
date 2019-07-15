--[[
    Needs displayed in stats menu
]]--
local this = {}
local common = require("mer.ashfall.common")
local function rgbToColor(r, g, b)
    return { (r/255), (g/255), (b/255) }
end



function this.showThirst()
    return (
        common.data.mcmSettings.enableThirst and 
        common.data.mcmSettings.thirstRate > 0
    )
end

function this.showHunger()
    return (
        common.data.mcmSettings.enableHunger and 
        common.data.mcmSettings.hungerRate > 0
    )
end

function this.showSleep()
    return (
        common.data.mcmSettings.enableSleep and 
        common.data.mcmSettings.loseSleepRate > 0
    )
end

this.UIData = {
    hunger = {
        blockID = tes3ui.registerID("Ashfall:hungerUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:hungerFillBar"),
        conditionID = tes3ui.registerID("Ashfall:hungerConditionId"),
        showUIFunction = this.showThirst,
        conditionTypes = common.conditions.hunger.states,
        defaultCondition = "satiated",
        conditionValueDataField = "hunger",
        color = rgbToColor(230, 92, 0),
    },
    thirst = {
        blockID = tes3ui.registerID("Ashfall:thirstUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:thirstFillBar"),
        conditionID = tes3ui.registerID("Ashfall:thirstConditionId"),
        showUIFunction = this.showThirst,
        conditionTypes = common.conditions.thirst.states,
        defaultCondition = "hydrated",
        conditionValueDataField = "thirst",
        color = rgbToColor(0, 143, 179),
    },
    sleep = {
        blockID = tes3ui.registerID("Ashfall:sleepUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:sleepFillBar"),
        conditionID = tes3ui.registerID("Ashfall:sleepConditionId"),
        showUIFunction = this.showThirst,
        conditionTypes = common.conditions.sleep.states,
        defaultCondition = "rested",
        conditionValueDataField = "sleep",
        color = rgbToColor(0, 204, 0),
        reverseDirection = true,
    },
    needsBlock = tes3ui.registerID("Ashfall:needsBlock"),
}

local function updateNeedsBlock(menu, data)

    local block = menu:findChild(data.blockID)
    
    if not data.showUIFunction() then
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
        local condition = common.data.currentStates[data.conditionValueDataField] or data.defaultCondition
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
        local needsBlock = inventoryMenu:findChild(this.UIData.needsBlock)
        local needsActive = (
            common.data.mcmSettings.enableHunger or
            common.data.mcmSettings.enableThirst or
            common.data.mcmSettings.enableSleep 
        )
        needsBlock.visible = needsActive
        --Update UIs
        updateNeedsBlock(inventoryMenu, this.UIData.hunger)
        updateNeedsBlock(inventoryMenu, this.UIData.thirst)
        updateNeedsBlock(inventoryMenu, this.UIData.sleep)

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
    local needsBlock = startingBlock:findChild(this.UIData.needsBlock)
    if needsBlock then
        needsBlock:destroyChildren()
    else
        needsBlock = startingBlock:createThinBorder({id = this.UIData.needsBlock})
    end  

    setupNeedsBlock(needsBlock)

    --Hunger
    local hungerBlock = needsBlock:createBlock({id = this.UIData.hunger.blockID})
    setupNeedsElementBlock(hungerBlock)

    local hungerBar = hungerBlock:createFillBar({ id = this.UIData.hunger.fillBarID, current = 100, max = 100 })
    setupNeedsBar(hungerBar)
    hungerBar.widget.fillColor = this.UIData.hunger.color

    local hungerConditionLabel = hungerBlock:createLabel({ id = this.UIData.hunger.conditionID, text = "Satiated"})
    setupConditionLabel(hungerConditionLabel)


    --Thirst
    local thirstBlock = needsBlock:createBlock({id = this.UIData.thirst.blockID})
    setupNeedsElementBlock(thirstBlock)

    local thirstBar = thirstBlock:createFillBar({ id = this.UIData.thirst.fillBarID, current = 100, max = 100 })
    setupNeedsBar(thirstBar)
    thirstBar.widget.fillColor = this.UIData.thirst.color


    local thirstConditionLabel = thirstBlock:createLabel({ id = this.UIData.thirst.conditionID, text = "Hydrated"})
    setupConditionLabel(thirstConditionLabel)


    --Sleep
    local sleepBlock = needsBlock:createBlock({id = this.UIData.sleep.blockID})
    setupNeedsElementBlock(sleepBlock)

    local sleepBar = sleepBlock:createFillBar({ id = this.UIData.sleep.fillBarID, current = 100, max = 100})
    setupNeedsBar(sleepBar)
    sleepBar.widget.fillColor = this.UIData.sleep.color

    local sleepConditionLabel = sleepBlock:createLabel({ id = this.UIData.sleep.conditionID, text = "Rested"})
    setupConditionLabel(sleepConditionLabel)

    this.updateNeedsUI()
end


function this.addNeedsBlockToMenu(e, need)
    local data = this.UIData[need]
    if not data.showUIFunction() then
        --this need is disabled
        return
    end

    local block = e.element:createBlock()
    setupNeedsElementBlock(block) 
    block.maxWidth = 250
    block.borderTop = 10

    local sleepValue = common.data[need]
    local fillBar = block:createFillBar({current = sleepValue, max = 100})
    setupNeedsBar(fillBar)

    fillBar.widget.fillColor = this.UIData[need].color

    local conditionText = common.conditions[need].states[common.data.currentStates[need]].text

    local conditionLabel = block:createLabel({ id = this.UIData[need].conditionID, text = conditionText})
    setupConditionLabel(conditionLabel)
    updateNeedsBlock(e.element, this.UIData[need])
end



event.register("uiCreated", createNeedsUI, { filter = "MenuInventory" } )







return this
