local this = {}

local common = require("mer.ashfall.common.common")
local tooltips = require("mer.ashfall.ui.hudTooltips")
local needsUI = require("mer.ashfall.needs.needsUI")

local IDs = {
    
    mainHUDBlock = tes3ui.registerID("Ashfall:HUD_mainHUDBlock"),
    outerBlock = tes3ui.registerID("Ashfall:HUD_outerBlock"),
    topHUDBlock = tes3ui.registerID("Ashfall:HUD_topHUDBlock"),
    wetnessBlock = tes3ui.registerID("Ashfall:HUD_wetnessBlock"),
    wetnessBar = tes3ui.registerID("Ashfall:HUD_wetnessBar"),
    conditionLabelBlock = tes3ui.registerID("Ashfall:HUD_conditionLabelBlock"),
    conditionLabel = tes3ui.registerID("Ashfall:HUD_conditionLabel"),
    conditionIcon = tes3ui.registerID("Ashfall:HUD_conditionIcon"),
    leftTempPlayerBar = tes3ui.registerID("Ashfall:HUD_leftTempPlayerBar"),
    rightTempPlayerBar = tes3ui.registerID("Ashfall:HUD_rightTempPlayerBar"),
    leftTempLimitBar = tes3ui.registerID("Ashfall:HUD_leftTempLimitBar"),
    rightTempLimitBar = tes3ui.registerID("Ashfall:HUD_rightTempLimitBar"),

    needsBlock = tes3ui.registerID("Ashfall:HUD_NeedsBlock"),
    hunger = tes3ui.registerID("Ashfall:HUD_HungerBar"),
    thirst = tes3ui.registerID("Ashfall:HUD_ThirstBar"),
    sleep = tes3ui.registerID("Ashfall:HUD_SleepBar"),


    healthBlocker = tes3ui.registerID("Ashfall:HUD_healthBlocker"),
    magicBlocker = tes3ui.registerID("Ashfall:HUD_magicBlocker"),
    fatigueBlocker = tes3ui.registerID("Ashfall:HUD_fatigueBlocker"),
}

local function findHUDElement(id)
    local multiMenu = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
    return multiMenu:findChild( id )
end


