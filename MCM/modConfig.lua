local common = require ("mer.ashfall.common")
local optionData = require ( "mer.ashfall.MCM.optionData")
local modConfig = {}
 
local configPath = "config/ashfall/mcm_config"

local config = json.loadfile(configPath)
if (not config) then
	config = {

	}
end


local uids = {
    sideBarText = tes3ui.registerID("Ashfall:MCM_SidebarText")
}


local sideBarDefaultText = (
    "Welcome to Ashfall, the ultimate survival mod for Morrowind! \n\n" ..
    "Use the configuration menu to turn various mechanics, features and udpate messages on or off.\n\n" ..
    "Hover over individual options to see more information."
)

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

    data[option.id] = not data[option.id]
    e.source.text = getOnOffFromBool (data[option.id])
end

local function formatBlock(block)
    block.layoutWidthFraction = 1.0
    block.autoHeight = true
    block.flowDirection = "top_to_bottom"
    block.paddingAllSides = 2
end


local function updateSideBar(params)
    local menu = tes3ui.findMenu(tes3ui.registerID("MWSE:ModConfigMenu"))
    local sideBarText = menu:findChild(uids.sideBarText)
    if params then
        sideBarText.text = (
            params.label .. 
            ":\n\n" ..    
            params.description
        )
    else
        sideBarText.text = sideBarDefaultText
    end
    menu:updateLayout()
end


local function createSideBar(parentBlock)
    local sideBarBlock = parentBlock:createBlock()
    sideBarBlock.widthProportional = 1.0
    sideBarBlock.heightProportional = 1.0
    sideBarBlock.borderAllSides = 10
    

    sideBarText = sideBarDefaultText
    local words = sideBarBlock:createLabel({id= uids.sideBarText, text = sideBarText})
    words.widthProportional = 1.0
    words.heightProportional = 1.0
    words.wrapText = true
    
end

local function registerMouseOvers(params)
    --[[
        params:
            bloack
            label
            description
    ]]--
    params.block:register("mouseOver", function() updateSideBar({label = params.label, description = params.description}) end )
    params.block:register("mouseLeave", function() updateSideBar() end )
end

local function createBlockIntro(params)
    --[[
        params:
            Element block
            String label
            String description (optional)
    ]]--

    if not params.parentBlock then
        mwse.log("[Ashfall.modConfig ERROR] createBlockIntro(): no block given")
        return
    elseif not params.label and not params.description then
        mwse.log("[Ashfall.modConfig ERROR] createBlockIntro(): no label or description given")
        return
    end

    local block = params.parentBlock:createBlock()
    formatBlock(block)

    local label = nil
    if params.label then
        label = params.parentBlock:createLabel({text = params.label})
        label.color = tes3ui.getPalette("header_color")
        label.borderBottom = 5
        registerMouseOvers({ block = label, label = params.label, description = params.description})
    end


    return { block = block, label = label }
   
end


--Creates On/Off MCM option with label on the left and button on the right--
local function makeOnOffButton(params)
    mwse.log("Making new button")
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

    local button = buttonBlock:createButton({ text = "---"})--getOnOffFromBool(false)})
    
    local label = buttonBlock:createLabel({ text = option.label })
    label.borderAllSides = 4
    label.wrapText = true
    label.widthProportional = 1.0

    --registerMouseOvers({block = buttonBlock,  label = option.label, description = option.description})
    --registerMouseOvers({block = button,  label = option.label, description = option.description})
    registerMouseOvers({block = label,  label = option.label, description = option.description})
    
      

    local inGame = tes3.player
    --Disable in menu for local options
    if option.isLocalOption and not inGame then
        button.widget.state = 2
        label.color = tes3ui.getPalette("disabled_color")
    else
        --not disabled, so activate button
        local data = getOptionData(option)
        local bool = data[option.id]

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


local function createOptionsBlock(parentBlock, optionsObject)
    mwse.log("Creating options block")
    mwse.log("Label: %s", optionsObject.label)
    local intro = createBlockIntro{
        parentBlock = parentBlock,
        label = optionsObject.label,
        description = optionsObject.description
    }
    for _, option in ipairs( optionsObject.options ) do
        makeOnOffButton( {block = parentBlock, option = option} )
    end
end


local function createIngameOptionsBlock(parentBlock)

    local inGameOptionsBlock = parentBlock:createBlock()
    inGameOptionsBlock.flowDirection = "top_to_bottom"
    inGameOptionsBlock.widthProportional = 1.0
    inGameOptionsBlock.autoHeight = true
    inGameOptionsBlock.borderAllSides = 10
    
    local mainIntro = createBlockIntro{
        parentBlock = inGameOptionsBlock,
        label = "In Game Options",
        description = "These options are specific to each save file and can only be edited in-game."
    }
    mainIntro.label.absolutePosAlignX = 0.5


    createOptionsBlock(inGameOptionsBlock, optionData.general)
    createOptionsBlock(inGameOptionsBlock, optionData.updates)
    createOptionsBlock(inGameOptionsBlock, optionData.misc)


    --Grey out label/description if not in game
    if not tes3.player then
        for _, element in ipairs(inGameOptionsBlock.children) do
            if element.color then 
                element.color = tes3ui.getPalette("disabled_color")
            end
        end

    end
end


---CREATE MCM---
function modConfig.onCreate(mcmContainer)

    local outerBlock = mcmContainer:createThinBorder()
    outerBlock.flowDirection = "top_to_bottom"
    outerBlock.paddingAllSides = 4
    outerBlock.widthProportional = 1.0
    outerBlock.heightProportional = 1.0
    

    local headerBlock = outerBlock:createBlock()
    headerBlock.autoHeight = true
    headerBlock.widthProportional = 1.0

    local headerImage = headerBlock:createImage({path = "textures/ashfall/MCMHeader.tga"})
    headerImage.absolutePosAlignX = 0.5
    headerImage.imageScaleX = 0.5
    headerImage.imageScaleY = 0.5

 

    local sideBySideBlock = outerBlock:createBlock()
    sideBySideBlock.flowDirection = "left_to_right"
    sideBySideBlock.heightProportional = 1.0
    sideBySideBlock.widthProportional = 1.0

    local leftColumn = sideBySideBlock:createVerticalScrollPane()
    leftColumn.heightProportional = 1.0
    leftColumn.widthProportional = 1.0
    leftColumn.borderAllSides = 2
    createIngameOptionsBlock(leftColumn)

    local rightColumn = sideBySideBlock:createThinBorder()
    rightColumn.heightProportional = 1.0
    rightColumn.widthProportional = 1.0
    rightColumn.borderAllSides = 2
    createSideBar(rightColumn)

    mcmContainer:updateLayout()
end

--Save when closing MCM--
function modConfig.onClose(mcmContainer)
	mwse.log("[merlord-Ashfall] Saving mod configuration:")
	mwse.log(json.encode(config, { indent = true }))
	json.savefile(configPath, config, { indent = true })
end


return modConfig