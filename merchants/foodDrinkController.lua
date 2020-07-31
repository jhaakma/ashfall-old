local common = require("mer.ashfall.common.common")



local foodConfig = common.staticConfigs.foodConfig
local function onReferenceSceneNodeCreated(e)
    local obj = e.reference.baseObject or e.reference.object
    if obj.objectType == tes3.objectType.container then
        common.log:debug("\n%s is a container", obj.name)
        local owner = tes3.getOwner(e.reference)
        if owner and owner.class.id == "Publican" then

            common.log:debug("Owned by %s", owner.name)
            e.reference:clone()
            
            common.log:debug("Cloning")
            for _, stack in pairs(obj.inventory) do
                common.log:debug("item: %s", stack.object.id)
                if stack.object.objectType == tes3.objectType.ingredient then
                    common.log:debug("%s is ingredient", stack.object.name)
                    local foodType = foodConfig.ingredTypes[stack.object.id]
                    
                    if foodConfig.grillValues[foodType] then
                        common.log:debug("Is cookable food")
                        if stack.variables then
                            for _, itemData in pairs(stack.variables) do
                                if not itemData then
                                    common.log:debug("no itemData")
                                    itemData = tes3.addItemData{
                                        to = e.reference,
                                        item = stack.object,
                                        updateGUI = true
                                    }
                                    common.log:debug("stack count: %s", stack.count)
                                    itemData.count = stack.count
                                end
                                common.log:debug("ADDING cooked amount for %s", stack.object.name)
                                itemData.data.cookedAmount = 100
                            end
                        end
                    end
                end
            end
            e.reference.object.modified = true
            e.reference.object:onInventoryClose(e.reference)
        end
    end
end
--event.register("referenceSceneNodeCreated", onReferenceSceneNodeCreated)