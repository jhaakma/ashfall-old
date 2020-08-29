local common = require ("mer.ashfall.common.common")
local thirstController = require("mer.ashfall.needs.thirstController")

return {
    text = "Drink",
    requirements = function(campfire)
        return (
            campfire.data.waterAmount and 
            campfire.data.waterAmount > 0 and
            not campfire.data.stewLevels
        )
    end,
    callback = function(campfire)
        local function doDrink()
            --tes3.playSound{ reference = tes3.player, sound = "Swallow" }
            local amountToDrink = math.min(common.staticConfigs.capacities.cookingPot / common.staticConfigs.stewMealCapacity, campfire.data.waterAmount)
            local amountDrank = thirstController.drinkAmount(amountToDrink, campfire.data.waterDirty)
            campfire.data.waterAmount = campfire.data.waterAmount - amountDrank
            if campfire.data.waterAmount == 0 then
                event.trigger("Ashfall:Campfire_clear_pot", { campfire = campfire})
            end
            event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
        end


        if campfire.data.waterDirty then
            common.helper.messageBox{
                message = "This water is dirty.",
                buttons = {
                    { 
                        text = "Drink", 
                        callback = function() doDrink() end 
                    },
                    { 
                        text = "Empty Cooking Pot", 
                        callback = function()
                            tes3.playSound{ reference = tes3.player, pitch = 0.8, sound = "Swim Left"} 
                            event.trigger("Ashfall:Campfire_clear_pot", { campfire = campfire})
                            event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
                        end
                    },
                    { text = tes3.findGMST(tes3.gmst.sCancel).value }
                }
            }
        else
            doDrink()
        end
    end
}