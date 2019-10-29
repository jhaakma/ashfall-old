--[[
    lightNodeHeight: set height to 0 in mesh, then 
        set lightNodeHeight here to where it will appear
        just above the flame

    grillingVars: How close ingred needs to be to grill
        minHeight/maxHeight vertical limits
        distance is for horizontal diameter
]]
local this = {}
this.TYPE = {
    campfire = {
        fuelLimit = 12,
        lightNodeHeight = 25,
        grillingVars = {
            minHeight = 21,
            maxHeight = 35,
            distance = 40
        },
        canAddSupports = true,
        canAddGrill = true,
        grillSupplied = false,
        canWait = true,
    },

    hibachi = {
        fuelLimit = 3,
        lightNodeHeight = 20,
        grillingVars = {
            minHeight = x,
            maxHeight = x,
            distance = x
        },
        canAddSupports = false,
        canAddGrill = false,
        grillSupplied = true,
        canWait = false,
    }
}
this.ids = {
    ["ashfall_campfire_01"] = this.TYPE.campfire,
    ["ashfall_hibachi_01"] = this.TYPE.hibachi
}

return this