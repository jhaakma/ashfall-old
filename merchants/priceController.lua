local waterMulti = 5.0
local cookedMulti = 1.0

local function calcItemDataPrice(e)
    local waterAmount = e.itemData and e.itemData.data.waterAmount
    if waterAmount then
        local multi = math.remap(waterAmount, 0, 100, 1.0, waterMulti)
        e.price = math.max(1, e.price * multi)
    end

    local cookedAmount = e.itemData and e.itemData.data.cookedAmount
    if cookedAmount then
        local multi = math.remap(cookedAmount, 0, 100, 1.0, cookedMulti)
        e.price = math.max(1, e.price * multi)
    end
end

event.register("calcBarterPrice", calcItemDataPrice)