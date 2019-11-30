local common = require("mer.ashfall.common.common")

local playerDataPath = "Ashfall.mcmSettings"
local configPath = "ashfall"

local config = common.getConfig()
if not config then 
    config = {}
end
config.blocked = config.blocked or {}
config.logLevel = config.logLevel or "INFO"
mwse.saveConfig(configPath, config)

local function createTableVar(id)
    return mwse.mcm.createTableVariable{ id = id, table = config }
end

local function registerModConfig()
    
    local sideBarDefault = (
        "Welcome to Ashfall, the ultimate survival mod for Morrowind! \n\n" ..
        "Use the configuration menu to turn various mechanics, features and udpate messages on or off.\n\n" ..
        "Hover over individual settings to see more information."
    )

    local function addSideBar(component)
        component.sidebar:createInfo{ text = sideBarDefault}
        component.sidebar:createHyperLink{
            text = "Made by Merlord",
            exec = "start https://www.nexusmods.com/users/3040468?tab=user+files",
            postCreate = (
                function(self)
                    self.elements.outerContainer.borderAllSides = self.indent
                    self.elements.outerContainer.alignY = 1.0
                    self.elements.outerContainer.layoutHeightFraction = 1.0
                    self.elements.info.layoutOriginFractionX = 0.5
                end
            ),
        }

    end

    local template = mwse.mcm.createTemplate{ name = "Ashfall", headerImagePath = "textures/ashfall/MCMHeader.tga" }
    template:saveOnClose(configPath, config)

    local function createplayerVar(id, default)
        return mwse.mcm.createPlayerData{
            id = id,
            path = playerDataPath,
            defaultSetting = default
        }  
    end


    do --General Settings Page
        local pageGeneral = template:createSideBarPage("General Settings")
        addSideBar(pageGeneral)
        pageGeneral.noScroll = true

        do --Survival Mechanics Category
            local categorySurvival = pageGeneral:createCategory{ 
                label = "Survival Mechanics", 
                description = "Turn Ashfall Mechanics on and off."
            }
            categorySurvival:createYesNoButton{
                label = "Enable Temperature & Weather Effects",
                description = (
                    "When enabled, you will need to find shelter from extreme temperatures or face delibitating condition effects. \n\n" .. 
                    "At night or in cold climates, stay well fed, wear plenty of clothinug, use torches or firepits or stay indoors to keep yourself warm. \n\n" ..
                    "In hotter climates, make sure you remain hydrated, wear clothing with low warmth ratings and avoid sources of heat like fire, lava or steam. \n\n" ..
                    "Getting wet will cool you down significantly, as well as increase your fire resistance and lower your shock resistance.\n\n" 
                ),
                variable = createplayerVar("enableTemperatureEffects", true)
            }
            categorySurvival:createYesNoButton{
                label = "Enable Hunger",
                description = ( 
                    "When enabled, you must eat food regularly in order to survive. " .. 
                    "Ingredients provide a small amount of nutritional value, but you can also cook meals at campfires, cooking pots and stoves. " 
                ),
                variable = createplayerVar("enableHunger", true)
            }
            categorySurvival:createYesNoButton{
                label = "Enable Thirst",
                description = (
                    "When enabled, you must drink water regularly in order to survive " ..
                    "Fill bottles with water at any nearby stream, well or keg. You can also drink directly from water sources."    
                ),
                variable = createplayerVar("enableThirst", true),
                callback = tes3ui.updateInventoryTiles --to clear water bottle icons
            }
            categorySurvival:createYesNoButton{
                label = "Enable Sleep",
                description = (
                    "When enabled, you must tiredness regularly or face debuffs from tiredness deprivation. " .. 
                    "Sleeping in a bed or bedroll will allow you to become \"Well Rested\", while sleeping out in the open will not fully recover your tiredness."
                ),
                variable = createplayerVar("enableTiredness", true)
            }
            categorySurvival:createYesNoButton{
                label = "Enable Cooking (In Development)",
                description = (
                    "This mechanic is a WIP and should remain disabled"
                ),
                variable = createplayerVar("enableCooking", true),
                postCreate = function(self)
                    self:disable()--Visible only, can still be toggles
                end
            }
        end --\Survival Mechanics Category

        do --Condition Updates Category
            local categoryConditions = pageGeneral:createCategory{   
                label = "Condition Updates",
                description = "Choose which message updates appear when player conditions change.",
            }

            categoryConditions:createOnOffButton{
                label = "Temperature updates",
                description = "Show update messages when temperature condition changes.",
                variable = createplayerVar("showTemp", true)
            }
            categoryConditions:createOnOffButton{
                label = "Hunger updates",
                description = "Show update messages when hunger condition changes.",
                variable = createplayerVar("showHunger", true)
            }
            categoryConditions:createOnOffButton{
                label = "Thirst updates",
                description = "Show update messages when thirst condition changes.",
                variable = createplayerVar("showThirst", true)
            }
            categoryConditions:createOnOffButton{
                label = "Sleep updates",
                description = "Show update messages when tiredness condition changes.",
                variable = createplayerVar("showTiredness", true)
            }
            categoryConditions:createOnOffButton{
                label = "Wetness updates",
                description = "Show update messages when wetness condition changes.",
                variable = createplayerVar("showWetness", true)
            }
        end --\Condition Updates Category

        do --Miscellanious Category
            local categoryMisc = pageGeneral:createCategory{ 
                label = "Miscellanious",
                description = "Ashfall features not directly related to survival mechanics.",
            }

            categoryMisc:createYesNoButton{
                label = "Hunger/Thirst can kill you",
                description = (
                    "When enabled, you can die of hunger or thirst. Otherwise you will drop to 1 health."
                ),
                variable = createplayerVar("needsCanKill", false)
            }

            categoryMisc:createYesNoButton{
                label = "Enable Frost Breath",
                description = (
                    "Adds a frost breath effect to NPCs and the player in cold temperatures. \n\n" ..
                    "Does not require weather survival mechanics to be active. "
                ),
                variable = createplayerVar("showFrostBreath", true)
            }
            categoryMisc:createYesNoButton{
                label = "Harvest Wood in Wilderness Only",
                description = (
                    "If this is enabled, you can not harvest wood with an axe while in town."   
                ),
                variable = createplayerVar("illegalHarvest", true)
            }
        end --\Miscellanious Category

    end -- \General Settings Page

    do --Mod values page
        local pageModValues = template:createSideBarPage{
            label = "Mod Values"
        }
        addSideBar(pageModValues)

        do --Time Category
            local categoryTime = pageModValues:createCategory{
                label = "Time",
                description = "Change time components."
            }

            categoryTime:createSlider{
                label = "Time Scale",
                description = "Changes the speed of the day/night cycle. A value of 1 makes the day go at real-time speed; an in-game day would last 24 hours in real life. A value of 10 will make it ten times as fast as real-time (i.e., one in-game day lasts 2.4 hours), etc. The default timescale is 30 (1 in-game day = 48 real minutes).",
                min = 0,
                max = 50,
                step = 1,
                jump = 5,
                variable = mwse.mcm:createGlobal{ id = "timeScale"}
            }
        end --\Time category

        do --Hunger Category
            local categoryTime = pageModValues:createCategory{
                label = "Hunger",
                description = "Change hunger components.",
            }

            categoryTime:createSlider{
                label = "Hunger Rate",
                description = "Determines how much hunger you gain per hour. When set to 10, you gain 1% hunger every hour (not taking into account temperature effects). The default hunger rate is 20.",
                min = 0,
                max = 100,
                step = 1,
                jump = 10,
                variable = createplayerVar("hungerRate", 20)
            }
        end --\Hunger category

        do --Thirst Category
            local categoryThirst = pageModValues:createCategory{
                label = "Thirst",
                description = "Change thirst components.",
            }

            categoryThirst:createSlider{
                label = "Thirst Rate",
                description = "Determines how much thirst you gain per hour. When set to 10, you gain 1% thirst every hour (not taking into account temperature effects). The default thirst rate is 30.",
                min = 0,
                max = 100,
                step = 1,
                jump = 10,
                variable = createplayerVar("thirstRate", 30)
            }
        end--\Thirst Category

        do --Sleep Category
            local categorySleep = pageModValues:createCategory{
                label = "Sleep",
                description =  "Change tiredness components."
            }

            categorySleep:createSlider{
                label = "Sleep Loss Rate",
                description = (
                    "Determines how much tiredness you lose per hour. When set to 10, you lose 1% tiredness every hour. The default lose tiredness rate is 50."
                ),
                min = 0,
                max = 200,
                step = 1,
                jump = 10,
                variable = createplayerVar("loseSleepRate", 50)
            }
            categorySleep:createSlider{
                label =  "Sleep Loss Rate (Waiting)",
                description = "Determines how much tiredness you lose per hour while waiting. When set to 10, you lose 1% tiredness every hour. The default rate is 28 (i.e tiredness goes from 100% to 0% in 30.",
                min = 0,
                max = 200,
                step = 1,
                jump = 10,
                variable = createplayerVar("loseSleepWaiting", 30)
            }

            categorySleep:createSlider{
                label = "Gain Sleep Rate",
                description = "Determines how much tiredness you gain per hour while resting on the ground. When set to 10, you gain 1% tiredness every hour. The default gain tiredness rate is 80.",
                min = 0,
                max = 200,
                step = 1,
                jump = 10,
                variable = createplayerVar("gainSleepRate", 80)
            }
            categorySleep:createSlider{
                label = "Gain Sleep Rate (Bed)",
                description = "Determines how much tiredness you gain per hour while resting while using a bed. When set to 10, you gain 1% tiredness every hour. The default gain tiredness rate is 120.",
                min = 0,
                max = 200,
                step = 1,
                jump = 10,
                variable = createplayerVar("gainSleepBed", 120)
            }
        end --\Sleep Category

    end --\mod values page

    do --Exclusions Page
        template:createExclusionsPage{
            label = "Exclusions",
            description = (
                "This mod by default will support all characters and equipment in your game. " .. 
                "In some cases this is not ideal, and you may prefer to exclude certain objects from being processed. " .. 
                "This page provides an interface to accomplish that. " ..
                "Using the lists below you can easily view or edit which objects are to be blocked and which are to be allowed."
            ),
            variable = createTableVar("blocked"),
            filters = {
                {
                    label = "Plugins",
                    type = "Plugin",
                },
                {
                    label = "Food",
                    type = "Object",
                    objectType = tes3.objectType.ingredient,
                },
                {
                    label = "Drinks",
                    type = "Object",
                    objectType = tes3.objectType.alchemy   
                }
            }
        }

    end --\Exclusions Page

    do --Dev Options
        local pageDevOptions = template:createSideBarPage{
            label = "Development Options",
            description = "Tools for debugging etc. Don't touch unless you know what you're doing.",
        }

        pageDevOptions:createDropdown{
            label = "Log Level",
            options = {
                { label = "DEBUG", value = "DEBUG"},
                { label = "INFO", value = "INFO"},
                { label = "ERROR", value = "ERROR"},
                { label = "NONE", value = "NONE"},
            },
            variable = createTableVar("logLevel")
        }

    end --\Dev Options

    template:register()
end

event.register("modConfigReady", registerModConfig)