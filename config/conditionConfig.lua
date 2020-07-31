local Condition = require("mer.ashfall.objects.Condition")
local conditions = {}

conditions.hunger = Condition:new{
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
}

conditions.thirst = Condition:new{
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
}

conditions.tiredness = Condition:new{
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
}

conditions.temp = Condition:new{
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
}

conditions.wetness = Condition:new{
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

conditions.foodPoison = Condition:new{
    id = "foodPoison",
    default = "healthy",
    showMessageOption = "showSickness",
    enableOption = "enableSickness",
    min = 0,
    max = 100,
    states = {
        sick = { 
            text = "You have contracted Food Poisoning.",
            sound = "ashfall_gurgle_01",
            min = 80, 
            max = 100, 
            spell = "ashfall_d_foodPoison",
            effects = {
                { id = tes3.effect.drainAttribute, attribute = tes3.attribute.strength, amount = 0.2 },
            }
        },
        healthy = { text = "You no longer have Food Poisoning.", min = 0, max = 80, spell = nil }
    },
    getCurrentStateMessage = function(self)
        return self:getCurrentStateData().text
    end
}

conditions.dysentery = Condition:new{
    id = "dysentery",
    default = "healthy",
    showMessageOption = "showSickness",
    enableOption = "enableSickness",
    min = 0,
    max = 100,
    states = {
        sick = { 
            text = "You have contracted Dysentery", 
            sound = "ashfall_gurgle_02",
            min = 80, 
            max = 100, 
            spell = "ashfall_d_dysentry",
            effects = {
                { id = tes3.effect.drainAttribute, attribute = tes3.attribute.speed, amount = 0.2 },
                { id = tes3.effect.drainAttribute, attribute = tes3.attribute.willpower, amount = 0.2 },
            }
        },
        healthy = { text = "You no longer have Dysentery.", min = 0, max = 80, spell = nil }
    },
    getCurrentStateMessage = function(self)
        return self:getCurrentStateData().text
    end
}

conditions.envDisease = Condition:new{
    id = "envDisease",
    default = "healthy",
    showMessageOption = "showSickness",
    enableOption = "enableEnvironmentSickness",
    min = -100,
    max = 100,
    states = {
        flu = {
            text = "You have come down with a flu.",
            min = -100,
            max = -80,
            spell = "ashfall_d_flu",
            effects = {
                { id = tes3.effect.drainAttribute, attribute = tes3.attribute.endurance, amount = 0.2 },
                { id = tes3.effect.drainAttribute, attribute = tes3.attribute.intelligence, amount = 0.1 },
            }
        },
        healthy = { min = -80, max = 80, spell = nil },
        heatstroke = {
            text = "You have come down with a heatstroke.",
            min = 80,
            max = 100,
            spell = "ashfall_d_heat",
            effects = {
                { id = tes3.effect.drainAttribute, attribute = tes3.attribute.agility, amount = 0.2 },
                { id = tes3.effect.drainAttribute, attribute = tes3.attribute.strength, amount = 0.1 },
            }
        }
    }
}

conditions.blightness = Condition:new{
    id = "blightness",
    default = "healthy",
    showMessageOption = "showSickness",
    enableOption = "enableBlightness",
    min = 0,
    max = 100,
    states = {
        sick = {
            min = 99, 
            max = 100, 
            blights = {
                "ash-chancre", 
                "black-heart blight",
                "chanthrax blight",
                "ash woe blight",
            },
        },
        healthy = { min = 0, max = 99, spell = nil }
    },
    conditionChanged = function(self)
        local stateData =  self:getCurrentStateData()
        if stateData.blights then
            if not self:hasBlight() then 
                local newBlight = table.choice(stateData.blights)
                mwscript.addSpell({ reference = tes3.player, spell = newBlight })
                
                stateData.spell = newBlight
                self:showUpdateMessages()
                --stateData.spell = nil
                self:setValue(0)
            end
        end
    end,
    getCurrentStateMessage = function(self)
        local spell = self:getCurrentSpellObj()
        if spell then
            return string.format("You have contracted %s.", spell.name)
        end
    end,
    updateConditionEffects = function() return end,
    hasBlight = function(self)
        if not self.blights then
            self.blights = self:getBlights()
        end
        for _, blight in ipairs(self.blights) do
            if tes3.mobilePlayer:isAffectedByObject(blight) then 
                return true
            end
        end
    end,
    
    getBlights = function(self)
        local blights = {}
        for spell in tes3.iterateObjects(tes3.objectType.spell) do
            if spell.castType == tes3.spellType.blight then
                table.insert(blights, spell)
            end
        end
        return blights
    end
}


return conditions