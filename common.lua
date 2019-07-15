--Common
local this = {}
local logger = require("mer.ashfall.logger")
--COMMON FUNCTIONS

--[[
    Returns human-readable formatted time from gameHour
]]--


local skillModule = require("OtherSkills.skillModule")

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

function this.checkRefSheltered(reference)
    reference = reference or tes3.player

    local oldCulledValue = reference.sceneNode.appCulled
    reference.sceneNode.appCulled = true
    local result = tes3.rayTest{
        position = reference.position,
        direction = {0, 0, 1},
        --useBackTriangles = true
    }
    reference.sceneNode.appCulled = oldCulledValue

    local sheltered =  (
        result and 
        result.reference and 
        result.reference.object and 
        result.reference.object.objectType == tes3.objectType.static
    ) == true
    return sheltered
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
                logger.info("fade back")
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

function this.restoreFatigue()
    --Restore lost fatigue to prevent collapsing
    local previousFatigue = tes3.mobilePlayer.fatigue.current
    timer.start{
        type = timer.real,
        iterations = 1,
        duration = 0.01,

        callback = function()
            local newFatigue = tes3.mobilePlayer.fatigue.current
            if previousFatigue >= 0 and newFatigue < 0 then
                tes3.mobilePlayer.fatigue.current = previousFatigue
            end
        end
    }
end

function this.tryContractDisease(spellID)
    local resistDisease = tes3.mobilePlayer.resistCommonDisease 
    local survival = skillModule.getSkill("Ashfall:Survival").value

    local resistEffect = math.remap( math.min(resistDisease, 100), 0, 100, 1.0, 0.0 )
    local survivalEffect =  math.remap( math.min(survival, 100), 0, 100, 1.0, 0.5 )

    local defaultChance = 0.3

    local catchChance = defaultChance * resistEffect * survivalEffect
    
    mwse.log("catchChance: %s", catchChance)
    if math.random() < catchChance then
        local spell = tes3.getObject(spellID)
        tes3.messageBox(tes3.findGMST(tes3.gmst.sMagicContractDisease).value, spell.name)
        mwscript.addSpell{ reference = tes3.player, spell = spell  }
    end
end

function this.scaleSpellValues(spellID)
    local BASE_STAT = 40
    local BASE_LEVEL = 20
    local ignoreList = {
        "fw_cond_warm",
        "fw_wetcond_soaked",
        "fw_wetcond_wet",
        "fw_wetcond_damp"
    }
    
    --logger.info("Entering scaleSpellValues")
    --No effect for comfortable
    if not spellID then
        logger.info("[Asfhall ERROR] no spell ID sent")
        return
    end
    
    local baseID = spellID .. "_BASE"
    --logger.info("BaseID : %s", baseID)
    local baseSpell = tes3.getObject(baseID)
    local realSpell = tes3.getObject(spellID)
    
    --Warm has a special case
    for _, id in ipairs(ignoreList) do
        if spellID == id then
            return
        end
    end
    --all others

    for i=1, #realSpell.effects do

        local effect = realSpell.effects[i]
        if effect.id ~= -1 then
            local baseEffect = baseSpell.effects[i]
            --Attributes: scale by matching player attribute
            local attribute  = effect.attribute
            if attribute ~= -1 then
                effect.min = baseEffect.min * ( tes3.mobilePlayer.attributes[attribute + 1].base / BASE_STAT ) 
                effect.max = effect.min
            else
                --Other: scale by level
                effect.min = baseEffect.min * ( tes3.player.object.level / BASE_LEVEL )
                effect.max = effect.min
            end
            --logger.info("%s: %s", spellID, effect.min)
        end
    end
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
this.skillStartValue = 10
local skillModule = include("OtherSkills.skillModule")
local function onSkillsReady()
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

    logger.info("Ashfall skills registered")
end

if skillModule then
    event.register("OtherSkills:Ready", onSkillsReady)
end


--Setup local configs. 
local function initialiseLocalSettings(mcmData)
    --logger.info("initialising category %s", category.id)
    for setting, value in pairs(mcmData) do
        if not this.data.mcmSettings[setting] then
            this.data.mcmSettings[setting] = value
            logger.info( "Initialising local config %s to %s", setting, value )
        end
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
    this.data.wateredCells = this.data.wateredCells or {}
    this.data.mcmSettings = this.data.mcmSettings or {}
    --[[this.data.temp = this.data.temp or {
        ext = { base = 0, real = 0 },
        int = { base = 0, real = 0 },
    }]]
    --initialise mod config
    local mcmData = require ("mer.ashfall.MCM.mcmData")
    initialiseLocalSettings(mcmData)

    logger.info("Ashfall: Common.lua loaded successfully")
    event.trigger("Ashfall:dataLoaded")
end
event.register("loaded", onLoaded)


return this