function this.updateHUD()
    if not common.data then return end
    local mainHUDBlock = findHUDElement(IDs.mainHUDBlock)

    --Hide HUD if Ashfall is disabled
    if common.data.mcmSettings.enableTemperatureEffects then
        mainHUDBlock.visible = true

        local outerBlock = findHUDElement(IDs.outerBlock)
        if outerBlock then
            --Get values
            local tempPlayer = math.clamp((common.data.temp or 0), -100, 100) or 0
            local tempLimit = math.clamp((common.data.tempLimit), -100, 100) or 0

            local condition = common.config.conditions.temp.states[( common.data.currentStates.temp  or "comfortable" )].text
            local wetness = common.data.wetness or 0
            wetness = math.clamp(wetness, 0, 100) or 0


            local conditionLabel = findHUDElement(IDs.conditionLabel)
            conditionLabel.text = condition


            --Update Temp Player bars
            local leftTempPlayerBar = findHUDElement(IDs.leftTempPlayerBar)
            local rightTempPlayerBar = findHUDElement(IDs.rightTempPlayerBar)
            --Cold
            if tempPlayer < 0 then

                leftTempPlayerBar.widget.fillColor = {0.3, 0.5, (0.75 + tempPlayer/400)} --Bluish
                leftTempPlayerBar.widget.current = tempPlayer
                --hack
                local bar = leftTempPlayerBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
                bar.width = (tempPlayer / 100) * leftTempPlayerBar.width        
                rightTempPlayerBar.widget.current = 0
            --Hot:
            else
                rightTempPlayerBar.widget.fillColor = {(0.75 + tempPlayer/400), 0.3, 0.2}
                rightTempPlayerBar.widget.current = tempPlayer
                local bar = leftTempPlayerBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
                bar.width = 0
            end

            --Update Temp Limit bars
            local leftTempLimitBar = findHUDElement(IDs.leftTempLimitBar)
            local rightTempLimitBar = findHUDElement(IDs.rightTempLimitBar)
            if tempLimit < 0 then
                leftTempLimitBar.widget.fillColor = {0.3, 0.5, (0.75 + tempLimit/400)} --Bluish
                leftTempLimitBar.widget.current = tempLimit
                --hack
                local bar = leftTempLimitBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
                bar.width = (tempLimit / 100) * leftTempLimitBar.width        
                rightTempLimitBar.widget.current = 0
            --Hot:
            else
                rightTempLimitBar.widget.fillColor = {(0.75 + tempLimit/400), 0.3, 0.2}
                rightTempLimitBar.widget.current = tempLimit
                local bar = leftTempLimitBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
                bar.width = 0
            end

            local wetnessBar = findHUDElement(IDs.wetnessBar)
            wetnessBar.widget.current = wetness

            outerBlock:updateLayout()
        end
    else
        mainHUDBlock.visible = false
    end

    local needsBlock = findHUDElement(IDs.needsBlock)
    if needsBlock then
        
        --Hide or show based on mcmSettings
        local hasNeeds = (
            common.data.mcmSettings.enableHunger or
            common.data.mcmSettings.enableThirst or
            common.data.mcmSettings.enableSleep
        )
        if hasNeeds then
            needsBlock.visible = true

            --HUNGER
            local hungerBar = findHUDElement(IDs.hunger)
            local hunger = common.data.hunger or 0
            if needsUI.showHunger() then
                local newHunger = ( ( 1 - hunger / 100 ) * hungerBar.parent.height)
                hungerBar.height = newHunger
                hungerBar.parent.visible = true
            else
                hungerBar.parent.visible = false
            end

            --THIRST
            local thirstBar = findHUDElement(IDs.thirst)
            local thirst = common.data.thirst or 0
            if needsUI.showThirst()  then
                local newThirst = ( (1 - thirst / 100 ) * thirstBar.parent.height)
                thirstBar.height = newThirst
                thirstBar.parent.visible = true
            else
                thirstBar.parent.visible = false
            end

            --SLEEP
            local sleepBar = findHUDElement(IDs.sleep)
            local sleep = common.data.sleep or 100
            if needsUI.showSleep() then
                local newSleep = ( ( sleep / 100 ) * sleepBar.parent.height)
                sleepBar.height = newSleep
                sleepBar.parent.visible = true
            else
                sleepBar.parent.visible = false
            end

            needsBlock:updateLayout()
        else
            needsBlock.visible = false
        end
        
       

    end

end


local function quickFormat(element, padding)
    element.paddingAllSides = padding
    element.autoHeight = true
    element.autoWidth = true
    return element
end


