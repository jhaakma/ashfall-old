local thirstController = require("mer.ashfall.needs.thirstController")

return  {
    text = "Fill Container",
    requirements = function(campfire)
        return (
            campfire.data.waterAmount and 
            campfire.data.waterAmount > 0 and
            not campfire.data.stewLevels
        )
    end,
    callback = function(campfire)
        --fill bottle
        thirstController.fillContainer{
            source = campfire.data,
            callback = function()
                if campfire.data.waterAmount <= 0 then
                    event.trigger("Ashfall:Campfire_clear_pot", { campfire = campfire})
                end
            end
        }

    end
}