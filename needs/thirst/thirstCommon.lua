
local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")

this.capacities = {
    cup = 20,
    goblet = 20,
    mug = 25,
    tankard = 30,
    flask = 35,
    bottle = 40,
    jug = 70,
    pitcher = 100,
    MAX = 100
}

this.bottleList = {
    --cups
    misc_com_redware_cup = { capacity = this.capacities.cup },
    misc_com_wood_cup_01 = { capacity = this.capacities.cup },
    misc_com_wood_cup_02 = { capacity = this.capacities.cup },
    misc_lw_cup = { capacity = this.capacities.cup },
    misc_imp_silverware_cup = { capacity = this.capacities.cup },
    misc_imp_silverware_cup_01 = { capacity = this.capacities.cup },

    --goblets
    misc_com_metal_goblet_01 = { capacity = this.capacities.goblet },
    misc_com_metal_goblet_02 = { capacity = this.capacities.goblet },
    misc_de_goblet_01 = { capacity = this.capacities.goblet },
    misc_de_goblet_02 = { capacity = this.capacities.goblet },
    misc_de_goblet_03 = { capacity = this.capacities.goblet },
    misc_de_goblet_04 = { capacity = this.capacities.goblet },
    misc_de_goblet_05 = { capacity = this.capacities.goblet },
    misc_de_goblet_06 = { capacity = this.capacities.goblet },
    misc_de_goblet_07 = { capacity = this.capacities.goblet },
    misc_de_goblet_08 = { capacity = this.capacities.goblet },
    misc_de_goblet_09 = { capacity = this.capacities.goblet },
    misc_dwrv_goblet00 = { capacity = this.capacities.goblet },
    misc_dwrv_goblet10 = { capacity = this.capacities.goblet },
    misc_dwrv_goblet00_uni = { capacity = this.capacities.goblet },
    misc_dwrv_goblet10_uni = { capacity = this.capacities.goblet },
    misc_dwrv_goblet10_tgcp = { capacity = this.capacities.goblet },
    misc_de_goblet_01_redas = { capacity = this.capacities.goblet },

    --tankards
    misc_com_tankard_01 = { capacity = this.capacities.tankard },
    misc_de_tankard_01 = { capacity = this.capacities.tankard },


    --mugs
    misc_dwrv_mug00 = { capacity = this.capacities.mug },
    misc_dwrv_mug00_uni = { capacity = this.capacities.mug },

    --flasks
    misc_flask_01 = { capacity = this.capacities.flask },
    misc_flask_02 = { capacity = this.capacities.flask },
    misc_flask_03 = { capacity = this.capacities.flask },
    misc_flask_04 = { capacity = this.capacities.flask },
    misc_com_redware_flask = { capacity = this.capacities.flask },
    misc_lw_flask = { capacity = this.capacities.flask },

    --bottles
    misc_com_bottle_01 = { capacity = this.capacities.bottle },
    misc_com_bottle_02 = { capacity = this.capacities.bottle },
    misc_com_bottle_04 = { capacity = this.capacities.bottle },
    misc_com_bottle_05 = { capacity = this.capacities.bottle },
    misc_com_bottle_06 = { capacity = this.capacities.bottle },
    
    misc_com_bottle_08 = { capacity = this.capacities.bottle },
    misc_com_bottle_09 = { capacity = this.capacities.bottle },
    misc_com_bottle_10 = { capacity = this.capacities.bottle },
    misc_com_bottle_11 = { capacity = this.capacities.bottle },
    misc_com_bottle_13 = { capacity = this.capacities.bottle },
    misc_com_bottle_14 = { capacity = this.capacities.bottle },
    misc_com_bottle_14_float = { capacity = this.capacities.bottle },
    misc_com_bottle_15 = { capacity = this.capacities.bottle },

    --jugs
    misc_com_bottle_03 = { capacity = this.capacities.jug },
    misc_com_bottle_07 = { capacity = this.capacities.jug },
    misc_com_bottle_07_float = { capacity = this.capacities.jug },
    misc_com_bottle_12 = { capacity = this.capacities.jug },

    --pitchers
    misc_de_pitcher_01 = { capacity = this.capacities.pitcher },
    misc_com_redware_pitcher = { capacity = this.capacities.pitcher },
    misc_com_pitcher_metal_01 = { capacity = this.capacities.pitcher },
    misc_dwrv_pitcher00 = { capacity = this.capacities.pitcher },
    misc_dwrv_pitcher00_uni = { capacity = this.capacities.pitcher },
    misc_imp_silverware_pitcher = { capacity = this.capacities.pitcher },
    misc_imp_silverware_pitcher_uni = { capacity = this.capacities.pitcher },
}

function this.getBottleData(id)
    return this.bottleList[string.lower(id)]
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
