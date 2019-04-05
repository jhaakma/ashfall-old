--Common
local this = {}
--COMMON FUNCTIONS

--[[
    Returns human-readable formatted time from gameHour
]]--


function this.hourToClockTime ( time )
    local gameTime = time or tes3.getGlobal("GameHour")
    local formattedTime
    
    local isPM = false
    if gameTime > 12 then
        isPM = true
        gameTime = gameTime - 12
    end
    
    local hourString
    if gameTime < 10 then 
        hourString = string.sub(gameTime, 1, 1)
    else
        hourString  = string.sub(gameTime, 1, 2)
    end

    local minuteTime = ( gameTime - hourString ) * 60
    local minuteString
    if minuteTime < 10 then
        minuteString = "0" .. string.sub( minuteTime, 1, 1 )
    else
        minuteString = string.sub ( minuteTime , 1, 2)
    end
    formattedTime = hourString .. ":" .. minuteString .. (isPM and " pm" or " am")
    return ( formattedTime )
end    

function this.messageBox(params)

    --[[
        Button = { text, callback}
    ]]--

    local message = params.message
    local buttons = params.buttons

    local function callback(e)
        --get button from 0-indexed MW param
        local button = buttons[e.button+1]
        if button.callback then
            button.callback()
        end
    end

    --Make list of strings to insert into buttons
    local buttonStrings = {}
    for _, button in ipairs(buttons) do
        table.insert(buttonStrings, button.text)
    end

    tes3.messageBox({
        message = message,
        buttons = buttonStrings,
        callback = callback
    })
end


--[[
    Fades out, passes time then runs callback when finished
]]--
function this.fadeTimeOut( hoursPassed, secondsTaken, callback )
    local function fadeTimeIn()
        mwse.log("CALLBACK")
        tes3.runLegacyScript({command = "EnablePlayerControls"})
        callback()
        this.data.muteConditionMessages = false
    end

    this.data.muteConditionMessages = true
    tes3.fadeOut({ duration = 0.5 })
    tes3.runLegacyScript({command = "DisablePlayerControls"})
    --Halfway through, advance gamehour
    local iterations = 10
    timer.start({
        type = timer.real,
        iterations = iterations,
        duration = ( secondsTaken / iterations ),
        callback = (
            function()
                local gameHour = tes3.findGlobal("gameHour")
                gameHour.value = gameHour.value + (hoursPassed/iterations)
            end
        )
    })
    --All the way through, fade back in
    timer.start({
        type = timer.real,
        iterations = 1,
        duration = secondsTaken,
        callback = (
            function()
                mwse.log("fade back")
                local fadeBackTime = 1
                tes3.fadeIn({ duration = fadeBackTime })
                timer.start({
                    type = timer.real,
                    iterations = 1,
                    duration = fadeBackTime, 
                    callback = fadeTimeIn
                })
            end
        )
    })
end



