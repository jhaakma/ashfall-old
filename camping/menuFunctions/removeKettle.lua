return {
    text = "Remove Kettle",
    requirements = function(campfire)
        return (
            campfire.data.hasKettle and
            ( not campfire.data.waterAmount or
            campfire.data.waterAmount == 0 )
        )
    end,
    callback = function(campfire)
        mwscript.addItem{ reference = tes3.player, item = "ashfall_kettle" }
        campfire.data.hasKettle = false
        tes3.playSound{ reference = tes3.player, sound = "Item Misc Up"  }
        event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
    end
}