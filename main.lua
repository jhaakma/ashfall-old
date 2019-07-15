--[[
    Plugin: ashfall.esp
--]]

local function onLoaded()
    -- set global to disable mwscripts
    tes3.setGlobal("a_lua_enabled", 1)
end 

local function initialized()
    if tes3.isModActive("Ashfall.esp") then
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

require("mer.ashfall.MCM.mcm")


