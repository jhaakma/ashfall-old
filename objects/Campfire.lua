
local common = require("mer.ashfall.common")
local logger = require("mer.ashfall.logger")
local CampFirePart = require("mer.ashfall.objects.CampFirePart")
local Utensil = require("mer.ashfall.objects.Utensil")
local utensils = require("mer.ashfall.cooking.utensils")
local CookingMenu = require("mer.ashfall.cooking.cookingMenu")
local Campfire = {}
Campfire.reference = {}
Campfire.litObject = "ashfall_campfire_lit"


function Campfire:new(data)
    data.reference.data.campfire = data.reference.data.campfire or {}
    local t = data
    setmetatable(t, self)
    self.__index = self
    return t
end


function Campfire:addFirewood()

    logger.info("adding firewood")
    local wood = CampFirePart:new{
        name = "Wood",
        nifId = "ashfall\\fp\\u\\wood.nif"
    }
    wood:attach(self.reference)
    self.fueled = true
end

function Campfire:lightFire()
    local newRef = mwscript.placeAtPC({ object = self.litObject })
    mwscript.disable({ reference = self.reference })

    newRef.position = self.reference.position
    newRef.orientation = self.reference.orientation
    newRef.data.campfire = {}
    newRef.data.campfire.parts = {}
    for key, value in ipairs(self.reference.data.campfire) do
        newRef.data.campfire[key] = value
    end   

    for _, part in ipairs(self.parts) do
        logger.info("part = %s", part.name)
        table.insert(newRef.data.campfire.parts, part)
        part:attach(newRef)    
    end

    mwscript.drop({reference = tes3.player, item = "a__lightreset"})
    self.reference = newRef
    self.lit = true
end

function Campfire:addSupports()
    local supports = CampFirePart:new{ 
        name = "Supports",
        nifId = "ashfall\\fp\\u\\supports.nif" 
    }
    supports:attach(self.reference)
    self.supports = true
end


function Campfire:cook()
    CookingMenu:new({name = "Camp Fire"}):create()
end



function Campfire:showMenu()
    local standardButtons = {

        addWood = {
            text = "Add Firewood",
            callback =  self.addFirewood,
        },
        lightFire = {
            text = "Light Fire",
            callback = self.lightFire,
        },
        addSupports = {
            text = "Add Supports",
            callback = self.addSupports,
        },
        cook = {
            text = "Cook Something",
            callback = self.cook,
        },
        wait = {
            text = tes3.findGMST(tes3.gmst.sWait).value,
            callback = self.wait,
        },
        cancel = {
            text = tes3.findGMST(tes3.gmst.sCancel).value,
            callback = function() return true end,
        }
    }
   
    local addButton = function(tbl, button)
        table.insert(tbl, {
            text = button.text, 
            callback = function()
                button.callback(self)
            end
        })
    end
    local buttons = {}
    --Add contextual buttons
    if not self.fueled then
        addButton(buttons, standardButtons.addWood)
    elseif not self.lit then
        addButton(buttons, standardButtons.lightFire)
    else
        addButton(buttons, standardButtons.cook)
    end


    if not self.supports then
        addButton(buttons, standardButtons.addSupports)
    end

    
    addButton(buttons, standardButtons.cancel)


    common.messageBox({ message = "Camp Fire", buttons = buttons })    
end

return Campfire