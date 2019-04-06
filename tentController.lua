local common = require("mer.ashfall.common")
local logger = require("mer.ashfall.logger")

local this = {}

local inTentGlobal = tes3.findGlobal("a_inside_tent")
function this.checkTent()
    if inTentGlobal.value == 1 then
        --logger.info("Inside tent")
        common.data.isSheltered = true
        common.data.tentTemp = 20
    else
        --logger.info("Outside tent")
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
