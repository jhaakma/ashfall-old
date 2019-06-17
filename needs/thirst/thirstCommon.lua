
local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")

this.capacities = {
    bottle = 50,
    jug = 100,
    flask = 50,
    MAX = 100
}

this.bottleList = {
    misc_com_bottle_01 = { capacity = this.capacities.bottle },
    misc_com_bottle_02 = { capacity = this.capacities.bottle },
    misc_com_bottle_03 = { capacity = this.capacities.jug },
    Misc_Com_Bottle_04 = { capacity = this.capacities.bottle },
    misc_com_bottle_05 = { capacity = this.capacities.bottle },
    misc_com_bottle_06 = { capacity = this.capacities.bottle },
    misc_com_bottle_07 = { capacity = this.capacities.bottle },
    misc_com_bottle_07_float = { capacity = this.capacities.jug },
    Misc_Com_Bottle_08 = { capacity = this.capacities.bottle },
    misc_com_bottle_09 = { capacity = this.capacities.bottle },
    misc_com_bottle_10 = { capacity = this.capacities.bottle },
    misc_com_bottle_11 = { capacity = this.capacities.bottle },
    misc_com_bottle_12 = { capacity = this.capacities.jug },
    misc_com_bottle_13 = { capacity = this.capacities.bottle },
    Misc_Com_Bottle_14 = { capacity = this.capacities.bottle },
    misc_com_bottle_14_float = { capacity = this.capacities.bottle },
    misc_com_bottle_15 = { capacity = this.capacities.bottle },
    misc_flask_01 = { capacity = this.capacities.flask },
    misc_flask_02 = { capacity = this.capacities.flask },
    misc_flask_03 = { capacity = this.capacities.flask },
    misc_flask_04 = { capacity = this.capacities.flask },
}

function this.getBottleCapacity(id)
    for _, bottle in ipairs(this.bottleList) do
        if bottle.id == id then
            return bottle.capacity
        end
    end
    return false
end


function this.drinkAmount( amount )
    local currentThirst = common.data.thirst or 0
    
    if currentThirst <= 0.1 then
        tes3.messageBox("You are fully hydrated.")
        return
    end

    common.data.thirst = math.max( ( currentThirst - amount ), 0 )
    conditionsCommon.updateCondition("thirst")
    needsUI.updateNeedsUI()
    hud.updateHUD()
    if common.data.thirst <= 0.01 then
        tes3.messageBox("You are fully hydrated.")
    end
    if amount > 1 then
        tes3.playSound({reference = tes3.player, sound = "Drink"})
    end
end


return this
