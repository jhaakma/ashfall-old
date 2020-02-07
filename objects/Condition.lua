local Parent = require("mer.ashfall.objects.Object")
local Condition = Parent:new()

Condition.type = "Condition"
Condition.fields = {
    id = true,
    default = true,
    showMessageOption = true,
    enableOption = true,
    states = true,
    minDebuffState = true,
    min = true, 
    max = true,
    minCallback = true,
    maxCallback = true,
}


function Condition:scaleSpellValues()

    local state = self:getCurrentStateData()
    if not state.spell then return end
    if not state.effects then return end

    
    local spell = tes3.getObject(state.spell)
    for _, stateEffect in ipairs(state.effects) do
        for _, spellEffect in ipairs(spell.effects) do


            local doScale = (
                spellEffect.id == stateEffect.id and 
                spellEffect.attribute == stateEffect.attribute and
                stateEffect.amount
            )
            if doScale then
                --For drain/fortify attributes, we scale according
                --to the player's base amount. 
                if stateEffect.attribute then
                    local baseAttr = tes3.mobilePlayer.attributes[stateEffect.attribute + 1].base 
                    spellEffect.min = baseAttr * stateEffect.amount
                    spellEffect.max = spellEffect.min
                end
            end
        end
    end

end

function Condition:isActive()
    return ( tes3.player.data.Ashfall.mcmSettings[self.enableOption] == true )
end

function Condition:showUpdateMessages()
    if (
        self:isActive() and
        ( tes3.player.data.Ashfall.fadeBlock ~= true ) and
        ( tes3.player.data.Ashfall.mcmSettings[self.showMessageOption] == true ) 
    ) then
        tes3.messageBox(self:getCurrentStateMessage())
    end
end


function Condition:getCurrentStateMessage()
    return string.format("You are %s.", self:getCurrentStateData().text )
end

function Condition:getCurrentStateData()
    return self.states[self:getCurrentState()]
end

--[[
    Returns the current state ID the player is in for this condition
]]
function Condition:getCurrentState()
    local currentState = self.default
    local currentValue = self:getValue()
    currentValue = math.clamp(currentValue, self.min, self.max)

    for id, values in pairs (self.states) do
        if values.min <= currentValue and currentValue <= values.max then
            currentState = id
        end
    end
    return currentState
end

function Condition:updateConditionEffects(currentState)
    currentState = currentState or self:getCurrentState()
    for state, values in pairs(self.states) do
        local isCurrentState = ( currentState == state )
        if values.spell then
            if isCurrentState then
                self:scaleSpellValues()
                mwscript.addSpell({ reference = tes3.player, spell = values.spell })
            else
                mwscript.removeSpell({ reference = tes3.player, spell =  values.spell })
            end
        end
    end
end

function Condition:getValue()
    if not tes3.player or not tes3.player.data.Ashfall then
        --mwse.log("ERROR: trying to get condition value %s before player was loaded", self.id)
        return 0
    end
    return tes3.player.data.Ashfall[self.id] or 0
end


function Condition:setValue(newVal)
    if not tes3.player or not tes3.player.data.Ashfall then
        --mwse.log("ERROR: trying to set condition value %s before player was loaded", self.id)
        return
    end
    tes3.player.data.Ashfall[self.id] = math.clamp(newVal, self.min, self.max)
end

function Condition:getStatMultiplier()
    if self.minDebuffState then
        local minVal =  self.states[self.minDebuffState].min
        local value = math.max(self:getValue(), minVal)
        return math.remap(value, minVal, 100, 1.0, 0.0)
    else
        mwse.log("[Asfall ERROR] getStatMultiplier(): %s does not have a debuffState", self.id)
    end
end

return Condition