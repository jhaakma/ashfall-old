local Condition = require("mer.ashfall.objects.Condition")

return {
    --CONDITIONS--
    hunger = Condition:new{
        id = "hunger",
        default = "wellFed",
        showMessageOption = "showHunger",
        enableOption = "enableHunger",
        min = 0,
        max = 100,
        minDebuffState = "peckish",
        states = {
            starving    = { text = "Starving"       , min = 80      , max = 100     , spell = "fw_h_starving"       },
            veryHungry  = { text = "Very Hungry"    , min = 60      , max = 80      , spell = "fw_h_veryHungry"     },
            hungry      = { text = "Hungry"         , min = 40      , max = 60      , spell = "fw_h_hungry"         },
            peckish    = { text = "Peckish"        , min = 20      , max = 40      , spell = "fw_h_peckish"        },
            wellFed     = { text = "Well Fed"       , min = 0       , max = 20      , spell = nil                   },
        },
   },

    thirst = Condition:new{
        id = "thirst",
        default = "hydrated",
        showMessageOption = "showThirst",
        enableOption = "enableThirst",
        min = 0,
        max = 100,
        minDebuffState = "thirsty",
        states = {
            dehydrated  = { text = "Dehydrated"     , min = 80      , max = 100     , spell = "fw_t_dehydrated"     },
            parched     = { text = "Parched"        , min = 60      , max = 80      , spell = "fw_t_parched"        },
            veryThirsty = { text = "Very Thirsty"   , min = 40      , max = 60      , spell = "fw_t_veryThirsty"    },
            thirsty     = { text = "Thirsty"        , min = 20      , max = 40      , spell = "fw_t_thirsty"        },
            hydrated    = { text = "Hydrated"       , min = 0       , max = 20      , spell = nil                   },
        },

    },

    tiredness = Condition:new{
        id = "tiredness",
        default = "rested",
        showMessageOption = "showTiredness",
        enableOption = "enableTiredness",
        min = 0,
        max = 100,
        minDebuffState = "rested",
        states = {
            exhausted   = { text = "Exhausted"      , min = 80      , max = 100     , spell = "fw_s_exhausted"      },
            veryTired   = { text = "Very Tired"     , min = 60      , max = 80      , spell = "fw_s_veryTired"      },
            tired       = { text = "Tired"          , min = 40      , max = 60      , spell = "fw_s_tired"          },
            rested      = { text = "Rested"         , min = 20      , max = 40      , spell = nil                   },
            wellRested  = { text = "Well Rested"    , min = 0       , max = 20      , spell = "fw_s_wellRested"     },
        },
    },

    temp = Condition:new{
        id = "temp",
        default = "comfortable",
        showMessageOption = "showTemp",
        enableOption = "enableTemperatureEffects",
        min = -100,
        max = 100,
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
        },
    },

    wetness = Condition:new{
        id = "wetness",
        default = "dry",
        showMessageOption = "showWetness",
        enableOption = "enableTemperatureEffects",
        min = 0,
        max = 100,
        states = {
            soaked  =   { text = "Soaked"   , min = 75, max = 100   , spell = "fw_wetcond_soaked"  },
            wet     =   { text = "Wet"      , min = 50, max = 75    , spell = "fw_wetcond_wet"     },
            damp    =   { text = "Damp"     , min = 25, max = 50    , spell = "fw_wetcond_damp"    },
            dry     =   { text = "Dry"      , min = 0, max = 25     , spell = nil               }
        },
    }
}