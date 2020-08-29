local common = require ("mer.ashfall.common.common")

return {
    text = "Destroy Campfire",
    requirements = function(campfire)
        return (
            not campfire.data.hasGrill and 
            not campfire.data.hasCookingPot and
            not campfire.data.isLit
        )
    end,
    callback = function(campfire)
        campfire.data.destroyed = true
        local recoveredFuel =  math.floor(campfire.data.fuelLevel / 2)
        if campfire.data.hasSupports then
            recoveredFuel = recoveredFuel + 3
        end
        if not campfire.data.isLit and recoveredFuel >= 1 then
            mwscript.addItem{
                reference = tes3.player, 
                item = common.staticConfigs.objectIds.firewood,
                count = recoveredFuel
            }
            tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
            tes3.messageBox(tes3.findGMST(tes3.gmst.sNotifyMessage61).value, recoveredFuel, tes3.getObject(common.staticConfigs.objectIds.firewood).name)
        end

        event.trigger("Ashfall:Campfire_Extinguish", {campfire = campfire})
        event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
        common.helper.yeet(campfire)
    end
}