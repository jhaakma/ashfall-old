--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local common = require("mer.ashfall.common")
local logger = require("mer.ashfall.logger")

local this = {}


--Update the spell strength to scale with player attributes/level



function this.updateCondition(id)
    
    if not common.data then return end
    local conditionData = common.conditions[id]
    
    if common.data.currentStates[id] == nil then
        common.data.currentStates[id] = conditionData.default
    end

    previousState = common.data.currentStates[id] or conditionData.default
    local currentValue = common.data[id] or 0
    local newState
    local conditionChanging = false

    for stateId, stateData in pairs(conditionData.states) do

        if stateData.min <= currentValue and currentValue <= stateData.max then
            newState = stateId
            if newState ~= previousState then--we have changed states
                conditionChanging = true
                common.data.currentStates[id] = newState
                local doShowMessage = (
                    common.data.mcmSettings[conditionData.showMessageOption] and
                    common.data.mcmSettings[conditionData.enableOption] and 
                    not common.data.muteConditionMessages 
                )
                if doShowMessage then
                    tes3.messageBox("You are " .. string.lower(common.conditions[id].states[newState].text) .. "." )
                end

            end  
        end

        --We want to updates spells every time to avoid bullshit mwscript issues
        local spellId = stateData.spell
        --BROKEN--local hasSpell = tes3.player.object.spells:contains(spellId) 

        local isCurrentState = ( common.data.currentStates[id] == stateId )

        if spellId then
            if isCurrentState then
                common.scaleSpellValues(spellId)
                mwscript.addSpell({ reference = tes3.player, spell = spellId })
            else
                mwscript.removeSpell({ reference = tes3.player, spell = spellId })
            end
        end   
    end

    --Restore fatigue if it drops below 0
    if conditionChanging then
        common.restoreFatigue()
    end

    
end

--Update all conditions - called by the script timer
function this.updateConditions()
    for name, _ in pairs(common.conditions) do
        this.updateCondition(name)
    end
end

--Remove and re-add the condition spell if the player healed their stats with a potion or spell. 
local function refreshAfterRestore(e)
    local doRefresh = (
        common.data and
        e.effectInstance.state == tes3.spellState.ending and
        not string.startswith(e.source.id, "fw")
    )
    if doRefresh then
        --logger.info("checking refresh")
        for id, data in pairs(common.conditions) do

            local currentCondition = common.data.currentStates[id]

            local conditionData = common.conditions[id].states

            if conditionData and currentCondition then
                local spell = conditionData[currentCondition].spell

               -- logger.info("Spell = %s", spell)
                if spell and tes3.player.object.spells:contains(spell) then
                    --logger.info("Refreshing spell: %s", spell)
                    --mwscript.removeSpell({ reference = tes3.player, spell = spell })
                    mwscript.addSpell({ reference = tes3.player, spell = spell })
                end
            end
        end
    end
end

event.register("spellTick", refreshAfterRestore)


return this