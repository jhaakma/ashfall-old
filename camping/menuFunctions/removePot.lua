local common = require ("mer.ashfall.common.common")

return  {
    text = "Remove Pot",
    requirements = function(campfire)
        return (
            campfire.data.utensil == "cookingPot" and
            ( not campfire.data.waterAmount or
            campfire.data.waterAmount == 0 )
        )
    end,
    callback = function(campfire)
        mwscript.addItem{ reference = tes3.player, item = common.staticConfigs.objectIds.cookingPot }
        event.trigger("Ashfall:Campfire_clear_utensils", { campfire = campfire})
        campfire.data.utensil = nil
        tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
        --event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
    end
}