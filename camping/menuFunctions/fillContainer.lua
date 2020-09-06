local thirstController = require("mer.ashfall.needs.thirstController")

return  {
    text = "Fill Container",
    requirements = function(campfire)
        return (
            campfire.data.waterAmount and 
            campfire.data.waterAmount > 0 and
            not campfire.data.stewLevels and
            ( 
                (not campfire.data.teaType) or
                campfire.data.teaProgress >= 100
            )
        )
    end,
    callback = function(campfire)
        --fill bottle
        local teaType
        if campfire.data.teaProgress and campfire.data.teaProgress >= 100 then
            teaType = campfire.data.teaType
        end
        thirstController.fillContainer{
            source = campfire.data,
            teaType = teaType,
            callback = function()
                if campfire.data.waterAmount <= 0 then
                    event.trigger("Ashfall:Campfire_clear_utensils", { campfire = campfire})
                end
            end
        }
        
    end
}