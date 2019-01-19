--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local common = require("mer.ashfall.common")
local this = {}

local ignoreList = {
    "fw_cond_warm",
    "fw_wetcond_soaked",
    "fw_wetcond_wet",
    "fw_wetcond_damp"
}

this.needsData = {
    temp = {
        value = "temp",
        default = "comfortable",
        showMessageOption = common.MCMOptionIds.showTemp,
        enableOption = common.MCMOptionIds.enableAshfall
    },
    hunger = {
        value = "hunger",
        default = "satiated",
        showMessageOption = common.MCMOptionIds.showHunger,
        enableOption = common.MCMOptionIds.enableHunger
    },   
    thirst = {
        value = "thirst",
        default = "hydrated",
        showMessageOption = common.MCMOptionIds.showThirst,
        enableOption = common.MCMOptionIds.enableThirst
    },   
    sleep =  {
        value = "sleep",
        default = "rested",
        showMessageOption = common.MCMOptionIds.showSleep,
        enableOption = common.MCMOptionIds.enableSleep
    },
    wetness = {
        value = "wetness",
        default = "dry",
        showMessageOption = common.MCMOptionIds.showWetness,
        enableOption = common.MCMOptionIds.enableAshfall
    }
}

--Update the spell strength to scale with player attributes/level
local function scaleSpellValues(spellID)
    --mwse.log("Entering scaleSpellValues")
    --No effect for comfortable
    if not spellID then
        mwse.log("no spell ID sent")
        return
    end
    
    local baseID = spellID .. "_BASE"
    --mwse.log("BaseID : %s", baseID)
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
                effect.min = baseEffect.min * ( tes3.mobilePlayer.attributes[attribute + 1].base / 40 ) --40 average starting stat
                effect.max = effect.min
            else
                --Other: scale by level
                effect.min = baseEffect.min * ( tes3.player.object.level / 20 )
                effect.max = effect.min
            end
            mwse.log("%s: %s", spellID, effect.min)
        end
    end
end

function this.updateCondition(id)
    local c = this.needsData[id]
    if not common.data then return end

    previousCondition = common.data.currentConditions[c.value] or c.default
    local currentValue = common.data[c.value] or 0
    local newCondition

    for conditionType, conditionValues in pairs(common.conditions[c.value]) do
        if conditionValues.min <= currentValue and currentValue <= conditionValues.max then
            newCondition = conditionType
            if newCondition ~= previousCondition then
                --Changing conditions, remove old, add new
                for _, innerVal in pairs(common.conditions[c.value])  do
                    local spellID = innerVal.spell
                    local playerHasCondition = 
                        innerVal.spell and 
                        tes3.player.object.spells:contains(spellID) 
                    if playerHasCondition then
                        --mwse.log("Removing spell: %s", spellID )
                        mwscript.removeSpell({ reference = tes3.player, spell = spellID })
                    end
                end

                --Add new condition
                local doShowMessage = (
                    common.data.mcmOptions[c.showMessageOption] and
                    common.data.mcmOptions[c.enableOption]
                )
                if doShowMessage then
                    tes3.messageBox("You are " .. string.lower(common.conditions[c.value][ newCondition].text) )
                end
                if conditionValues.spell then
                    scaleSpellValues(common.conditions[c.value][newCondition].spell)
                    mwscript.addSpell({ reference=tes3.player, spell = conditionValues.spell })
                end
                common.data.currentConditions[c.value] = newCondition
            end
            break
        end
    end
end

--Update all conditions - called by the script timer
function this.updateConditions()
    for name, _ in pairs(this.needsData) do
        this.updateCondition(name)
    end
end

--Remove and re-add the condition spell if the player healed their stats with a potion or spell. 
local function refreshAfterRestore(e)
    local doRefresh = 
        e.effectInstance.state == tes3.spellState.ending and
        not string.startswith(e.source.id, "fw")

    if doRefresh then
        --mwse.log("checking refresh")
        for _, data in pairs(this.needsData) do

            local currentCondition = common.data.currentConditions[data.value]

            local conditionData = common.conditions[data.value]

            if conditionData and currentCondition then
                mwse.log("Current Condition: %s", currentCondition)
                local spell = conditionData[currentCondition].spell

               -- mwse.log("Spell = %s", spell)
                if spell and tes3.player.object.spells:contains(spell) then
                    --mwse.log("Refreshing spell: %s", spell)
                    --mwscript.removeSpell({ reference = tes3.player, spell = spell })
                    mwscript.addSpell({ reference = tes3.player, spell = spell })
                end
            end
        end
    end
end

event.register("spellTick", refreshAfterRestore)

return this