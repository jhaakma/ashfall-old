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
            starving = { 
                text = "Starving", 
                min = 80, max = 100, 
                spell = "fw_h_starving",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.agility, amount = 0.6 }
                }
            },
            veryHungry = { 
                text = "Very Hungry", 
                min = 60, max = 80, 
                spell = "fw_h_veryHungry",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.agility, amount = 0.4 }
                }
            },
            hungry = { 
                text = "Hungry", 
                min = 40, max = 60, 
                spell = "fw_h_hungry",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.agility, amount = 0.2 }
                }
            },
            peckish = { 
                text = "Peckish", 
                min = 20, max = 40,
                spell = "fw_h_peckish",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.agility, amount = 0.1 }
                }
            },
            wellFed = { 
                text = "Well Fed", 
                min = 0, max = 20, 
                spell = "fw_h_wellFed",
                effects = { 
                    { id = tes3.effect.fortifyAttribute, attribute = tes3.attribute.agility, amount = 0.2 }
                }
            },
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
            dehydrated = { 
                text = "Dehydrated", 
                min = 80, max = 100, 
                spell = "fw_t_dehydrated",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.willpower, amount = 0.6 }
                }
            },
            parched = { 
                text = "Parched", 
                min = 60, max = 80, 
                spell = "fw_t_parched",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.willpower, amount = 0.4 }
                }
            },
            veryThirsty = { 
                text = "Very Thirsty", 
                min = 40, max = 60, 
                spell = "fw_t_veryThirsty",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.willpower, amount = 0.2 }
                }
            },
            thirsty = { 
                text = "Thirsty", 
                min = 20, max = 40,
                spell = "fw_t_thirsty",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.willpower, amount = 0.1 }
                }
            },
            hydrated = { 
                text = "Hydrated", 
                min = 0, max = 20, 
                spell = "fw_t_hydrated",
                effects = { 
                    { id = tes3.effect.fortifyAttribute, attribute = tes3.attribute.willpower, amount = 0.2 }
                }
            },
        },
    },

    tiredness = Condition:new{
        id = "tiredness",
        default = "rested",
        showMessageOption = "showTiredness",
        enableOption = "enableTiredness",
        min = 0,
        max = 100,
        minDebuffState = "tired",
        states = {
            exhausted = { 
                text = "Exhausted", 
                min = 80, max = 100, 
                spell = "fw_s_exhausted",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.intelligence, amount = 0.6 }
                }
            },
            veryTired = { 
                text = "Very Tired", 
                min = 60, max = 80, 
                spell = "fw_s_veryTired",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.intelligence, amount = 0.4 }
                }
            },
            tired = { 
                text = "Tired", 
                min = 40, max = 60, 
                spell = "fw_s_tired",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.intelligence, amount = 0.2 }
                }
            },
            rested = { 
                text = "Rested", 
                min = 20, max = 40,
            },
            wellRested = { 
                text = "Well Rested", 
                min = 0, max = 20, 
                spell = "fw_s_wellRested",
                effects = { 
                    { id = tes3.effect.fortifyAttribute, attribute = tes3.attribute.intelligence, amount = 0.2 }
                }
            },
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
            scorching = { 
                text = "Scorching", 
                min = 80, max = 100, 
                spell = "fw_cond_scorching",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.endurance, amount = 0.6 }
                }            
            },
            veryHot = { 
                text = "Very Hot", 
                min = 60, max = 80, 
                spell = "fw_cond_very_hot",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.endurance, amount = 0.4 }
                }            
            },
            hot = { 
                text = "Hot", 
                min = 40, max = 60,
                spell = "fw_cond_hot",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.endurance, amount = 0.2 }
                }            
            },
            warm = { 
                text = "Warm", 
                min = 20, max = 40,
                spell = "fw_cond_warm",
            },
            comfortable = { 
                text = "Comfortable", 
                min = -20, max = 20,
            },
            chilly = { 
                text = "Chilly", 
                min = -40, max = -20,
                spell = "fw_cond_chilly",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.speed, amount = 0.2 }
                }            
            },
            cold = { 
                text = "Cold", 
                min = -60, max = -40,
                spell = "fw_cond_cold",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.speed, amount = 0.4 }
                }            
            },
            veryCold = { 
                text = "Very Cold", 
                min = -80, max = -60,
                spell = "fw_cond_very_cold",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.speed, amount = 0.6 }
                }            
            },
            freezing = { 
                text = "Freezing", 
                min = -100, max = -80,
                spell = "fw_cond_freezing",
                effects = { 
                    { id = tes3.effect.drainAttribute, attribute = tes3.attribute.speed, amount = 0.8 }
                }            
            }
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