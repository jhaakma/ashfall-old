local ui = require("mer.ashfall.tempEffects.ratings.ratingUI")
local ratings = require("mer.ashfall.tempEffects.ratings.ratings")
local common = require("mer.ashfall.common.common")

--Register heat source
local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerInternalHeatSource("warmthRating")
temperatureController.registerRateMultiplier("coverageMulti")

local function updateRatings()
    local warmth = ratings.getTotalWarmth()
    common.data.warmthRating = warmth

    local coverage = ratings.getTotalCoverage()
    common.data.coverageRating = coverage
    common.data.coverageMulti = math.remap(coverage, 0, 1, 1, 0.25 )

    
end

event.register("Ashfall:dataLoaded", function()
    updateRatings()
    ui.updateRatingsUI()

    timer.start({
        duration = 1,
        callback = function()

            event.register("unequipped", function()
                updateRatings()
                temperatureController.update()
                ui.updateRatingsUI()
            end)
            event.register("equipped", function()
                updateRatings()
                temperatureController.update()
                ui.updateRatingsUI()
            end)
        end
    })
end)