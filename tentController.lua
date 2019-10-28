local common = require("mer.ashfall.common.common")

local this = {}

local temperatureController = require("mer.ashfall.temperatureController")
temperatureController.registerExternalHeatSource("tentTemp")

local inTentGlobal = tes3.findGlobal("a_inside_tent")
function this.checkTent()
    if inTentGlobal.value == 1 then
        --common.log.info("Inside tent")
        common.data.isSheltered = true
        common.data.tentTemp = 20
    else
        --common.log.info("Outside tent")
        common.data.tentTemp = 0
    end
    
end

--When sleeping in a tent, you can't be woken up by creatures
local function calcRestInterrupt(e)
    if inTentGlobal.value == 1 then
        e.count = 0
    end
end

event.register("calcRestInterrupt", calcRestInterrupt)

return this
