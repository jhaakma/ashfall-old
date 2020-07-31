
local activatorConfig = require("mer.ashfall.config.activatorConfig")
local this = {}

this.controllers = {}
local ReferenceController = {
    new = function(self, o)
        o = o or {}   -- create object if user does not provide one
        setmetatable(o, self)
        self.__index = self
        return o
    end,

    addReference = function(self, ref)
        self.references[ref] = true
    end,

    removeReference = function(self, ref)
            self.references[ref] = nil
    end,

    references = nil,
    requirements = nil
}

this.controllers.campfire = ReferenceController:new{
    references = {},
    requirements = function(self, ref)
        return activatorConfig.list.campfire:isActivator(ref.object.id)
    end
}


local function onRefPlaced(e)
    for controllerName, controller in pairs(this.controllers) do
        if controller:requirements(e.reference) then
            controller:addReference(e.reference)
        end
    end
end
event.register("referenceSceneNodeCreated", onRefPlaced)


local function onObjectInvalidated(e)
    local ref = e.object
    for _, controller in pairs(this.controllers) do
        if controller.references[ref] == true then
            controller:removeReference(ref)
        end
    end
end

event.register("objectInvalidated", onObjectInvalidated)

return this