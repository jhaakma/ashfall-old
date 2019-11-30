--[[
    Plugin: ashfall.esp
--]]

if not mwse.loadConfig("ashfall") then
    mwse.saveConfig("ashfall", {})
end
local function onLoaded()
    -- set global to disable mwscripts
    tes3.setGlobal("a_lua_enabled", 1)
end 

local function initialized()

    if tes3.isModActive("Ashfall.esp") then

        event.register("loaded", onLoaded)

        require("mer.ashfall.survival")
        -- load modules
        require ("mer.ashfall.common.common")
        
        require ("mer.ashfall.scriptTimer")
        
        require("mer.ashfall.needs.needs")
        require("mer.ashfall.effects.harvest_wood")
        require("mer.ashfall.camping.branches")
        require("mer.ashfall.ui.hud")


        require("mer.ashfall.effects.frostbreath")
        require("mer.ashfall.effects.keybinds")

        require("mer.ashfall.camping.campfire")
        require("mer.ashfall.ui.itemTooltips")
        require("mer.ashfall.tempEffects.ratings.ratingEffects")
        
        require("mer.ashfall.needs.extremeEffects")

        mwse.log("[Ashfall] Initialized")
    end
end


--Need to initialise faders immediately
require ("mer.ashfall.effects.faderController")

event.register("initialized", initialized)

require("mer.ashfall.MCM.mcm")




