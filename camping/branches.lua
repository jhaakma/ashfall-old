local common = require("mer.ashfall.common.common")

local function onActivate(e)
    if string.lower(e.target.object.id) == common.staticConfigs.objectIds.branch then
        mwscript.disable{ reference = e.target }
        mwscript.setDelete{ reference = e.target}

        tes3.addItem{
            reference = tes3.player,
            item = common.staticConfigs.objectIds.firewood,
            playSound = true,
        }
        tes3.messageBox("Collected 1 firewood.")
        return false
    end
end

event.register("activate", onActivate)
