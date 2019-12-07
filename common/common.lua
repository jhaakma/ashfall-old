--Common
local this = {}

this.staticConfigs = require("mer.ashfall.common.staticConfigs")
this.log = require("mer.ashfall.common.logger")
this.helper = require("mer.ashfall.common.helperFunctions")
this.conditions = require("mer.ashfall.common.conditions")

local configPath = "ashfall"
local inMemConfig
function this.getConfig()
    return inMemConfig and inMemConfig or mwse.loadConfig(configPath)
end

function this.saveConfig(newConfig)
    inMemConfig = newConfig
    mwse.saveConfig(configPath, newConfig)
end

function this.getConfigValue(value)
    local config = this.getConfig()
    if config then
        return config[value]
    else
        return nil
    end
end

function this.saveConfigValue(key, val)
    local config = this.getConfig()
    if config then
        config[key] = val
        mwse.saveConfig(configPath, config)
    end
end

--[[
    Skills
]]
local skillModule = include("OtherSkills.skillModule")
this.skills = {}
--INITIALISE SKILLS--
this.skillStartValue = 10
local function onSkillsReady()
    if not skillModule then
        timer.start({
            callback = function()
                tes3.messageBox({message = "Please install Skills Module", buttons = {"Okay"} })
            end,
            type = timer.simulate,
            duration = 1.0
        })

    end

    if ( skillModule.version == nil ) or ( skillModule.version < 1.4 ) then
        timer.start({
            callback = function()
                tes3.messageBox({message = string.format("Please update Skills Module"), buttons = {"Okay"} })
            end,
            type = timer.simulate,
            duration = 1.0
        })
    end

    skillModule.registerSkill(
        "Ashfall:Survival", 
        {    
            name = "Survival", 
            icon = "Icons/ashfall/survival.dds",
            value = this.skillStartValue,
            attribute = tes3.attribute.endurance,
            description = "The Survival skill determines your ability to deal with harsh weather conditions and perform actions such as chopping wood and creating campfires effectively. A higher survival skill also reduces the chance of getting food poisoning or dysentry from drinking dirty water.",
            specialization = tes3.specialization.stealth
        }
    )

    skillModule.registerSkill(
        "Ashfall:Cooking", 
        {    
            name = "Cooking", 
            icon = "Icons/ashfall/cooking.dds",
            value = this.skillStartValue,
            attribute = tes3.attribute.intelligence,
            description = "The cooking skill determines your effectiveness at cooking meals. The higher your cooking skill, the higher the nutritional value of cooked meats and vegetables, and the stronger the buffs given by stews. A higher cooking skill also increases the time before food will burn on a grill.",
            specialization = tes3.specialization.magic
        }
    )

    this.skills.survival = skillModule.getSkill("Ashfall:Survival")
    this.skills.cooking = skillModule.getSkill("Ashfall:Cooking")

    this.log.info("Ashfall skills registered")
end
event.register("OtherSkills:Ready", onSkillsReady)


--Setup local configs. 
local function initialiseLocalSettings(mcmData)
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
    local mcmData = require ("mer.ashfall.MCM.mcmData")
    initialiseLocalSettings(mcmData)

    this.log.info("Common Data loaded successfully")
    event.trigger("Ashfall:dataLoaded")
end
event.register("loaded", onLoaded)

return this
