local common = require ("mer.ashfall.common.common")

local function onActivate(e)
    
    if not e.activator.hasMenu then return end

    local campfire = e.ref
    local node = e.node

    local addButton = function(tbl, button)
        if button.requirements(campfire) then
            table.insert(tbl, {
                text = button.text, 
                callback = function()
                    button.callback(campfire)
                end
            })
        end
    end

    local buttons = {}
    --Add contextual buttons
    local buttonList = buttonMapping.Campfire
    local text = "Campfire"
    --If looking at an attachment, show buttons for it instead
    if buttonMapping[node.name] then
        buttonList = buttonMapping[node.name]
        text = node.name
    end

    for _, buttonType in ipairs(buttonList) do
        local button = require(string.format("mer.ashfall.camping.menuFunctions.%s", buttonType))
        addButton(buttons, button)
    end
    common.helper.messageBox({ message = text, buttons = buttons })
end

event.register( "Ashfall:ActivatorActivated", onActivate)