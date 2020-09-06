local common = require ("mer.ashfall.common.common")
return {
    text = "Remove Supports",
    requirements = function(campfire)
        return campfire.data.hasSupports and campfire.data.utensil == nil
    end,
    callback = function(campfire)
        mwscript.addItem{
            reference = tes3.player, 
            item = common.staticConfigs.objectIds.firewood,
            count = 3
        }
        campfire.data.hasSupports = false
        tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
        --event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
    end
}