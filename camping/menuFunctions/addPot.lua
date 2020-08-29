local common = require ("mer.ashfall.common.common")

return  {
    text = "Attach Cooking Pot",
    requirements = function(campfire)
        return (
            campfire.data.hasSupports and 
            not ( campfire.data.hasKettle or campfire.data.hasCookingPot ) and
            mwscript.getItemCount{ reference = tes3.player, item = common.staticConfigs.objectIds.cookingPot} > 0
        )
    end,
    callback = function(campfire)
        mwscript.removeItem{ reference = tes3.player, item = common.staticConfigs.objectIds.cookingPot }
        campfire.data.hasCookingPot = true
        tes3.playSound{ reference = tes3.player, sound = "Item Misc Down"  }
        event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
    end
}