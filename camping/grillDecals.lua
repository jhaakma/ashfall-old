local common = require ("mer.ashfall.common.common")

local cookStates = {
    cooked = {texPath = "textures\\Ashfall\\grill\\cooked.dds"},
    burnt = {texPath = "textures\\Ashfall\\grill\\burnt.dds"}
}

local function traverseNIF(roots)
    local function iter(nodes)
        for i, node in ipairs(nodes or roots) do
            if node then
                coroutine.yield(node)
                if node.children then
                    iter(node.children)
                end
            end
        end
    end
    return coroutine.wrap(iter)
end


--pre-load textures
local function preloadTextures()
    common.log:debug("Preloading Grill textures")
    for _, cookState in pairs(cookStates) do
        local texture = niSourceTexture.createFromPath(cookState.texPath)
        cookState.texture = texture
    end
end
preloadTextures()


local function addDecal(property, grillState)
    local decal 
    if grillState then
        decal = cookStates[grillState].texture
    end
    --Remove old one if it exists
    for index, map in ipairs(property.maps) do
        local texture = map and map.texture
        local fileName = texture and texture.fileName
        
        if fileName then
            common.log:debug("fileName: %s", fileName)
            for _, cookState in pairs(cookStates) do
                if fileName == cookState.texPath then
                    if decal then
                        common.log:debug("Found existing decal, replacing with %s", decal.fileName)
                        map.texture = decal
                    else
                        common.log:debug("Removing existing decal")
                        property:removeDecalMap(index)
                    end
                    return
                end
            end
        end
    end

    if decal then
        --Add new decal
        if property.canAddDecal then
            property:addDecalMap(decal)
            common.log:debug("Adding new decal")
        end
    end
end

local function updateIngredient(e)
    local reference = e.reference
    local grillState = e.reference.data.grillState

    common.log:debug("Updating %s decal for %s",
        grillState or "(removing)",
        reference.id
    )
   
    for node in traverseNIF{ reference.sceneNode} do
        local success, texturingProperty, alphaProperty = pcall(function() return node:getProperty(0x4), node:getProperty(0x0) end)
        if (success and texturingProperty and not alphaProperty) then
            local clonedProperty = node:detachProperty(0x4):clone()
            node:attachProperty(clonedProperty)
            node:updateProperties()
            addDecal(clonedProperty, grillState)
        end
    end
end

event.register("Ashfall:ingredCooked", updateIngredient)


local function ingredPlaced(e)
    local grillState = (
        e.reference and
        (not common.helper.isStack(e.reference) ) and
        e.reference.data and
        e.reference.data.grillState
    )
    if grillState ~= nil then
        common.log:debug("is grilled food")
        if grillState == "cooked" then
            common.log:debug("Placed cooked ingredient")
            updateIngredient{ reference = e.reference}
        elseif grillState == "burnt" then
            common.log:debug("Placed burnt ingredient")
            updateIngredient{ reference = e.reference}
        else
            common.log:error("invalid grillState")
        end
    end
end
event.register("referenceSceneNodeCreated", ingredPlaced)