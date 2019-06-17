local ui = require("mer.ashfall.tempEffects.ratings.ratingUI")
local ratings = require("mer.ashfall.tempEffects.ratings.ratings")
local common = require("mer.ashfall.common")

local function updateRatings()
    local warmth = ratings.getTotalWarmth()
    common.data.warmthRating = warmth

    local coverage = ratings.getTotalCoverage()
    common.data.coverageRating = coverage

    ui.updateRatingsUI()
end

 

event.register("unequipped", updateRatings)
event.register("equipped", updateRatings)
event.register("Ashfall:dataLoaded", updateRatings)