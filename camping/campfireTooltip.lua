local common = require ("mer.ashfall.common.common")
------------------
--Tooltips
-----------------
local function updateTooltip(e)
    common.log:trace("Campfire tooltip")
    local function centerText(element)
        element.autoHeight = true
        element.autoWidth = true
        element.wrapText = true
        element.justifyText = "center" 
    end
    local label = e.label
    local labelBorder = e.element
    local campfire = e.reference
    local parentNode = e.parentNode

    --Do some fancy campfire stuff
    local attachments = {
        "Grill",
        "Kettle",
        "Cooking Pot",
        "Supports",
    }
    local attachment = parentNode.name
    if table.find(attachments, attachment) then
        label.text = attachment
    end

    --Add special fields
    if label.text == "Campfire" then
        local fuelLevel = ( campfire.data.fuelLevel or 0 )
        if fuelLevel and fuelLevel > 0 then
            local fuelLabel = labelBorder:createLabel{
                text = string.format("Fuel: %.1f hours", fuelLevel )
            }
            centerText(fuelLabel)
        end
    elseif label.text == "Kettle" or label.text == "Cooking Pot" then
        local waterAmount = campfire.data.waterAmount
        if waterAmount then
            --WATER
            local waterHeat = campfire.data.waterHeat or 0
            local waterLabel = labelBorder:createLabel{
                text = string.format(
                    "Water: %d/%d %s| Heat: %d/100", 
                    math.ceil(waterAmount), 
                    common.staticConfigs.capacities.cookingPot, 
                    ( campfire.data.waterDirty and "(Dirty) " or ""),
                    waterHeat)
            }
            centerText(waterLabel)

            if campfire.data.stewLevels then

                labelBorder:createDivider()

                local progress = ( campfire.data.stewProgress or 0 )
                local progressText

                if campfire.data.waterHeat < common.staticConfigs.hotWaterHeatValue then
                    progressText = "Stew (Cold)"
                elseif progress < 100 then
                    progressText = string.format("Stew (%d%% Cooked)", progress ) 
                else 
                    progressText = "Stew (Cooked)"
                end
                local stewProgressLabel = labelBorder:createLabel({ text = progressText })
                stewProgressLabel.color = tes3ui.getPalette("header_color")
                centerText(stewProgressLabel)

                
                for name, ingredLevel in pairs(campfire.data.stewLevels) do
                    local value = math.min(ingredLevel, 100)
                    local stewBuff = common.staticConfigs.foodConfig.stewBuffs[name]
                    local spell = tes3.getObject(stewBuff.id)
                    local effect = spell.effects[1]

                    local ingredText = string.format("(%d%% %s)", value, name )
                    local ingredLabel

                    if progress >= 100 then
                        local block = labelBorder:createBlock{}
                        block.autoHeight = true
                        block.autoWidth = true
                        block.childAlignX = 0.5

                        
                        local image = block:createImage{path=("icons\\" .. effect.object.icon)}
                        image.wrapText = false
                        image.borderLeft = 4

                        --"Fortify Health"
                        local statName
                        if effect.attribute ~= -1 then
                            local stat = effect.attribute
                            statName = tes3.findGMST(888 + stat).value
                        elseif effect.skill ~= -1 then
                            local stat = effect.skill
                            statName = tes3.findGMST(896 + stat).value
                        end
                        local effectNameText
                        local effectName = tes3.findGMST(1283 + effect.id).value
                        if statName then
                            effectNameText = effectName:match("%S+") .. " " .. statName
                        else
                            effectNameText = effectName
                        end
                        --points " 25 points "
                        local pointsText = string.format("%d pts", common.helper.calculateStewBuffStrength(value, stewBuff.min, stewBuff.max) )
                        --for X hours
                        local duration = common.helper.calculateStewBuffDuration()
                        local hoursText = string.format("for %d hour%s", duration, (duration >= 2 and "s" or "") )

                        ingredLabel = block:createLabel{text = string.format("%s %s: %s %s %s", spell.name, ingredText, effectNameText, pointsText, hoursText) }
                        ingredLabel.wrapText = false
                        ingredLabel.borderLeft = 4
                    else
                        ingredLabel = labelBorder:createLabel{text = ingredText }
                        centerText(ingredLabel)
                    end
                end
            end
        end
    end
end

event.register("Ashfall:Activator_tooltip", updateTooltip, { filter = "campfire" })