local common = require ("mer.ashfall.common.common")
local foodConfig = common.staticConfigs.foodConfig
local hungerController = require("mer.ashfall.needs.hungerController")
local skillCookingGrillingIncrement = 10
local skillSurvivalGrillingIncrement = 4

-------------------------------------------------------
--COOKING----------------------------------------------
-------------------------------------------------------

----------------------------
--Grilling
-----------------------------


--How much fuel level affects grill cook speed
local function calculateCookMultiplier(fuelLevel)
    return 350 * math.min(math.remap(fuelLevel, 0, 10, 0.5, 1.5), 1.5)
end

--How much ingredient weight affects grill cook speed
local function calculateCookWeightModifier(ingredObject)
    return math.remap(ingredObject.weight, 1, 2, 1, 0.5)
end

--Checks if the ingredient has been placed on a campfire
local function findCampfireForCooking(ingredient, cookingType)
    local distance
    local minHeight
    local maxHeight
    if cookingType == "grilling" then
        minHeight = 21
        maxHeight = 50
        distance = 40
    elseif cookingType == "boiling" then
        minHeight = 50
        maxHeight = 500
        distance = 500
    else
        common.log:error("findCampfireForCooking: invalid cooking type")
        return
    end
    local campfire
    local function checkDistance(ref)
        --food sitting on grill
        local heightDistance = ingredient.position.z - ref.position.z
        if heightDistance < maxHeight and heightDistance > minHeight then
            
            local thisDistance = ingredient.position:distance(ref.position)
            if thisDistance < distance then
                distance = thisDistance
                campfire = ref
            end
        end
    end
    common.helper.iterateCampfires(checkDistance)
    return campfire
end

local function isStack(ingredient)
    return ( 
        ingredient.attachments.variables and 
        ingredient.attachments.variables.count > 1 
    )
end

local function resetCookingTime(ingredient)
    if not isStack(ingredient) and ingredient.data then 
        ingredient.data.lastCookUpdated = nil 
    end
end

local function startCookingIngredient(ingredient, timestamp)
    
    if isStack(ingredient) then
        local count = ingredient.attachments.variables.count
        mwscript.addItem{ reference = tes3.player, item = ingredient.object, count = (count - 1) }
        ingredient.attachments.variables.count = 1
    end
    timestamp = timestamp or tes3.getSimulationTimestamp()
    ingredient.data.lastCookUpdated = timestamp
    tes3.messageBox("%s begins to cook.", ingredient.object.name)
    tes3.playSound{ sound = "potion fail", pitch = 0.8, reference = ingredient }

    -- local smoke = tes3.loadMesh("ashfall\\cookingSmoke.nif"):clone()
    -- ingredient.sceneNode:attachChild(smoke, true)
    -- ingredient.sceneNode:update()
    -- ingredient.sceneNode:updateNodeEffects()
end



local function grillFoodItem(ingredient, timestamp)
    if ingredient.object.objectType == tes3.objectType.ingredient then
        local foodType = foodConfig.ingredTypes[ingredient.object.id]
        --Can only grill certain types of food
        if foodConfig.grillValues[foodType] then
            local campfire = findCampfireForCooking(ingredient, "grilling")
            if campfire then
                if campfire.data.hasGrill and campfire.data.isLit then
                    
                    if isStack(ingredient) or ingredient.data.lastCookUpdated == nil then 
                        startCookingIngredient(ingredient, timestamp) 
                        return
                    end

                    ingredient.data.lastCookUpdated = ingredient.data.lastCookUpdated or timestamp
                    ingredient.data.cookedAmount = ingredient.data.cookedAmount or 0

                    local difference = timestamp - ingredient.data.lastCookUpdated
                    if difference > 0.008 then
                        ingredient.data.lastCookUpdated = timestamp
                        local before = ingredient.data.cookedAmount

                        local thisCookMulti = calculateCookMultiplier(campfire.data.fuelLevel)
                        local weightMulti = calculateCookWeightModifier(ingredient.object)
                        ingredient.data.cookedAmount = ingredient.data.cookedAmount + ( difference * thisCookMulti * weightMulti)
                        local after = ingredient.data.cookedAmount

                        

                        --Only play sounds/messages if not transitioning from cell
                        if difference < 0.01 then
                            --Cooked your food
                            if before < 100 and after > 100 then
                                tes3.messageBox("%s is fully cooked.", ingredient.object.name)
                                tes3.playSound{ sound = "potion fail", pitch = 0.7, reference = ingredient }
                                common.skills.cooking:progressSkill(skillCookingGrillingIncrement)
                                common.skills.survival:progressSkill(skillSurvivalGrillingIncrement)
                            
                                --common.helper.addDecal(ingredient, "Textures\\Ashfall\\cooked_decal.dds")
                            end
                            --burned your food
                            local burnLevel = hungerController.getBurnLimit()
                            if before < burnLevel and after > burnLevel then
                                tes3.messageBox("%s has become burnt.", ingredient.object.name)
                                tes3.playSound{ sound = "potion fail", pitch = 0.9, reference = ingredient }

                               --common.helper.addDecal(ingredient, "Textures\\Ashfall\\burnt_decal.dds")
                                
                            end
                        end
                        local helpMenu = tes3ui.findHelpLayerMenu(tes3ui.registerID("HelpMenu"))
                        if helpMenu and helpMenu.visible == true then
                            tes3ui.refreshTooltip()
                        end
                    end
                else
                    --reset grill time if campfire is unlit
                    resetCookingTime(ingredient)
                end
            end
        end
    end
end


--update any food that is currently grilling
local function grillFoodSimulate(e)
    for _, cell in pairs( tes3.getActiveCells() ) do
        for ingredient in cell:iterateReferences(tes3.objectType.ingredient) do
            grillFoodItem(ingredient, e.timestamp)
        end
    end
end
event.register("simulate", grillFoodSimulate)



--Reset grill time when item is placed
local function ingredientPlaced(e)
    if e.reference and e.reference.object then
        local foodType = foodConfig.ingredTypes[e.reference.object.id]
        if foodConfig.grillValues[foodType] then
            local timestamp = tes3.getSimulationTimestamp()
            local ingredient = e.reference
                --Reset grill time for meat and veges
            timer.frame.delayOneFrame(function()
                resetCookingTime(ingredient, timestamp)
                grillFoodItem(ingredient, timestamp)
            end) 
        end
    end
end
event.register("referenceSceneNodeCreated" , ingredientPlaced)


--Update Stew buffs
--local  i = 0
local function updateBuffs(e)
    if common.data.stewBuffTimeLeft and common.data.stewBuffTimeLeft > 0 then

        common.data.lastStewBuffUpdated = common.data.lastStewBuffUpdated or e.timestamp

        local interval = e.timestamp - common.data.lastStewBuffUpdated
        common.data.stewBuffTimeLeft = math.max((common.data.stewBuffTimeLeft - interval), 0)
        --time's up, remove spells and heat
        if common.data.stewBuffTimeLeft == 0 then

            common.data.stewWarmEffect = 0 

            for _, stewBuff in pairs(foodConfig.stewBuffs) do
                mwscript.removeSpell({ reference = tes3.player, spell = stewBuff.id})
            end
            common.helper.restoreFatigue()
        end
    end
    common.data.lastStewBuffUpdated = e.timestamp
end
event.register("simulate", updateBuffs)