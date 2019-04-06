--[[
    Plugin: ashfall.esp
--]]

local function onLoaded()
    -- set global to disable mwscripts
    tes3.setGlobal("a_lua_enabled", 1)
end 

local function initialized()
    if tes3.isModActive("Ashfall.ESP") then
        event.register("loaded", onLoaded)
        -- load modules
        require ("mer.ashfall.common")
        
        require ("mer.ashfall.scriptTimer")
        require("mer.ashfall.tempEffects.ratings.ratingEffects")
        require("mer.ashfall.needs.needs")
        require("mer.ashfall.effects.harvest_wood")
        require("mer.ashfall.ui.hud")
        require("mer.ashfall.cooking.cooking")
        require("mer.ashfall.effects.frostbreath")
        require("mer.ashfall.effects.keybinds")

        require("mer.ashfall.camping.campfire")

        mwse.log("Initialized Ashfall")
    end
end


--Need to initialise faders immediately
--require ("mer.ashfall.effects.faderController")

event.register("initialized", initialized)


--MCM settings
local mcmDataPath = "mer.ashfall.MCM.mcmData"
local function placeholderMCM(element)
    element:createLabel{text="This mod requires the EasyMCM library to be installed."}
    local link = element:createTextSelect{text="Go to EasyMCM Nexus Page"}
    link.color = tes3ui.getPalette("link_color")
    link.widget.idle = tes3ui.getPalette("link_color")
    link.widget.over = tes3ui.getPalette("link_over_color")
    link.widget.pressed = tes3ui.getPalette("link_pressed_color")
    link:register("mouseClick", function()
        os.execute("start https://www.nexusmods.com/morrowind/mods/46427?tab=files")
    end)
end

local function registerModConfig()
    local easyMCM = include("easyMCM.modConfig")
    local mcmData = require(mcmDataPath)
    local modData = easyMCM and easyMCM.registerModData(mcmData)
    mwse.registerModConfig(mcmData.name, modData or {onCreate=placeholderMCM})
end

event.register("modConfigReady", registerModConfig)