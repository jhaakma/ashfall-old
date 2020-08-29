local common = require ("mer.ashfall.common.common")
local hungerController = require("mer.ashfall.needs.hungerController")
local thirstController = require("mer.ashfall.needs.thirstController")
return {
    text = "Eat Stew",
    requirements = function(campfire)
        return (
            campfire.data.stewLevels and 
            campfire.data.stewProgress and
            campfire.data.stewProgress == 100 and
            common.staticConfigs.conditionConfig.hunger:getValue() > 0.01
        )
    end,
    callback = function(campfire)

        --remove old sbuffs
        for name, buff in pairs(common.staticConfigs.foodConfig.stewBuffs) do
            if campfire.data.stewLevels[name] == nil then
                mwscript.removeSpell{ reference = tes3.player, spell = buff.id }
            end
        end

        --Add buffs and set duration
        for name, ingredLevel in pairs(campfire.data.stewLevels) do
            --add spell
            local stewBuff = common.staticConfigs.foodConfig.stewBuffs[name]
            local effectStrength = common.helper.calculateStewBuffStrength(math.min(ingredLevel, 100), stewBuff.min, stewBuff.max)
            timer.delayOneFrame(function()
                local spell = tes3.getObject(stewBuff.id)
                local effect = spell.effects[1]
                effect.min = effectStrength
                effect.max = effectStrength
                mwscript.addSpell{ reference = tes3.player, spell = spell }
                common.data.stewBuffTimeLeft = common.helper.calculateStewBuffDuration()
            end)
        end

        --add up ingredients, mulitplying nutrition by % in the pot
        local nutritionLevel = 0
        local maxNutritionLevel = 0
        for type, _ in pairs(common.staticConfigs.foodConfig.stewBuffs) do
            nutritionLevel = nutritionLevel + ( common.staticConfigs.foodConfig.nutrition[type] * ( campfire.data.stewLevels[type] or 0 ) / 100 )
            maxNutritionLevel = nutritionLevel + common.staticConfigs.foodConfig.nutrition[type]
        end
        local foodRatio = nutritionLevel / maxNutritionLevel
        
        local highestNeed = math.max(common.staticConfigs.conditionConfig.hunger:getValue() / foodRatio, common.staticConfigs.conditionConfig.thirst:getValue())
        local maxDrinkAmount = math.min(campfire.data.waterAmount, (common.staticConfigs.capacities.cookingPot / common.staticConfigs.stewMealCapacity), highestNeed )

        local amountAte = hungerController.eatAmount(maxDrinkAmount * foodRatio)
        local amountDrank = thirstController.drinkAmount(maxDrinkAmount, campfire.data.waterDirty)
        

        if amountAte >= 1 or amountDrank >= 1 then
            tes3.playSound{ reference = tes3.player, sound = "Swallow" }
            campfire.data.waterAmount = math.max( (campfire.data.waterAmount - amountDrank), 0)
            
            if campfire.data.waterHeat >= common.staticConfigs.hotWaterHeatValue then
                common.data.stewWarmEffect = common.helper.calculateStewWarmthBuff(campfire.data.waterHeat) 
            end

            if campfire.data.waterAmount == 0 then
                event.trigger("Ashfall:Campfire_clear_pot", { campfire = campfire})
            end
            event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
        else
            tes3.messageBox("You are full.")
        end
        

        
    end
}