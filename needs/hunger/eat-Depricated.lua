local hungerCommon = require("mer.ashfall.needs.hunger.hungerCommon")
local common = require("mer.ashfall.common.common")
local foodTypes = require("mer.ashfall.camping.foodTypes")
local meals = require("mer.ashfall.cooking.meals")

local function applyFoodBuff(foodId)
    for _, meal in pairs(meals) do
        if meal.id == foodId then
            meal:applyBuff()
            temperatureController.update("applyFoodBuff")
        end
    end
end

local function onEquip(e)    
    if hungerCommon.isFood(e.item) then
        hungerCommon.eatAmount(hungerCommon.getFoodValue(e.item, e.itemData))
        applyFoodBuff(e.item.id)

        --Check for food poisoning
        if foodTypes.ingredTypes[e.item.id] == foodTypes.TYPE.protein then
            local cookedAmount = e.itemData and e.itemData.data.cookedAmount or 0
            if cookedAmount then
                local chance = 1 - ( cookedAmount / 100 )
                if math.random() < chance then
                    common.helper.tryContractDisease("ashfall_d_foodPoison")
                end
            end
        end
    end
end

event.register("equip", onEquip, { filter = tes3.player } )