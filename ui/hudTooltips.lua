local this = {}
local common = require("mer.ashfall.common.common")

--Generic Tooltip with header and description
local function createTooltip(thisHeader, thisLabel)
    local tooltip = tes3ui.createTooltipMenu()
    
    local outerBlock = tooltip:createBlock({ id = tes3ui.registerID("Ashfall:temperatureIndicator_outerBlock") })
    outerBlock.flowDirection = "top_to_bottom"
    outerBlock.paddingTop = 6
    outerBlock.paddingBottom = 12
    outerBlock.paddingLeft = 6
    outerBlock.paddingRight = 6
    outerBlock.width = 300
    outerBlock.autoHeight = true    
    
    local headerText = thisHeader
    local headerLabel = outerBlock:createLabel({ id = tes3ui.registerID("Ashfall:temperatureIndicator_header"), text = headerText })
    headerLabel.autoHeight = true
    headerLabel.width = 285
    headerLabel.color = tes3ui.getPalette("header_color")
    headerLabel.wrapText = true
    --header.justifyText = "center"
    
    local descriptionText = thisLabel
    local descriptionLabel = outerBlock:createLabel({ id = tes3ui.registerID("Ashfall:temperatureIndicator_description"), text = descriptionText })
    descriptionLabel.autoHeight = true
    descriptionLabel.width = 285
    descriptionLabel.wrapText = true   
    
    tooltip:updateLayout()
end


function this.wetnessIndicator()
    if not common.data then return end
    if not common.conditions.wetness.states[common.data.currentStates.wetness] then return end

    local headerText = "Wet level: " .. common.conditions.wetness.states[common.data.currentStates.wetness].text--:lower()
    local labelText = "The wetter you are, the longer it takes to warm up, the quicker you cool down, and the more susceptible you are to shock damage."
    createTooltip(headerText, labelText)

end

function this.conditionIndicator()
    if not common.data then return end
    if not common.conditions.temp.states[common.data.currentStates.wetness] then return end 
    
    local headerText = "Condition: " .. common.conditions.temp.states[common.data.currentStates.wetness].text--:lower()
    local labelText = "The player's current condition, determined by Player Temperature."
    createTooltip(headerText, labelText)
end
function this.playerLeftIndicator()
    local headerText = string.format("Player Temperature: %.2f", common.data.temp )
    local labelText = "The player's current temperature. This directly determines hot and cold condition effects."
    createTooltip(headerText, labelText)
end
function this.playerRightIndicator()
    local headerText = string.format("Player Temperature: %.2f", common.data.temp  )
    local labelText = "Directly determines hot and cold condition effects."
    createTooltip(headerText, labelText)  
end

function this.limitLeftIndicator()
    local headerText = string.format("Temperature Limit: %.2f", common.data.tempLimit)
    local labelText = "Represents the temperature the player will reach if the current conditions remain."
    createTooltip(headerText, labelText)
end

function this.limitRightIndicator()
    local headerText = string.format("Temperature Limit: %.2f", common.data.tempLimit)
    local labelText = "Represents the temperature the player will reach if the current conditions remain."
    createTooltip(headerText, labelText)
end

return this