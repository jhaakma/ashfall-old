local common = require ("mer.ashfall.common.common")


local skillCookingStewIngredIncrement = 5
local skillSurvivalStewIngredIncrement  = 1
local stewIngredientCooldownAmount = 20
return {
    text = "Add Ingredient",
    requirements = function(campfire)
        return (
            campfire.data.hasCookingPot and
            campfire.data.waterAmount and
            campfire.data.waterAmount > 0
        )
    end,
    callback = function(campfire)
        local function ingredientSelect(foodType)
            timer.delayOneFrame(function()
                tes3ui.showInventorySelectMenu{
                    title = "Select Ingredient:",
                    noResultsText = string.format("You do not have any %ss.", string.lower(foodType)),
                    filter = function(e)
                        return (
                            e.item.objectType == tes3.objectType.ingredient and
                            common.staticConfigs.foodConfig.ingredTypes[e.item.id] == foodType
                            --Can only grill meat and veges
                        )
                    end,
                    callback = function(e)
                        if e.item then
                            --Cool down stew
                            campfire.data.stewProgress = campfire.data.stewProgress or 0
                            campfire.data.stewProgress = math.max(( campfire.data.stewProgress - stewIngredientCooldownAmount ), 0)

                            --initialise stew levels
                            campfire.data.stewLevels = campfire.data.stewLevels or {}
                            campfire.data.stewLevels[foodType] = campfire.data.stewLevels[foodType] or 0

                            --Add ingredient to stew
                            campfire.data.stewLevels[foodType] = (
                                campfire.data.stewLevels[foodType] +
                                (
                                    (
                                        common.staticConfigs.capacities.cookingPot / campfire.data.waterAmount
                                    ) / common.staticConfigs.stewMealCapacity
                                ) * 100
                            )

                            common.skills.cooking:progressSkill(skillCookingStewIngredIncrement)
                            common.skills.survival:progressSkill(skillSurvivalStewIngredIncrement)

                            
                            tes3.player.object.inventory:removeItem{
                                mobile = tes3.mobilePlayer,
                                item = e.item,
                                itemData = e.itemData
                            }
                            tes3ui.forcePlayerInventoryUpdate()
                            --mwscript.removeItem{ reference = tes3.player, item = e.item }
                            tes3.playSound{ reference = tes3.player, sound = "Swim Right" }
                            event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
                        end
                    end
                }
            end)
        end
        local ingredButtons = {
            { text = common.staticConfigs.foodConfig.TYPE.protein, callback = function() ingredientSelect(common.staticConfigs.foodConfig.TYPE.protein) end },
            { text = common.staticConfigs.foodConfig.TYPE.vegetable, callback = function() ingredientSelect(common.staticConfigs.foodConfig.TYPE.vegetable) end },
            { text = common.staticConfigs.foodConfig.TYPE.mushroom, callback = function() ingredientSelect(common.staticConfigs.foodConfig.TYPE.mushroom) end },
            { text = common.staticConfigs.foodConfig.TYPE.seasoning, callback = function() ingredientSelect(common.staticConfigs.foodConfig.TYPE.seasoning) end },
            { text = common.staticConfigs.foodConfig.TYPE.herb, callback = function() ingredientSelect(common.staticConfigs.foodConfig.TYPE.herb) end },

        }
        local buttons = {}
        --add buttons for ingredients that can be added
        for _, button in ipairs(ingredButtons) do
            local foodType = button.text
            local canAdd = (
                not campfire.data.stewLevels or
                not campfire.data.stewLevels[foodType] or 
                campfire.data.stewLevels[foodType] < 100
            )
            if canAdd then
                table.insert(buttons, button)
            end
        end

        table.insert(buttons, { text = tes3.findGMST(tes3.gmst.sCancel).value })

        common.helper.messageBox({
            message = "Select Ingredient Type:",
            buttons = buttons
        })

    end
}