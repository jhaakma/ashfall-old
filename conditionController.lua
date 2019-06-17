--Updates condition spell effect strength based on player stats
--Uses base version of spell as a reference to get attribute  values without multiplier
local common = require("mer.ashfall.common")
local logger = require("mer.ashfall.logger")

local this = {}

local ignoreList = {
    "fw_cond_warm",
    "fw_wetcond_soaked",
    "fw_wetcond_wet",
    "fw_wetcond_damp"
}

--Update the spell strength to scale with player attributes/level
local function scaleSpellValues(spellID)
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
                effect.min = baseEffect.min * ( tes3.mobilePlayer.attributes[attribute + 1].base / 40 ) --40 average starting stat
                effect.max = effect.min
            else
                --Other: scale by level
                effect.min = baseEffect.min * ( tes3.player.object.level / 20 )
                effect.max = effect.min
            end
            --logger.info("%s: %s", spellID, effect.min)
        end
    end
end

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

        local isCurrentState = common.data.currentStates[id] == stateId

        if spellId then
            if isCurrentState then
                scaleSpellValues(spellId)
                mwscript.addSpell({ reference = tes3.player, spell = spellId })
            else
                mwscript.removeSpell({ reference = tes3.player, spell = spellId })
            end
        end   
    end

    if conditionChanging then
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