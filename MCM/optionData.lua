

local this = {}
--OPTIONS DATA--
--[[
    label: descrition of option
    id: id of variable where option data is stored
    isLocalOption: if true, data is stored on player, game-save specific. Otherwise stored 
]]
this.general = {
    label = "Survival Mechanics",
    description = "Turn Ashfall Mechanics on and off.",
    options = {
        {   
            id = "enableTemperatureEffects",
            label = "Enable Temperature & Weather Effects",
            description = (
                "When enabled, you will need to find shelter from extreme temperatures or face delibitating condition effects. \n\n" .. 
                "At night or in cold climates, stay well fed, wear plenty of clothinug, use torches or firepits or stay indoors to keep yourself warm. \n\n" ..
                "In hotter climates, make sure you remain hydrated, wear clothing with low warmth ratings and avoid sources of heat like fire, lava or steam. \n\n" ..
                "Getting wet will cool you down significantly, as well as increase your fire resistance and lower your shock resistance.\n\n" 
            ),
            
            defaultSetting = true,
            isLocalOption = true  
        },
        { 
            id = "enableHunger",
            label = "Enable Hunger",
            description = ( 
                "When enabled, you must eat food regularly in order to survive. " .. 
                "Ingredients provide a small amount of nutritional value, but you can also cook meals at campfires, cooking pots and stoves. " 
            ),
            defaultSetting = true,
            isLocalOption = true
        },
        { 
            id = "enableThirst",
            label = "Enable Thirst",
            description = (
                "When enabled, you must drink water regularly in order to survive " ..
                "Fill bottles with water at any nearby stream, well or keg. You can also drink directly from water sources."    
            ),
            defaultSetting = true,
            isLocalOption = true
        },
        { 
            id = "enableSleep",
            label = "Enable Sleep",
            description = (
                "When enabled, you must sleep regularly or face debuffs from sleep deprivation. " .. 
                "Sleeping in a bed or bedroll will allow you to become \"Well Rested\", while sleeping out in the open will not fully recover your sleep."
            ),
            defaultSetting = true,
            isLocalOption = true
        },
    }
}


this.updates = {
    label = "Condition Updates",
    description = "Choose which message updates appear when player conditions change.",
    options = {
        { 
            id = "showTemp",
            label = "Temperature updates",
            description = "Show update messages when temperature condition changes.",
            defaultSetting = true,
            isLocalOption = true 
        },
        { 
            id = "showHunger",
            label = "Hunger updates",
            description = "Show update messages when hunger condition changes.",
            defaultSetting = true,
            isLocalOption = true 
        },
        { 
            id = "showThirst",
            label = "Thirst updates",
            description = "Show update messages when thirst condition changes.",
            defaultSetting = true,
            isLocalOption = true 
        },
        { 
            id = "showSleep",
            label = "Sleep updates",
            description = "Show update messages when sleep condition changes.",
            defaultSetting = true,
            isLocalOption = true 
        },
        { 
            id = "showWetness",
            label = "Wetness updates",
            description = "Show update messages when wetness condition changes.",
            defaultSetting = true,
            isLocalOption = true 
        },
    }
}

this.misc = {
    label = "Miscellanious",
    description = "Ashfall features not directly related to survival mechanics.",
    options = {
        {
            id = "showFrostBreath",
            label = "Frost Breath",
            description = (
                "Adds a frost breath effect to NPCs and the player in cold temperatures. \n\n" ..
                "Does not require weather survival mechanics to be active. "
            ),
            defaultSetting = true,
            isLocalOption = true
        }
    }
}

return this