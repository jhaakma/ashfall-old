local common = require("mer.ashfall.common.common")
--check that the creature is diseased
local function getDisease(obj)
    for spell in tes3.iterate(obj.spells.iterator) do
        common.log:debug("Spell: %s", spell.id)
        if spell.castType == tes3.spellType.disease or spell.castType == tes3.spellType.blight then
            return spell
        end
    end
end

local function addDiseaseToMeat(reference, disease)
    local obj = reference.object
    for stack in tes3.iterate(obj.inventory.iterator) do
        if stack.object.id:lower():find("meat") then
            common.log:debug("Found %s", stack.object.id)
            if stack.variables then
                for _, variable in ipairs(stack.variables) do
                    variable.data.mer_disease = { id = disease.id, spellType = disease.castType }
                end
            else
                for i= 1, stack.count do
                    local itemData = tes3.addItemData{
                        to = reference,
                        item = stack.object,
                        updateGUI = true
                    }
                    itemData.data.mer_disease = { id = disease.id, spellType = disease.castType }
                end
            end

        end
    end
end


local function addDiseaseOnDeath(e)
    if common.config.getConfig().enableDiseasedMeat then
        common.log:debug("Dead")
        local baseObj = e.reference.baseObject or e.reference.object
        if baseObj.objectType == tes3.objectType.creature then
            common.log:debug("Creature: %s", baseObj.name)
            local disease = getDisease(e.reference.object)
            if disease then
                addDiseaseToMeat(e.reference, disease)
            end
        end
    end
end
event.register("death", addDiseaseOnDeath)