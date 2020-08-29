return {
    text = "Extinguish",
    requirements = function(campfire)
        return campfire.data.isLit
    end,
    callback = function(campfire)
        event.trigger("Ashfall:Campfire_Extinguish", {campfire = campfire})
        event.trigger("Ashfall:Campfire_Update_Visuals", { campfire = campfire, all = true})
    end,
}