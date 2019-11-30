--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local common = require("mer.ashfall.common.common")

local this = {}


--Update the spell strength to scale with player attributes/level

function this.updateCondition(id)

    if not common.data then return end
    local thisCondition = common.conditions[id]

    if common.data.currentStates[id] == nil then
        common.data.currentStates[id] = thisCondition.default
    end

    local previousState = common.data.currentStates[id] or thisCondition.default
    local currentState = thisCondition:getCurrentState()

    local conditionChanging = ( currentState ~= previousState )
    if conditionChanging then
        common.data.currentStates[id] = currentState
        thisCondition:showUpdateMessages()
        thisCondition:updateConditionEffects(currentState)
    end
    

    --Restore fatigue if it drops below 0
    if conditionChanging then
        common.helper.restoreFatigue()
    end

end

--Update all conditions - called by the script timer
function this.updateConditions()
    --if tes3.menuMode() then return end
    for name, _ in pairs(common.conditions) do
        this.updateCondition(name)
    end
end

--Remove and re-add the condition spell if the player healed their stats with a potion or spell. 
local function refreshAfterRestore(e)
    local doRefresh = (
        e.effectInstance.state == tes3.spellState.ending and
        --We aren't checking Ashfall spells, we're checking other spells that might have healed the ashfall spells
        not string.startswith(e.source.id, "fw")
    )
    if doRefresh then
        for id, condition in pairs(common.conditions) do
            local currentState = condition:getCurrentState()
            local states = common.conditions[id].states
            if states and currentState then
                local spell = states[currentState].spell
                if spell and tes3.player.object.spells:contains(spell) then
                    mwscript.addSpell({ reference = tes3.player, spell = spell })
                end
            end
        end
    end
end

event.register("spellTick", refreshAfterRestore)

return this