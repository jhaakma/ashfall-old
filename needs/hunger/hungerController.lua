local this = {}
local common = require("mer.ashfall.common.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")
local foodTypes = require("mer.ashfall.camping.foodTypes")
local meals = require("mer.ashfall.cooking.meals")

local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerBaseTempMultiplier({ id = "hungerEffect", coldOnly = true })

local coldMulti = 2.0
local HUNGER_EFFECT_LOW = 1.3
local HUNGER_EFFECT_HIGH = 1.0
local restMultiplier = 1.0

function this.isFood(foodObject)
    local config = mwse.loadConfig("ashfall/config")
    if not config then 
        common.log.info("Error: no config found")
    end
    local mod = foodObject.sourceMod and foodObject.sourceMod:lower()
    return (
        foodObject.objectType == tes3.objectType.ingredient and
        not config.blocked[foodObject.id] and
        not config.blocked[mod]
    )
end

function this.getBurnLimit()
    --TODO: Use cooking skill to determine
    local cooking = common.skills.cooking.value
    if not cooking then
        common.log.error("No cooking skill found")
        return 150
    end
    
    local burnLimit = math.remap(cooking, common.skillStartValue, 100, 120, 160)
    return burnLimit
end

function this.getFoodValue(object, itemData)

    if not foodTypes.nutrition[foodTypes.ingredTypes[object.id]] then
        common.log.error("No value found for %s", object.id)
    end

    local value = foodTypes.nutrition[foodTypes.ingredTypes[object.id]] or foodTypes.nutrition[foodTypes.TYPE.misc]

    local cookedAmount = itemData and itemData.data.cookedAmount
    if cookedAmount then
        local cooking = common.skills.cooking.value
        local cookingEffect = math.remap(
            cooking, 
            common.skillStartValue, 100, 
            foodTypes.cookedMultiMin, foodTypes.cookedMultiMax
        )

        local min = value
        local max = math.ceil(value * cookingEffect)

        if cookedAmount < this.getBurnLimit() then
            --value based on how cooked it is
            cookedAmount = math.min(cookedAmount, 100)
            value = math.remap(cookedAmount, 0, 100, min, max)
        else
            --half value when burned
            value = ( ( max - min ) / 2 ) + min
        end
    end
    return value
end


function this.eatAmount( amount ) 
    if not common.data.mcmSettings.enableHunger then
        return
    end

    local currentHunger = common.data.hunger or  0
    local amountAte = math.min(amount, currentHunger)
    common.data.hunger = currentHunger - amountAte
    conditionsCommon.updateCondition("hunger")
    this.calculate(0)
    temperatureController.update("eatAmount")
    needsUI.updateNeedsUI()
    hud.updateHUD()
    return amountAte
end



function this.processMealBuffs(scriptInterval)
    --decrement buff time
    if common.data.mealTime and common.data.mealTime > 0 then
        common.data.mealTime = math.max(common.data.mealTime - scriptInterval, 0)

    --Time's up, remove buff
    elseif common.data.mealBuff then
        mwscript.removeSpell({ reference = tes3.player, spell = common.data.mealBuff })
        common.data.mealBuff = nil
    end
end

function this.calculate(scriptInterval)
    
    --Check Ashfall disabled
    local hungerEnabled = (
        common.data.mcmSettings.enableHunger
    )
    if not hungerEnabled then
        common.data.hunger = 0
        return
    end

    local hungerRate = common.data.mcmSettings.hungerRate / 10

    local hunger = common.data.hunger or 0
    local temp = common.data.temp or 0

    --Colder it gets, the faster you grow hungry
    local coldEffect = math.clamp(temp, -100, 0) 
    
    coldEffect = math.remap( coldEffect, -100, 0, coldMulti, 1.0)

    --calculate hunger
    local resting = (
        tes3.mobilePlayer.sleeping or
        tes3.menuMode()
    )
    if resting then
        hunger = hunger + ( scriptInterval * hungerRate * coldEffect * restMultiplier )
    else
        hunger = hunger + ( scriptInterval * hungerRate * coldEffect )
    end
    hunger = math.clamp( hunger, 0, 100 )
    common.data.hunger = hunger

    --The hungrier you are, the more extreme cold temps are
    local hungerEffect = math.remap( hunger, 0, 100, HUNGER_EFFECT_HIGH, HUNGER_EFFECT_LOW )
    common.data.hungerEffect = hungerEffect
end

local function applyFoodBuff(foodId)
    for _, meal in pairs(meals) do
        if meal.id == foodId then
            meal:applyBuff()
            temperatureController.update("applyFoodBuff")
        end
    end
end

local function onEquip(e)    
    if this.isFood(e.item) then
        this.eatAmount(this.getFoodValue(e.item, e.itemData))
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

return this