this.conditions = {
    --CONDITIONS--
    sleep = {
        --id = "sleep",
        default = "rested",
        showMessageOption = "showSleep",
        enableOption = "enableSleep",
        states = {
            exhausted   = { text = "Exhausted"      , min = 0       , max = 20      , spell = "fw_s_exhausted"      },
            veryTired   = { text = "Very Tired"     , min = 20      , max = 40      , spell = "fw_s_veryTired"      },
            tired       = { text = "Tired"          , min = 40      , max = 60      , spell = "fw_s_tired"          },
            rested      = { text = "Rested"         , min = 60      , max = 80      , spell = nil                   },
            wellRested  = { text = "Well Rested"    , min = 80      , max = 100     , spell = "fw_s_wellRested"     },
        }
    },

    hunger = {
        --id = "hunger",
        default = "satiated",
        showMessageOption = "showHunger",
        enableOption = "enableHunger",
        states = {
            starving    = { text = "Starving"       , min = 80      , max = 100     , spell = "fw_h_starving"       },
            veryHungry  = { text = "Very Hungry"    , min = 60      , max = 80      , spell = "fw_h_veryHungry"     },
            hungry      = { text = "Hungry"         , min = 40      , max = 60      , spell = "fw_h_hungry"         },
            satiated    = { text = "Peckish"        , min = 20      , max = 40      , spell = "fw_h_peckish"        },
            wellFed     = { text = "Well Fed"       , min = 0       , max = 20      , spell = nil                   },
        }
   },

    thirst = {
        --id = "thirst",
        default = "hydrated",
        showMessageOption = "showThirst",
        enableOption = "enableThirst",
        states = {
            dehydrated  = { text = "Dehydrated"     , min = 80      , max = 100     , spell = "fw_t_dehydrated"     },
            parched     = { text = "Parched"        , min = 60      , max = 80      , spell = "fw_t_parched"        },
            veryThirsty = { text = "Very Thirsty"   , min = 40      , max = 60      , spell = "fw_t_veryThirsty"    },
            thirsty     = { text = "Thirsty"        , min = 20      , max = 40      , spell = "fw_t_thirsty"        },
            hydrated    = { text = "Hydrated"       , min = 0       , max = 20      , spell = nil                   },
        }
    },


    temp = {
        --id = "temp",
        default = "comfortable",
        showMessageOption = "showTemp",
        enableOption = "enableTemperatureEffects",
        states = {
            scorching       = { text = "Scorching"      , min = 80      , max = 100     , spell = "fw_cond_scorching"   } ,
            veryHot         = { text = "Very Hot"       , min = 60      , max = 80      , spell = "fw_cond_very_hot"    } ,
            hot             = { text = "Hot"            , min = 40      , max = 60      , spell = "fw_cond_hot"         } ,
            warm            = { text = "Warm"           , min = 20      , max = 40      , spell = "fw_cond_warm"        } ,
            comfortable     = { text = "Comfortable"    , min = -20     , max = 20      , spell = nil                   } ,
            chilly          = { text = "Chilly"         , min = -40     , max = -20     , spell = "fw_cond_chilly"      } ,
            cold            = { text = "Cold"           , min = -60     , max = -40     , spell = "fw_cond_cold"        } ,
            veryCold        = { text = "Very Cold"      , min = -80     , max = -60     , spell = "fw_cond_very_cold"   } ,
            freezing        = { text = "Freezing"       , min = -100    , max = -80     , spell = "fw_cond_freezing"    }
        }
    },

    wetness = {
        --id = "wetness",
        default = "dry",
        showMessageOption = "showWetness",
        enableOption = "enableTemperatureEffects",
        states = {
            soaked  =   { text = "Soaked"   , min = 75, max = 100   , spell = "fw_wetcond_soaked"  },
            wet     =   { text = "Wet"      , min = 50, max = 75    , spell = "fw_wetcond_wet"     },
            damp    =   { text = "Damp"     , min = 25, max = 50    , spell = "fw_wetcond_damp"    },
            dry     =   { text = "Dry"      , min = 0, max = 25     , spell = nil               }
        }
    }
}



--INITIALISE SKILLS--
local skillModule = include("OtherSkills.skillModule")
local function onSkillsReady()
    skillModule.registerSkill("Survival", 
    {    name             =        "Survival", 
        icon             =        "Icons/ashfall/survival.dds", 
        id            =         30,
        attribute         =        tes3.attribute.endurance,
        description     =         "The Survival skill determines your ability to deal with harsh weather conditions and perform actions such as chopping wood and creating campfires effectively.",
        specialization     =         tes3.specialization.stealth
    })
    mwse.log("Ashfall skills registered")
end

if skillModule then
    event.register("OtherSkills:Ready", onSkillsReady)
end




--Setup local configs. 
local function initialiseCategory(category)
    --mwse.log("initialising category %s", category.id)
    for _, component in pairs(category.components or {}) do
        if component.class == "Category" then
            initialiseCategory(component)
        else
            if component.variable.id and this.data.mcmSettings[component.variable.id] == nil then
                this.data.mcmSettings[component.variable.id] = component.variable.defaultSetting
                mwse.log( "Initialising local config %s to %s", component.variable.id, component.variable.defaultSetting )
            end
        end
    end
end
local function initialiseLocalSettings(modData )
    --set up tables on player data
    this.data.mcmSettings = this.data.mcmSettings or {}
    for _, page in pairs(modData.pages) do
        initialiseCategory(page)
    end
end


--INITIALISE COMMON--
local function onLoaded()
    --Persistent data stored on player reference 
    -- ensure data table exists
    local data = tes3.player.data
    data.Ashfall = data.Ashfall or {}

    -- create a public shortcut
    this.data = data.Ashfall

    this.data.currentStates = this.data.currentStates or {}
    this.data.mcmSettings = this.data.mcmSettings or {}
    --initialise mod config
    local mcmData = require ("mer.ashfall.MCM.mcmData")
    initialiseLocalSettings(mcmData)

    mwse.log("Ashfall: Common.lua loaded successfully")
    event.trigger("Ashfall:dataLoaded")
end
event.register("loaded", onLoaded)


return this
