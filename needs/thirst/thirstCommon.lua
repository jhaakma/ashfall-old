
local this = {}
local common = require("mer.ashfall.common")
local conditionsCommon = require("mer.ashfall.conditionController")
local needsUI = require("mer.ashfall.needs.needsUI")
local hud = require("mer.ashfall.ui.hud")
this.containerList = {
    bottles = {
        "misc_com_bottle_01",
        "misc_com_bottle_02",
        "Misc_Com_Bottle_04",
        "misc_com_bottle_05",
        "misc_com_bottle_06",
        "Misc_Com_Bottle_08",
        "misc_com_bottle_09",
        "misc_com_bottle_10",
        "misc_com_bottle_11",
        "misc_com_bottle_13",
        "Misc_Com_Bottle_14",
        "misc_com_bottle_14_float",
        "misc_com_bottle_15",
    },
    flasks = {
        "misc_flask_01",
        "misc_flask_02",
        "misc_flask_03",
        "misc_flask_04",
    },
    partialFilled = {
        bottleHalf = "fw_water_bottle_half",
        bottleLow = "fw_water_bottle_low",
        flaskHalf = "fw_water_flask_half",
        flaskLow = "fw_water_flask_low",
    },
    filledBottles = {
        bottleFull = "fw_water_bottle_full",
        bottleHalf = "fw_water_bottle_half",
        bottleLow = "fw_water_bottle_low",       
    },
    filledFlasks = {
        flaskFull = "fw_water_flask_full",
        flaskHalf = "fw_water_flask_half",
        flaskLow = "fw_water_flask_low",
    }
}

function this.isDrink(foodObject)
    local config = mwse.loadConfig("ashfall/config")
    if not config then 
        mwse.log("Error: no config found")
    end
    local mod = foodObject.sourceMod and foodObject.sourceMod:lower()
    return (
        foodObject.objectType == tes3.objectType.alchemy and
        not config.blocked[foodObject.id] and
        not config.blocked[mod]
    )
end

function this.drinkAmount( amount )
    local currentThirst = common.data.thirst or 0
    common.data.thirst = math.max( ( currentThirst - amount ), 0 )
    conditionsCommon.updateCondition("thirst")
    needsUI.updateNeedsUI()
    hud.updateHUD()
    if common.data.thirst <= 0.001 then
        tes3.messageBox("You are fully hydrated.")
    end
end

return this