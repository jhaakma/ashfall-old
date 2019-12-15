--Common
local this = {}

this.staticConfigs = require("mer.ashfall.common.staticConfigs")
this.log = require("mer.ashfall.common.logger")
this.helper = require("mer.ashfall.common.helperFunctions")
this.conditions = require("mer.ashfall.common.conditions")
this.config = require("mer.ashfall.common.config")
this.skills = require("mer.ashfall.common.skills")


--Setup local configs. 
local function initialiseLocalSettings()
    local mcmData = require ("mer.ashfall.MCM.mcmData")
    --this.log.info("initialising category %s", category.id)
    for setting, value in pairs(mcmData) do
        if this.data.mcmSettings[setting] == nil then
            this.data.mcmSettings[setting] = value
            this.log.info( "Initialising local data %s to %s", setting, value )
        end
    end
end


--INITIALISE COMMON--
local function onLoaded()
    if not skillModule then
        tes3.messageBox("WARNING: Skills module not installed!")
    end
    --Persistent data stored on player reference 
    -- ensure data table exists
    local data = tes3.player.data
    data.Ashfall = data.Ashfall or {}

    -- create a public shortcut
    this.data = data.Ashfall

    this.data.currentStates = this.data.currentStates or {}
    this.data.wateredCells = this.data.wateredCells or {}
    this.data.mcmSettings = this.data.mcmSettings or {}

    --In case the game was saved during block Needs timer
    this.data.blockNeeds = false

    --initialise mod config
    initialiseLocalSettings()

    this.log.info("Common Data loaded successfully")
    event.trigger("Ashfall:dataLoaded")
end
event.register("loaded", onLoaded)

return this
