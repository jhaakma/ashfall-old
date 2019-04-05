local hungerCommon = require("mer.ashfall.needs.hunger.hungerCommon")
local common = require("mer.ashfall.common")
local meals = require("mer.ashfall.cooking.meals")
local function applyFoodBuff(foodId)
    for _, meal in pairs(meals) do
        if meal.id == foodId then
            meal:applyBuff()
        end
    end
    mwse.log("Regular ingredient")
end

local function onEquip(e)    
    if hungerCommon.isFood(e.item) then
        hungerCommon.eatAmount(hungerCommon.getFoodValue(e.item.id))
        applyFoodBuff(e.item.id)
    end
end

event.register("equip", onEquip, { filter = tes3.player } )