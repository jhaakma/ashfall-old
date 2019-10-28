local Parent = require("mer.ashfall.objects.Object")
local Condition = Parent:new()

Condition.type = "Condition"
Condition.fields = {
    id = true,
    default = true,
    showMessageOption = true,
    enableOption = true,
    states = true,
    min = true,
    max = true,
    minCallback = true,
    maxCallback = true
}


local function scaleSpellValues(spellID)

    if not spellID then
        return
    end
    
    local BASE_STAT = 40
    local BASE_LEVEL = 20
    local ignoreList = {
        "fw_cond_warm",
        "fw_wetcond_soaked",
        "fw_wetcond_wet",
        "fw_wetcond_damp"
    }
    

    
    local baseID = spellID .. "_BASE"
    --this.log.info("BaseID : %s", baseID)
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
            --this.log.info("%s: %s", spellID, effect.min)
        end
    end
end

function Condition:isActive()
    return ( tes3.player.data.Ashfall.mcmSettings[self.enableOption] == true )
end

function Condition:showUpdateMessages()
    if (
        self:isActive() and
        ( tes3.player.data.Ashfall.muteConditionMessages ~= true ) and
        ( tes3.player.data.Ashfall.mcmSettings[self.showMessageOption] == true ) 
    ) then
        tes3.messageBox(self:getCurrentStateText())
    end
end


function Condition:getCurrentStateText()
    local state = tes3.player.data.Ashfall.currentStates[self.id]
    return string.format("You are %s.", self.states[state].text)
end

--[[
    Returns the current state the player is in for this condition
]]
function Condition:getCurrentState()
    local currentValue = (tes3.player.data.Ashfall[self.id] ~= nil ) and tes3.player.data.Ashfall[self.id] or 0
    currentValue = math.clamp(currentValue, self.min, self.max)

    for state, values in pairs (self.states) do
        if values.min <= currentValue and currentValue <= values.max then
             return state
        end
    end
    return self.default
end

function Condition:updateConditionEffects(currentState)
    for state, values in pairs(self.states) do
        local isCurrentState = ( currentState == state )
        if values.spell then
            if isCurrentState then
                scaleSpellValues(values.spell)
                mwscript.addSpell({ reference = tes3.player, spell = values.spell })
            else
                mwscript.removeSpell({ reference = tes3.player, spell =  values.spell })
            end
        end
    end

end

return Condition