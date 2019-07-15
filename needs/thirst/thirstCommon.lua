
local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")
local skillModule = require("OtherSkills.skillModule")

this.capacities = {
    cup = 50,
    goblet = 50,
    mug = 60,
    flask = 80,
    tankard = 100,
    bottle = 120,
    jug = 150,
    pitcher = 180,
    cookingPot = 200,
    kettle = 120,
    MAX = 200
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



function this.drinkAmount( amount, drinkingDirtyWater )
    local currentThirst = common.data.thirst or 0
    
    if currentThirst <= 0.1 then
        tes3.messageBox("You are fully hydrated.")
        return 0
    end
    local amountDrank = math.min( currentThirst, amount )
    common.data.thirst = common.data.thirst - amountDrank
    conditionsCommon.updateCondition("thirst")
    needsUI.updateNeedsUI()
    hud.updateHUD()

    tes3.playSound({reference = tes3.player, sound = "Drink"})

    if drinkingDirtyWater == true then
        common.tryContractDisease("ashfall_d_dysentry")
    end
    return amountDrank
end



function this.callWaterMenuAction(callback)
    if common.data.drinkingRain then
        mwse.log("fading out")
        common.data.drinkingRain = false
        common.fadeTimeOut( 0.25, 2, callback )
    else
        callback()
    end
    common.data.drinkingDirtyWater = nil
end

--Fill a bottle to max water capacity
function this.fillContainer(source, returnFunction)
    --mwse.log("before delay one frame: %s", tes3.getSimulationTimestamp())
    timer.delayOneFrame(function()
        --mwse.log("after delay one frame: %s", tes3.getSimulationTimestamp())
        tes3ui.showInventorySelectMenu{
            title = "Select Water Container",
            noResultsText = "You have no containers to fill.",
            filter = function(e)
                local bottleData = this.getBottleData(e.item.id)
                if bottleData then
                    local capacity = bottleData.capacity
                    local currentAmount = e.itemData and e.itemData.data.waterAmount or 0
                    return currentAmount < capacity
                else
                    return false
                end
            end,
            callback = function(e)
                
                if not e.item then 
                    return 
                end
                this.callWaterMenuAction(function()
                    --initialise itemData
                    local itemData = e.itemData
                    if not itemData then
                        itemData = tes3.addItemData{ 
                            to = tes3.player, 
                            item = e.item,
                            updateGUI = true
                        }
                    end

                    --dirty container if drinking from raw water
                    if common.data.drinkingDirtyWater then
                        itemData.data.waterDirty = true
                        common.data.drinkingDirtyWater = nil
                    end
                    local fillAmount
                    local bottleData = this.getBottleData(e.item.id)
                    
                    
                    itemData.data.waterAmount = itemData.data.waterAmount or 0
                    if source then
                        fillAmount = math.min(
                            bottleData.capacity,
                            itemData.data.waterAmount + source.waterAmount
                        )
                        itemData.data.waterAmount = fillAmount
                        source.waterAmount = math.max(source.waterAmount - fillAmount, 0)
                        --clean source if empty
                        if source.waterDirty then
                            itemData.data.waterDirty = true
                        end
                        if source.waterAmount == 0 then
                            mwse.log("cleaning source")
                            source.waterDirty = nil
                        end
                    else
                        fillAmount = bottleData.capacity
                    end

                    

                    itemData.data.waterAmount = fillAmount
                    tes3ui.updateInventoryTiles()
                    tes3.playSound({reference = tes3.player, sound = "Swim Left"})
                    tes3.messageBox(
                        "%s filled with %swater.",
                        e.item.name,
                        (itemData.data.waterDirty and "dirty " or "")
                    )

                    if returnFunction then returnFunction() end
                end)
            end
        }
    end
    )
end

return this
