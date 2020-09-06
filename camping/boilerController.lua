--[[
    --Handles the heating and cooling of objects that can boil water
]]
local common = require ("mer.ashfall.common.common")

local waterHeatRate = 40--base water heat/cooling speed
local updateInterval = 0.001
local minFuelWaterHeat = 5--min fuel multiplier on water heating
local maxFuelWaterHeat = 10--max fuel multiplier on water heating


local function updateBoilers(e)
    
    local function doUpdate(boilerRef)
        boilerRef.data.lastWaterUpdated = boilerRef.data.lastWaterUpdated or e.timestamp
        local difference = e.timestamp - boilerRef.data.lastWaterUpdated

        if difference > updateInterval then
            local hasFilledPot = (
                boilerRef.data.waterAmount and 
                boilerRef.data.waterAmount > 0
            )
            if hasFilledPot then
                boilerRef.data.waterHeat = boilerRef.data.waterHeat or 0
                boilerRef.data.lastWaterUpdated = e.timestamp
                local heatEffect = -1--negative if cooling down
                if boilerRef.data.isLit then--based on fuel if heating up
                    heatEffect = math.remap(boilerRef.data.fuelLevel, 0, common.staticConfigs.maxWoodInFire, minFuelWaterHeat, maxFuelWaterHeat)
                end
                local heatBefore = boilerRef.data.waterHeat
                boilerRef.data.waterHeat = math.clamp((boilerRef.data.waterHeat + ( difference * waterHeatRate * heatEffect )), 0, 100)
                local heatAfter = boilerRef.data.waterHeat

                --add boiling sound
                if heatBefore < common.staticConfigs.hotWaterHeatValue and heatAfter > common.staticConfigs.hotWaterHeatValue then
                    tes3.playSound{
                        reference = boilerRef, 
                        sound = "ashfall_boil"
                    }
                end
                --remove boiling sound
                if heatBefore > common.staticConfigs.hotWaterHeatValue and heatAfter < common.staticConfigs.hotWaterHeatValue then
                    tes3.removeSound{
                        reference = boilerRef, 
                        sound = "ashfall_boil"
                    }
                end

                if boilerRef.data.waterHeat > common.staticConfigs.hotWaterHeatValue then
                    boilerRef.data.waterDirty = nil
                end
            else
                boilerRef.data.lastWaterUpdated = nil
            end
        end
    end
    common.helper.iterateRefType("boiler", doUpdate) 
end

 event.register("simulate", updateBoilers)
