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


local function scaleSpellValues(spellID)

    if not spellID then
        return
    end
    
    local BASE_STAT = 60
    local BASE_LEVEL = 30
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

function Condition:getValue()
    if not tes3.player or not tes3.player.data.Ashfall then
        mwse.log("ERROR: trying to get condition value %s before player was loaded", self.id)
        return 0
    end
    return tes3.player.data.Ashfall[self.id] or 0
end


function Condition:setValue(newVal)
    if not tes3.player or not tes3.player.data.Ashfall then
        mwse.log("ERROR: trying to set condition value %s before player was loaded", self.id)
        return
    end
    --mwse.log("Set %s to %s", self.id, newVal)
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