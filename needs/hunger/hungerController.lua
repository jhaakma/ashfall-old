local this = {}
local common = require("mer.ashfall.common.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")

local meals = require("mer.ashfall.cooking.meals")
local statsEffect = require("mer.ashfall.needs.statsEffect")

local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerBaseTempMultiplier({ id = "hungerEffect", coldOnly = true })

local coldMulti = 5.0
local HUNGER_EFFECT_LOW = 1.3
local HUNGER_EFFECT_HIGH = 1.0
local restMultiplier = 1.0

local hunger = common.staticConfigs.conditionConfig.hunger
local foodConfig = common.staticConfigs.foodConfig

function this.isFood(foodObject)
    local config = common.getConfig()
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

    if not foodConfig.nutrition[foodConfig.ingredTypes[object.id]] then
        common.log.error("No value found for %s", object.id)
    end
    local ingredType = foodConfig.ingredTypes[object.id]
    local value = foodConfig.nutrition[ingredType] or foodConfig.nutrition[foodConfig.TYPE.misc]
    --scale by weight
    value = value * math.remap(object.weight, 1, 2, 1, 1.5)

    local cookedAmount = itemData and itemData.data.cookedAmount
    if cookedAmount then
        local cooking = common.skills.cooking.value
        local cookingEffect = math.remap(
            cooking, 
            common.skillStartValue, 100, 
            foodConfig.grillValues[ingredType].min, foodConfig.grillValues[ingredType].max
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


    local currentHunger = hunger:getValue()
    local amountAte = math.min(amount, currentHunger)

    --Get the health stat before and after applying the hunger
    local before = statsEffect.getMaxStat("health")
    hunger:setValue(currentHunger - amountAte)
    local after = statsEffect.getMaxStat("health")

    --Increase health by how much was gained by eating
    local healthIncrease = after - before
    tes3.modStatistic{
        reference = tes3.mobilePlayer,
        current = healthIncrease,
        name = "health",
        limit = true
    }
    conditionsCommon.updateCondition("hunger")
    this.update()
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




function this.calculate(scriptInterval, forceUpdate)
    if not forceUpdate and scriptInterval == 0 then return end

    --Check Ashfall disabled
    if not hunger:isActive() then
        hunger:setValue(0)
        return
    end
    if common.data.blockNeeds == true then
        return
    end

    local hungerRate = common.data.mcmSettings.hungerRate / 10

    local newHunger = hunger:getValue()
    
    local temp = common.staticConfigs.conditionConfig.temp
    --Colder it gets, the faster you grow hungry
    local coldEffect = math.clamp(temp:getValue(), temp.states.freezing.min, temp.states.chilly.max) 
    
    coldEffect = math.remap( coldEffect, temp.states.freezing.min,  temp.states.chilly.max, coldMulti, 1.0)

    --calculate newHunger
    local resting = (
        tes3.mobilePlayer.sleeping or
        tes3.menuMode()
    )
    if resting then
        newHunger = newHunger + ( scriptInterval * hungerRate * coldEffect * restMultiplier )
    else
        newHunger = newHunger + ( scriptInterval * hungerRate * coldEffect )
    end
    hunger:setValue(newHunger)


    --The hungrier you are, the more extreme cold temps are
    local hungerEffect = math.remap( newHunger, 0, 100, HUNGER_EFFECT_HIGH, HUNGER_EFFECT_LOW )
    common.data.hungerEffect = hungerEffect
end

function this.update()
    this.calculate(0, true)
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
        if foodConfig.ingredTypes[e.item.id] == foodConfig.TYPE.protein then
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

event.register("equip", onEquip, { filter = tes3.player, priority = -100 } )

return this