local function createTempHUD(parent)
    local tempBarWidth = 70
    local tempBarHeight = 10
    local limitBarHeight = 12

        ---\
            --fill background of outerBlock with blackj
            local colorBlock = parent:createRect({color = tes3ui.getPalette("black_color")})
            colorBlock.flowDirection = "top_to_bottom"
            colorBlock = quickFormat(colorBlock, 0)
        
            ---\
                ---MID BLOCK
                local tempIndicatorBlock = colorBlock:createBlock()
                tempIndicatorBlock.flowDirection = "left_to_right"
                tempIndicatorBlock = quickFormat(tempIndicatorBlock, 0)
                ---\    
                    local leftTempIndicatorBlock = tempIndicatorBlock:createBlock()
                    leftTempIndicatorBlock.flowDirection = "top_to_bottom"
                    leftTempIndicatorBlock = quickFormat(leftTempIndicatorBlock, 0)
                    ---\
                        --Left Player Bar
                        local leftTempPlayerBar = leftTempIndicatorBlock:createFillBar({id = IDs.leftTempPlayerBar, current = 50, max = 100})
                        leftTempPlayerBar:register( "help", tooltips.playerLeftIndicator )
                        leftTempPlayerBar.widget.showText = false
                        leftTempPlayerBar.height = tempBarHeight
                        leftTempPlayerBar.width = tempBarWidth
                        leftTempPlayerBar.borderBottom = 0
                        --Reverse direction of left bar
                        leftTempPlayerBar.paddingAllSides = 2
                        local bar = leftTempPlayerBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
                        bar.layoutOriginFractionX = 1.0    
                        
                    ---\    
                        --Left tempLimit bar
                        local leftTempLimitBar = leftTempIndicatorBlock:createFillBar({id = IDs.leftTempLimitBar, current = 50, max = 100})
                        leftTempLimitBar:register( "help", tooltips.limitLeftIndicator )
                        leftTempLimitBar.widget.showText = false
                        leftTempLimitBar.height = limitBarHeight
                        leftTempLimitBar.width = tempBarWidth
                        --Reverse direction of left bar
                        leftTempLimitBar.paddingAllSides = 2
                        bar = leftTempLimitBar:findChild(tes3ui.registerID("PartFillbar_colorbar_ptr"))
                        bar.layoutOriginFractionX = 1.0                
                        
                ---\        
                    --[[local centretempIndicatorBlock = tempIndicatorBlock:createThinBorder({"Ashfall:centretempIndicatorBlock"})
                    --centretempIndicatorBlock.flowDirection = "top_to_bottom"
                    centretempIndicatorBlock = quickFormat(centretempIndicatorBlock, 2)
                    
                    --cond icon: color based on player condition
                    local conditionIcon = centretempIndicatorBlock:createImage({id = IDs.conditionIcon, path="Textures/Ashfall/indicators/chilly.dds"})
                    conditionIcon.height = tempBarHeight + limitBarHeight - 4
                    conditionIcon.width = 5
                    conditionIcon.scaleMode = true]]--
                    
                ---\        
                    local righttempIndicatorBlock = tempIndicatorBlock:createBlock()
                    righttempIndicatorBlock.flowDirection = "top_to_bottom"
                    righttempIndicatorBlock = quickFormat(righttempIndicatorBlock, 0)        
                    ---\
                        --Right Color Bar
                        local rightTempPlayerBar = righttempIndicatorBlock:createFillBar({id = IDs.rightTempPlayerBar, max = 100})
                        rightTempPlayerBar:register( "help", tooltips.playerRightIndicator )
                        rightTempPlayerBar.widget.showText = false
                        rightTempPlayerBar.height = tempBarHeight
                        rightTempPlayerBar.width = tempBarWidth
                        rightTempPlayerBar.borderBottom = 0
                        
                    --\    
                        --Right tempLimit bar
                        local rightTempLimitBar = righttempIndicatorBlock:createFillBar({id = IDs.rightTempLimitBar , current = 50, max = 100})
                        rightTempLimitBar:register( "help", tooltips.limitRightIndicator )
                        rightTempLimitBar.widget.showText = false
                        rightTempLimitBar.height = limitBarHeight
                        rightTempLimitBar.width = tempBarWidth
end

local function createVerticalNeedsBar(parent, need)

    local function darkenColor(color)
        local multi = 0.8
        return { 
            color[1] * multi, 
            color[2] * multi, 
            color[3] * multi,
        }
    end

    local data = needsUI.UIData[need]
    local block = parent:createBlock()
    block.flowDirection = "top_to_bottom"
    block.heightProportional = 1.0
    block.autoWidth = true

    local fillbar = block:createThinBorder()
    fillbar.autoWidth = true
    fillbar.heightProportional = 1.0
    fillbar.paddingAllSides = 2

    local filler = fillbar:createRect({ id = IDs[need] })
    filler.color = darkenColor(data.color)
    filler.width = 5
    filler.absolutePosAlignY = 1.0
    filler.height = 0

    --[[local shadow = fillbar:createImage({ path = "icons/ashfall/UI/vertical_shadow.dds"})
    shadow.absolutePosAlignY = 0.0
    shadow.absolutePosAlignX = 0.0
    shadow.heightProportional = true
    shadow.widthProportional = true
    shadow.scaleMode = true]]--
