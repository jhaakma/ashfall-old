local common = require ("mer.ashfall.common")

local modConfig = {}

local configPath = "config/ashfall/mcm_config"

local config = json.loadfile(configPath)
if (not config) then
	config = {

	}
end


local uids = {

}

--OPTIONS DATA--
--[[
    label: descrition of option
    dataField: id of variable where option data is stored
    isLocalOption: if true, data is stored on player, game-save specific. Otherwise stored 
]]
local ashfallOptions = {
    { label = "Enable Temperature and Weather Effects", dataField = common.MCMOptionIds.enableAshfall, isLocalOption = true},
    { label = "Enable Hunger",                          dataField = common.MCMOptionIds.enableHunger, isLocalOption = true},
    { label = "Enable Thirst",                          dataField = common.MCMOptionIds.enableThirst, isLocalOption = true},
    { label = "Enable Sleep",                           dataField = common.MCMOptionIds.enableSleep, isLocalOption = true},
}


local updateOptions = {
    { label = "Temperature updates", dataField = common.MCMOptionIds.tempPlayer, isLocalOption = true },
    { label = "Hunger updates",      dataField = common.MCMOptionIds.showHunger, isLocalOption = true },
    { label = "Thirst updates",      dataField = common.MCMOptionIds.showThirst, isLocalOption = true },
    { label = "Sleep updates",       dataField = common.MCMOptionIds.showSleep, isLocalOption = true },
    { label = "Wetness updates",     dataField = common.MCMOptionIds.showWetness, isLocalOption = true },
}



--FUNCTIONS--

local function getOptionData(option)
    if option.isLocalOption then  
        if not common.data then 
            mwse.log("[Ashfall.modConfig ERROR] toggleYesNoButton(): Toggled ingame only option while not in game")
            return
        end
        return common.data.mcmOptions
    else
        return config
    end   
end

local function getOnOffFromBool (bool)
    --Returns "On" for true or "Off" for false--
    return bool and tes3.findGMST(tes3.gmst.sOn).value or tes3.findGMST(tes3.gmst.sOff).value
end

local function toggleYesNoButton(e, option)
    local data = getOptionData(option)

    data[option.dataField] = not data[option.dataField]
    e.source.text = getOnOffFromBool (data[option.dataField])
    mwse.log("dataField = %s, value = %s", option.dataField,  data[option.dataField])
 
end

local function formatBlock(block)
    block.layoutWidthFraction = 1.0
    block.autoHeight = true
    block.flowDirection = "top_to_bottom"
    block.paddingAllSides = 5
end

local function createBlockIntro(params)
    --[[
        params:
            Element block
            String header
            String description (optional)
    ]]--

    if not params.parentBlock then
        mwse.log("[Ashfall.modConfig ERROR] createBlockIntro(): no block given")
        return
    elseif not params.header and not params.description then
        mwse.log("[Ashfall.modConfig ERROR] createBlockIntro(): no header or description given")
        return
    end

    local block = params.parentBlock:createBlock()
    formatBlock(block)

    local header = nil
    if params.header then
        header = params.parentBlock:createLabel({text = params.header})
        header.color = tes3ui.getPalette("header_color")
        header.borderBottom = 5
    end

    local description = nil
    if params.description then
        description = params.parentBlock:createLabel({ text = params.description})
        description.borderLeft = 5
        description.borderBottom = 5
        description.layoutWidthFraction = 1.0
        description.wrapText = true
    end

    return { block = block, header = header, description = description }
   
end


--Creates On/Off MCM option with label on the left and button on the right--
local function makeOnOffButton(params)
    
    --[[
        params:
            Block block 
            Option option 
    ]]--
    if not params.block then
        mwse.log("[Ashfall.modConfig ERROR] makeOnOffButton(): no block given")
        return
    elseif not params.option then
        mwse.log("[Ashfall.modConfig ERROR] makeOnOffButton(): no option given")
        return
    end
    local block = params.block
    local option = params.option
    
    local buttonBlock
    buttonBlock = block:createBlock({})
    buttonBlock.flowDirection = "left_to_right"
    buttonBlock.widthProportional = 1.0
    buttonBlock.autoHeight = true

    local button = buttonBlock:createButton({ text = getOnOffFromBool(false)})
    
    local label = buttonBlock:createLabel({ text = option.label })
    label.borderAllSides = 3

    local inGame = tes3.player
    --Disable in menu for local options
    if option.isLocalOption and not inGame then
        mwse.log("isLocalOption: %s", option.isLocalOption)
        mwse.log("In game: %s", inGame)
        button.widget.state = 2
        label.color = tes3ui.getPalette("disabled_color")
    else
        --not disabled, so activate button
        local data = getOptionData(option)
        local bool = data[option.dataField]

        local buttonText = getOnOffFromBool (bool)
        button.text = buttonText
        button:register(
            "mouseClick", 
            function(e)
                toggleYesNoButton(e, option )
            end
        )		
    end

    return { buttonBlock = buttonBlock, label = label, button = button }
end



---CREATE MCM---
function modConfig.onCreate(mcmContainer)

    local outerBlock = mcmContainer:createBlock()
    formatBlock(outerBlock)




    --IN GAME OPTIONS--

    local inGameOptionsBlock = outerBlock:createThinBorder()
    formatBlock(inGameOptionsBlock)

    
    local mainIntro = createBlockIntro{
        parentBlock = inGameOptionsBlock,
        header = "In Game Options",
        description = "(Specific to each save file)"
    }
    mainIntro.header.absolutePosAlignX = 0.5
    mainIntro.description.absolutePosAlignX = 0.5

    local generalIntro = createBlockIntro{
        parentBlock = inGameOptionsBlock,
        header = "General Options"
    }
    for _, option in ipairs( ashfallOptions ) do
        makeOnOffButton( {block = inGameOptionsBlock, option = option} )
    end

    local conditionIntro = createBlockIntro({
        parentBlock = inGameOptionsBlock,
        header = "Condition Updates",
        description = "Display update messages when conditions change"
    })

    --Grey out header/description if not in game
    if not tes3.player then
        for _, element in ipairs(inGameOptionsBlock.children) do
            if element.color then 
                element.color = tes3ui.getPalette("disabled_color")
            end
        end

        --[[generalIntro.header.color = tes3ui.getPalette("disabled_color")
        conditionIntro.header.color = tes3ui.getPalette("disabled_color")
        conditionIntro.description.color = tes3ui.getPalette("disabled_color")]]--
    end

    for _, option in ipairs( updateOptions ) do
        makeOnOffButton( {block = inGameOptionsBlock, option = option, isLocalOption = true} )
    end



end

--Save when closing MCM--
function modConfig.onClose(mcmContainer)
	mwse.log("[merlord-Ashfall] Saving mod configuration:")
	mwse.log(json.encode(config, { indent = true }))
	json.savefile(configPath, config, { indent = true })
end


return modConfig