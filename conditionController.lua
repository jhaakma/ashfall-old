--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local common = require("mer.ashfall.common.common")

local this = {}


--Update the spell strength to scale with player attributes/level

function this.updateCondition(id)

    if not common.data then return end
    local thisCondition = common.config.conditions[id]

    if common.data.currentStates[id] == nil then
        common.data.currentStates[id] = thisCondition.default
    end

    local previousState = common.data.currentStates[id] or thisCondition.default
    

    local currentState = thisCondition:getCurrentState()

    local conditionChanging = ( currentState ~= previousState )
    if conditionChanging then
        common.data.currentStates[id] = currentState
        thisCondition:showUpdateMessages()
    end
    thisCondition:updateConditionEffects(currentState)

    --Restore fatigue if it drops below 0
    if conditionChanging then
        common.helper.restoreFatigue()
    end

end

--Update all conditions - called by the script timer
function this.updateConditions()
    for name, _ in pairs(common.config.conditions) do
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
        for id, _ in pairs(common.config.conditions) do

            local currentCondition = common.data.currentStates[id]

            local thisCondition = common.config.conditions[id].states

            if thisCondition and currentCondition then
                local spell = thisCondition[currentCondition].spell

                if spell and tes3.player.object.spells:contains(spell) then
                    mwscript.addSpell({ reference = tes3.player, spell = spell })
                end
            end
        end
    end
end

event.register("spellTick", refreshAfterRestore)

--Extreme Conditions timer
function this.checkExtremeConditions()
    
    -- for _, condition in pairs(common.config.conditions) do
    --     if common.data[condition.id] <= condition.min then
    --         if condition.minCallback then condition.minCallback() end
    --     elseif common.data[condition.id] >= condition.max then
    --         if condition.maxCallback then condition.maxCallback() end
    --     end
    -- end
end


return this