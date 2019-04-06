
local playerDataPath = "Ashfall.mcmSettings"
local configPath = "Ashfall/config"
local sideBarDefault = (
    "Welcome to Ashfall, the ultimate survival mod for Morrowind! \n\n" ..
    "Use the configuration menu to turn various mechanics, features and udpate messages on or off.\n\n" ..
    "Hover over individual settings to see more information."
)

local sidebar = {

    {
        class = "MouseOverInfo",
        text = sideBarDefault,
    },
    {
        class = "Hyperlink",
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
    },
}


local this = {
    name = "Ashfall",
    headerImagePath = "textures/ashfall/MCMHeader.tga",
    pages = {
        --Page 1
        {   
            class = "SideBarPage",
            label = "General Settings",
            sidebarComponents = sidebar,
            components = {
                {
                    --id = "survivalMechanics",
                    class = "Category",
                    label = "Survival Mechanics",
                    description = "Turn Ashfall Mechanics on and off.",
                    components = {
                        {   
                            label = "Enable Temperature & Weather Effects",
                            class = "YesNoButton",
                            description = (
                                "When enabled, you will need to find shelter from extreme temperatures or face delibitating condition effects. \n\n" .. 
                                "At night or in cold climates, stay well fed, wear plenty of clothinug, use torches or firepits or stay indoors to keep yourself warm. \n\n" ..
                                "In hotter climates, make sure you remain hydrated, wear clothing with low warmth ratings and avoid sources of heat like fire, lava or steam. \n\n" ..
                                "Getting wet will cool you down significantly, as well as increase your fire resistance and lower your shock resistance.\n\n" 
                            ),
                            variable = {
                                id = "enableTemperatureEffects",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Enable Hunger",
                            class = "YesNoButton",
                            description = ( 
                                "When enabled, you must eat food regularly in order to survive. " .. 
                                "Ingredients provide a small amount of nutritional value, but you can also cook meals at campfires, cooking pots and stoves. " 
                            ),
                            variable = {
                                id = "enableHunger",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Enable Thirst",
                            class = "YesNoButton",
                            description = (
                                "When enabled, you must drink water regularly in order to survive " ..
                                "Fill bottles with water at any nearby stream, well or keg. You can also drink directly from water sources."    
                            ),
                            variable = {
                                id = "enableThirst",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Enable Sleep",
                            class = "YesNoButton",
                            description = (
                                "When enabled, you must sleep regularly or face debuffs from sleep deprivation. " .. 
                                "Sleeping in a bed or bedroll will allow you to become \"Well Rested\", while sleeping out in the open will not fully recover your sleep."
                            ),
                            variable = {
                                id = "enableSleep",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Enable Cooking (In Development)",
                            class = "YesNoButton",
                            description = (
                                "This mechanic is a WIP and should remain disabled"
                            ),
                            variable = {
                                id = "enableCooking",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = false,
                            },
                            postCreate = function(self)
                                self:disable()--Visible only, can still be toggles
                            end
                        },
                    }
                },
                {
                    class = "Category",
                    label = "Condition Updates",
                    description = "Choose which message updates appear when player conditions change.",
                    components = {
                        {  
                            label = "Temperature updates",
                            class = "OnOffButton",
                            description = "Show update messages when temperature condition changes.",
                            variable = {
                                id = "showTemp",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Hunger updates",
                            class = "OnOffButton",
                            description = "Show update messages when hunger condition changes.",
                            variable = {
                                id = "showHunger",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Thirst updates",
                            class = "OnOffButton",
                            description = "Show update messages when thirst condition changes.",
                            variable = {
                                id = "showThirst",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Sleep updates",
                            class = "OnOffButton",
                            description = "Show update messages when sleep condition changes.",
                            variable = {
                                id = "showSleep",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        {  
                            label = "Wetness updates",
                            class = "OnOffButton",
                            description = "Show update messages when wetness condition changes.",
                            variable = {
                                id = "showWetness",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = false,
                            },
                        },
                    },           
                },
                {
                    class = "Category",
                    label = "Miscellanious",
                    description = "Ashfall features not directly related to survival mechanics.",
                    components = {
                        { 
                            label = "Enable Frost Breath",
                            class = "YesNoButton",
                            description = (
                                "Adds a frost breath effect to NPCs and the player in cold temperatures. \n\n" ..
                                "Does not require weather survival mechanics to be active. "
                            ),
                            variable = {
                                id = "showFrostBreath",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                        --[[{
                            label = "Player Name",
                            class = "TextField",
                            --lengthLimit = 20,
                            variable = {
                                id = "setPlayerName",
                                class = "Custom",
                                inGameOnly = true,
                                getter = (
                                    function(self)
                                        return tes3.player.object.name
                                    end
                                ),
                                setter = (
                                    function(self, newValue)
                                        tes3.player.object.name = newValue
                                    end
                                ),
                                defaultSetting = "Enter New Name",
                            },
                            callback = (
                                function(self)
                                    tes3.messageBox("New Player name: \"%s\"", self.variable.value)
                                end
                            ),
                        },]]--

                        { 
                            label = "Harvest Wood in Wilderness Only",
                            class = "YesNoButton",
                            description = (
                                "If this is enabled, you can not harvest wood with an axe while in town."   
                            ),
                            variable = {
                                id = "illegalHarvest",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = true,
                            },
                        },
                    }
                }
            }--/components
        },
        --Page 2
        {
            class = "SideBarPage",
            label = "Mod Values",
            sidebarComponents = sidebar,
            components = {
                {
                    class = "Category",
                    label = "Time",
                    description = "Change time components.",
                    components = {
                        {   
                            label = "Time Scale",
                            class = "Slider",
                            description = "Changes the speed of the day/night cycle. A value of 1 makes the day go at real-time speed; an in-game day would last 24 hours in real life. A value of 10 will make it ten times as fast as real-time (i.e., one in-game day lasts 2.4 hours), etc. The default timescale is 30 (1 in-game day = 48 real minutes).",
                            min = 0,
                            max = 50,
                            step = 1,
                            jump = 5,
                            variable = {
                                id = "timeScale",
                                class = "Global",
                            },
                        },
                    }
                },
                {
                    class = "Category",
                    label = "Hunger",
                    description = "Change hunger components.",
                    components = {
                        {
                            class = "Slider",
                            label = "Hunger Rate",
                            description = "Determines how much hunger you gain per hour. When set to 10, you gain 1% hunger every hour (not taking into account temperature effects). The default hunger rate is 28 (i.e hunger goes from 0% to 100% in 36 hours).",
                            min = 0,
                            max = 100,
                            step = 1,
                            jump = 10,
                            variable = {
                                id = "hungerRate",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = 28,
                            },
                        },
                    }
                },
                {
                    class = "Category",
                    label = "Thirst",
                    description = "Change thirst components.",
                    components = {
                        {
                            class = "Slider",
                            label = "Thirst Rate",
                            description = "Determines how much thirst you gain per hour. When set to 10, you gain 1% thirst every hour (not taking into account temperature effects). The default thirst rate is 42 (i.e thirst goes from 0% to 100% in 24 hours).",
                            
                            min = 0,
                            max = 100,
                            step = 1,
                            jump = 10,

                            variable = {
                                id = "thirstRate",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = 42,
                            },
                        },
                    }
                },
                {
                    class = "Category",
                    label = "Sleep",
                    description = "Change sleep components.",
                    components = {
                        {
                            class = "Slider",
                            label = "Lose Sleep Rate",
                            description = "Determines how much sleep you lose per hour. When set to 10, you lose 1% sleep every hour. The default lose sleep rate is 56 (i.e sleep goes from 100% to 0% in 18 hours).",
                            min = 0,
                            max = 200,
                            step = 1,
                            jump = 10,
                            variable = {
                                id = "loseSleepRate",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = 56,
                            },
                        },
                        {
                            class = "Slider",
                            label = "Sleep Loss Rate (Waiting)",
                            description = "Determines how much sleep you lose per hour while waiting. When set to 10, you lose 1% sleep every hour. The default rate is 28 (i.e sleep goes from 100% to 0% in 36 hours).",
                            min = 0,
                            max = 200,
                            step = 1,
                            jump = 10,
                            variable = {
                                id = "loseSleepWaiting",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = 28,
                            },
                        },
                        {
                            class = "Slider",
                            label = "Gain Sleep Rate",
                            description = "Determines how much sleep you gain per hour while resting on the ground. When set to 10, you gain 1% sleep every hour. The default gain sleep rate is 83 (i.e sleep goes from 100% to 0% in 12 hours).",
                            min = 0,
                            max = 200,
                            step = 1,
                            jump = 10,
                            variable = {
                                id = "gainSleepRate",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = 83,
                            },
                        },
                        {
                            class = "Slider",
                            label = "Gain Sleep Rate (Bed)",
                            description = "Determines how much sleep you gain per hour while resting while using a bed. When set to 10, you gain 1% sleep every hour. The default gain sleep rate is 125 (i.e sleep goes from 100% to 0% in 8 hours).",
                            sliderSettings = {
                                max = 200,
                                step = 1,
                                jump = 10
                            },
                            variable = {
                                id = "gainSleepBed",                                
                                path = playerDataPath,
                                class = "PlayerData",
                                defaultSetting = 125,
                            },
                        }, 

                    },
                },
            } ,
        },
        --Page 3
        --[[{
            class = "SideBarPage",
            label = "Key Bindings",
            sidebarComponents = sidebar,
            components = {
                --crafting
                {
                    label = "Crafting Menu",
                    class = "KeyBinder",
                    variable = {
                        id = "craftingKey",
                        class = "ConfigVariable",
                        path = configPath,
                        defaultSetting = {
                            keyCode = tes3.scanCode.c
                        },
                    },
                },
            },
        },]]--
        --Page 4
        {
            id = "exclusions",
            class = "ExclusionsPage",         
            description = (
                "This mod by default will support all characters and equipment in your game. " .. 
                "In some cases this is not ideal, and you may prefer to exclude certain objects from being processed. " .. 
                "This page provides an interface to accomplish that. " ..
                "Using the lists below you can easily view or edit which objects are to be blocked and which are to be allowed."
            ),
            label = "Exclusions",
            leftListLabel = "Blocked",
            rightListLabel = "Allowed",
            variable = {
                id = "blocked",                                
                path = configPath,
                class = "ConfigVariable",
            },
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
        },
        {
            id = "devOptions",
            label = "Development Options",
            class = "SideBarPage",
            description = "Tools for debugging etc. Don't touch unless you know what you're doing.",
            components = {
                {
                    label = "Log level",
                    class = "Dropdown",
                    description = "Set the level of logging to appear in MWSELog.txt for Ashfall",
                    options = {
                        { label = "DEBUG", value = "DEBUG"},
                        { label = "INFO", value = "INFO"},
                        { label = "ERROR", value = "ERROR"},
                        { label = "NONE", value = "NONE"},
                    },
                    variable = {
                        id = "logLevel",
                        class = "ConfigVariable",
                        path = configPath,
                        defaultSetting = "INFO"
                    }
                },
            }
        }

    },--/categories

}
return this