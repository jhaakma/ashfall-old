return {
    text = "Empty Kettle",
    requirements = function(campfire)
        return (
            campfire.data.utensil == "kettle" and
            ( campfire.data.waterAmount and
            campfire.data.waterAmount > 0 )
        )
    end,
    callback = function(campfire)
        event.trigger("Ashfall:Campfire_clear_utensils", { campfire = campfire})
        tes3.playSound{ reference = tes3.player, pitch = 0.8, sound = "Swim Left" }
        --event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
    end
}