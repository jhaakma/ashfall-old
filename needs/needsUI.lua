--[[
    Needs displayed in stats menu
]]--
local this = {}
local common = require("mer.ashfall.common.common")
local conditionConfig = common.staticConfigs.conditionConfig

local function rgbToColor(r, g, b)
    return { (r/255), (g/255), (b/255) }
end

function this.showThirst()
    return (
        common.config.getConfig().enableThirst and 
        common.config.getConfig().thirstRate > 0
    )
end

function this.showHunger()
    return (
        common.config.getConfig().enableHunger and 
        common.config.getConfig().hungerRate > 0
    )
end

function this.showTiredness()
    return (
        common.config.getConfig().enableTiredness and 
        common.config.getConfig().loseSleepRate > 0
    )
end

this.UIData = {
    hunger = {
        blockID = tes3ui.registerID("Ashfall:hungerUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:hungerFillBar"),
        conditionID = tes3ui.registerID("Ashfall:hungerConditionId"),
        showUIFunction = this.showHunger,
        conditionTypes = conditionConfig.hunger.states,
        defaultCondition = "wellFed",
        need = "hunger",
        color = rgbToColor(230, 92, 0),
    },
    thirst = {
        blockID = tes3ui.registerID("Ashfall:thirstUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:thirstFillBar"),
        conditionID = tes3ui.registerID("Ashfall:thirstConditionId"),
        showUIFunction = this.showThirst,
        conditionTypes = conditionConfig.thirst.states,
        defaultCondition = "hydrated",
        need = "thirst",
        color = rgbToColor(0, 143, 179),
    },
    tiredness = {
        blockID = tes3ui.registerID("Ashfall:sleepUIBlock"),
        fillBarID = tes3ui.registerID("Ashfall:sleepFillBar"),
        conditionID = tes3ui.registerID("Ashfall:sleepConditionId"),
        showUIFunction = this.showTiredness,
        conditionTypes = conditionConfig.tiredness.states,
        defaultCondition = "rested",
        need = "tiredness",
        color = rgbToColor(0, 204, 0),
    },
    needsBlock = tes3ui.registerID("Ashfall:needsBlock"),
}

local function updateNeedsBlock(menu, data)
    local need = conditionConfig[data.need]

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
        conditionLabel.text =  need:getCurrentStateData().text
            
        --update fillBar
        local needsLevel
        needsLevel = need:getValue()
        fillBar.widget.current = need.max - needsLevel
    end
end

function this.updateNeedsUI()
    if not common.data then return end
    local inventoryMenu = tes3ui.findMenu(tes3ui.registerID("MenuInventory"))

    if inventoryMenu then   
        --Check Ashfall active
        local needsBlock = inventoryMenu:findChild(this.UIData.needsBlock)
        local needsActive = (
            common.config.getConfig().enableHunger or
            common.config.getConfig().enableThirst or
            common.config.getConfig().enableTiredness 
        )
        needsBlock.visible = needsActive
        --Update UIs
        updateNeedsBlock(inventoryMenu, this.UIData.hunger)
        updateNeedsBlock(inventoryMenu, this.UIData.thirst)
        updateNeedsBlock(inventoryMenu, this.UIData.tiredness)

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

    for _, needId in ipairs({"hunger", "thirst", "tiredness"}) do
        local data = this.UIData[needId]
        local need = conditionConfig[needId]

        local block = needsBlock:createBlock({id = data.blockID})
        setupNeedsElementBlock(block)

        local fillBar = block:createFillBar({ id = data.fillBarID, current = need.max, max = need.max })
        setupNeedsBar(fillBar)

        fillBar.widget.fillColor = data.color
    
        local conditionLabel = block:createLabel({ id = data.conditionID, text = need.states[need.default].text})
        setupConditionLabel(conditionLabel)
    end


    -- --Hunger
    -- local hungerBlock = needsBlock:createBlock({id = this.UIData.hunger.blockID})
    -- setupNeedsElementBlock(hungerBlock)

    -- local hungerBar = hungerBlock:createFillBar({ id = this.UIData.hunger.fillBarID, current = 100, max = 100 })
    -- setupNeedsBar(hungerBar)
    -- hungerBar.widget.fillColor = this.UIData.hunger.color

    -- local hungerConditionLabel = hungerBlock:createLabel({ id = this.UIData.hunger.conditionID, text = ""})
    -- setupConditionLabel(hungerConditionLabel)


    -- --Thirst
    -- local thirstBlock = needsBlock:createBlock({id = this.UIData.thirst.blockID})
    -- setupNeedsElementBlock(thirstBlock)

    -- local thirstBar = thirstBlock:createFillBar({ id = this.UIData.thirst.fillBarID, current = 100, max = 100 })
    -- setupNeedsBar(thirstBar)
    -- thirstBar.widget.fillColor = this.UIData.thirst.color


    -- local thirstConditionLabel = thirstBlock:createLabel({ id = this.UIData.thirst.conditionID, text = "Hydrated"})
    -- setupConditionLabel(thirstConditionLabel)


    -- --Sleep
    -- local sleepBlock = needsBlock:createBlock({id = this.UIData.tiredness.blockID})
    -- setupNeedsElementBlock(sleepBlock)

    -- local sleepBar = sleepBlock:createFillBar({ id = this.UIData.tiredness.fillBarID, current = 100, max = 100})
    -- setupNeedsBar(sleepBar)
    -- sleepBar.widget.fillColor = this.UIData.tiredness.color

    -- local sleepConditionLabel = sleepBlock:createLabel({ id = this.UIData.tiredness.conditionID, text = "Rested"})
    -- setupConditionLabel(sleepConditionLabel)

    this.updateNeedsUI()
end


function this.addNeedsBlockToMenu(e, needId)
    local need = conditionConfig[needId]
    local data = this.UIData[needId]
    if not data.showUIFunction() then
        --this need is disabled
        return
    end

    local block = e.element:createBlock()
    setupNeedsElementBlock(block) 
    block.maxWidth = 250
    block.borderTop = 10

    local needsValue = need.max - need:getValue()
    local fillBar = block:createFillBar({current = needsValue, max = need.max})
    setupNeedsBar(fillBar)

    fillBar.widget.fillColor = data.color

    local conditionText = need:getCurrentStateMessage()

    local conditionLabel = block:createLabel({ id = data.conditionID, text = conditionText})
    setupConditionLabel(conditionLabel)
    updateNeedsBlock(e.element, data)
end



event.register("uiCreated", createNeedsUI, { filter = "MenuInventory" } )







return this