end


local function createNeedsHUD(parent)

    local needsBlock = parent:createRect({ id = IDs.needsBlock})
    needsBlock.heightProportional = 1.0
    needsBlock.autoWidth = true
    needsBlock.borderAllSides = 2

    createVerticalNeedsBar(needsBlock, "hunger")

    createVerticalNeedsBar(needsBlock, "thirst")

    createVerticalNeedsBar(needsBlock, "sleep")


end





local topBlockID = tes3ui.registerID("Ashfall:topBlock")
local function createHUD(e)
    if not e.newlyCreated then return end


    local multiMenu = e.element

    -- Find the UI element that holds the sneak icon indicator.
    local mainBlock = multiMenu:findChild(tes3ui.registerID("MenuMulti_weapon_layout")).parent.parent.parent




    local mainHUDBlock = mainBlock:createBlock({id = IDs.mainHUDBlock})
    
    createNeedsHUD(mainBlock)
    
    mainHUDBlock = quickFormat(mainHUDBlock, 2)
    --mainHUDBlock.layoutOriginFractionX = 0
    mainHUDBlock.flowDirection = "top_to_bottom"
    ---\
        ---TOPBLOCK - Wetness Indicator and Condition state---
        local topBlock = mainHUDBlock:createBlock({id = IDs.topHUDBlock})

        topBlock.flowDirection = "left_to_right"
        topBlock = quickFormat(topBlock, 0)
        ---\
            ---WETNESS INDICATOR---    
            local wetnessBlock = topBlock:createBlock({id = IDs.wetnessBlock})
            --Register Tooltip
            wetnessBlock:register("help", tooltips.wetnessIndicator )
            wetnessBlock = quickFormat(wetnessBlock, 0)
            ---\
                local wetnessBackground = wetnessBlock:createRect({color = {0.0, 0.05, 0.1} })
                wetnessBackground.height = 20
                wetnessBackground.width = 36
                wetnessBackground.layoutOriginFractionX = 0.0
            
            ---\
                local wetnessBar = wetnessBlock:createFillBar({id = IDs.wetnessBar, current = 50, max = 100})
                wetnessBar.widget.fillColor = {0.5, 1.0, 1.0}
                wetnessBar.widget.showText = false
                wetnessBar.height = 20
                wetnessBar.width = 36
                wetnessBar.layoutOriginFractionX = 0.0
    
            ---\
                local wetnessIcon = wetnessBlock:createImage({path="Textures/Ashfall/indicators/wetness.dds"})
                wetnessIcon.height = 16
                wetnessIcon.width = 32
                wetnessIcon.borderAllSides = 2
                wetnessBar.layoutOriginFractionX = 0.0
            
            
            ---CONDITION STATE---    
            local conditionLabelBlock = topBlock:createBlock({id = IDs.conditionLabelBlock})

            conditionLabelBlock = quickFormat(conditionLabelBlock, 0)
            conditionLabelBlock.paddingLeft = 2
            ---\
                local conditionLabel = conditionLabelBlock:createLabel({id = IDs.conditionLabel, text = "Comfortable" })
                --register tooltip
                conditionLabel:register("help", tooltips.conditionIndicator )

                
    ---\        
        ---OUTER FRAME - sits below wetness and condition, houses temperature fillbars---
        outerBlock = mainHUDBlock:createThinBorder({id = IDs.outerBlock})
        outerBlock.flowDirection = "top_to_bottom"
        outerBlock = quickFormat(outerBlock, 0)
        createTempHUD(outerBlock)

        mainBlock:reorderChildren(1, -2, 2)

end




local function createUI(e)
    createHUD(e)
end



event.register("uiActivated", createUI, { filter = "MenuMulti" })

return this