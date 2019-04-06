--[[
    CampFirePart is an object that can be attached to a campfire, 
    such as firewood or a cooking utensil.
]]--

local logger = require("mer.ashfall.logger")

local CampFirePart = {}
CampFirePart.name = "CampFirePart"
CampFirePart.nifId = nil
CampFirePart._object = nil

function CampFirePart:new(data)
    local t = data or {}
    setmetatable(t, self)
    self.__index = self
    return t
end

function CampFirePart:loadMesh()
    return tes3.loadMesh(self.nifId):clone()
end


--[[
    Attaches the utensil mesh to a reference with an "attach" node
]]--
function CampFirePart:attach(reference)
    local node = reference.sceneNode:getObjectByName("attach")
    if node then
        local nif = self:loadMesh()  
        if nif then
            logger.info("attaching nif")
            node:attachChild(nif, true)
            reference:updateSceneGraph()
            reference.sceneNode:updateNodeEffects()
        end
    else
        logger.info("No 'attach' node found for %s", reference.id)
    end
end

return CampFirePart