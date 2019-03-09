local common = require ("mer.ashfall.common")
local activators = require("mer.ashfall.activators.activatorController")
local utensils = require("mer.ashfall.cooking.utensils")
local recipes = require("mer.ashfall.cooking.recipes")

local uids = {
    menu = tes3ui.registerID("Ashfall:Cooking_Menu"),
    recipeList = tes3ui.registerID("Ashfall:Recipe_List"),
    cookButton = tes3ui.registerID("Ashfall:Cook_Button"),
    imagePane = tes3ui.registerID("Ashfall:Result_Image_Container"),
}


local function createMenuContainer()
    mwse.log("Creating Cooking menu")
    local cookingMenu = tes3ui.createMenu{ id = uids.menu, fixedFrame = true }

    local fixedBlock = cookingMenu:createBlock()
    fixedBlock.flowDirection = "top_to_bottom"
    fixedBlock.width  = 550
    fixedBlock.height = 450
    fixedBlock.borderAllSides = 10

    local headerBlock = fixedBlock:createBlock()
    headerBlock.borderBottom = 20
    headerBlock.autoHeight = true
    headerBlock.widthProportional = 1.0
    local header = headerBlock:createLabel{ text = "Cooking Menu"}
    header.color = tes3ui.getPalette("header_color")
    header.absolutePosAlignX = 0.5



    return fixedBlock
end

local function createRecipeImage(imagePane, path)
    local image = imagePane:createImage({ path = path })
    image.height = 64
    image.width = 64
    image.scaleMode = true
end

local function updateResultsWindow(recipe)
    local menu = tes3ui.findMenu(uids.menu)
    local imagePane = menu:findChild(uids.imagePane)
    imagePane:destroyChildren()
    local newPath = ( "Icons/" .. tes3.getObject(recipe.id).icon)
    mwse.log("New path = %s", newPath)
    createRecipeImage(imagePane, newPath)
    menu:updateLayout()
end


local function recipeClick(clickedLabel, recipe)
    --Update recipe text color
    for _, label in ipairs(clickedLabel.parent.children) do
        label.color = tes3ui.getPalette("normal_color")
    end
    clickedLabel.color = tes3ui.getPalette("active_color")
    clickedLabel.parent:updateLayout()
    --play click sound manually because these aren't actually buttons
    mwse.log("Playing click sound now")
    tes3.playSound({ reference = tes3.player, sound = "Menu Click"})

    updateResultsWindow(recipe)
end

local function createRecipeItem(parent, recipe)
    recipeObject = tes3.getObject(recipe.id)
    local label = parent:createLabel({ text = recipeObject.name })
    
    label:register("mouseClick", function() recipeClick(label, recipe) end)
end

local function createRecipesBlock(parent)

    local recipesBlock = parent:createBlock()
    recipesBlock.flowDirection = "top_to_bottom"
    recipesBlock.heightProportional =  1.0
    recipesBlock.widthProportional =  0.75
    recipesBlock.borderRight = 10

    
    local header = recipesBlock:createLabel({text = "Recipes"})
    --header.absolutePosAlignX = 0.5
    header.color = tes3ui.getPalette("header_color")


    local recipesList = recipesBlock:createVerticalScrollPane()
    recipesList.layoutHeightFraction =  1.0
    recipesList.widthProportional =  1.0
    recipesList.paddingAllSides = 6    


    --[[local headerBlock = recipesList:createBlock()
    headerBlock.borderAllSides = 10
    headerBlock.autoHeight = true
    headerBlock.widthProportional =  1.0]]--




    for _, recipe in ipairs(recipes) do
        createRecipeItem(recipesList, recipe)
    end

    return recipesBlock
end

local function createResultsBlock(parent)

    local resultsBlock = parent:createBlock() 
    resultsBlock.flowDirection = "top_to_bottom"
    resultsBlock.heightProportional = 1.0
    resultsBlock.widthProportional = 1.25

    local header = resultsBlock:createLabel({text = "Result"})
    --header.absolutePosAlignX = 0.5
    header.color = tes3ui.getPalette("header_color")



    local topBlock = resultsBlock:createThinBorder()
    topBlock.autoHeight = true
    topBlock.widthProportional = 1.0 
    topBlock.paddingAllSides = 10

    local imagePane = topBlock:createThinBorder({id = uids.imagePane})
    imagePane.autoHeight = true
    imagePane.autoWidth = true
    imagePane.borderRight = 10
    imagePane.paddingAllSides = 5

    createRecipeImage(imagePane, "Icons/ashfall/food/empty.dds")

    local descriptionPane = topBlock:createBlock()
    descriptionPane.heightProportional = 1.0
    descriptionPane.widthProportional = 1.0
    local descriptionLabel = descriptionPane:createLabel({ text = "Meal Name goes here"})
    descriptionLabel.absolutePosAlignY = 0.5


    local ingredientsList = resultsBlock:createThinBorder()
    ingredientsList.heightProportional = 1.0
    ingredientsList.widthProportional = 1.0   


    return resultsBlock
end

local function createButtonBlock(parent)
    local block = parent:createBlock()
    block.flowDirection = "left_to_right"
    block.widthProportional = 1.0
    block.autoHeight = true
    block.childAlignX = 1.0
    block.borderTop = 5

    local cancelButton = block:createButton({ text = "Cancel"})
    cancelButton:register(
        "mouseClick", 
        function ()
            tes3ui.findMenu(uids.menu):destroy()
            tes3ui.leaveMenuMode()
        end
    )

    local cookButton = block:createButton({ id = uids.cookButton, text = "Cook"})

end


local function createCookingMenu()

    local menuContainer = createMenuContainer()

    local mainBorder = menuContainer:createBlock()
    mainBorder.heightProportional = 1.0
    mainBorder.widthProportional = 1.0

    local recipesBlock = createRecipesBlock(mainBorder)
    local resultsBlock = createResultsBlock(mainBorder)

    local buttonBlock = createButtonBlock(menuContainer)


    tes3ui.enterMenuMode(uids.menu)
end

local function onActivate(e)
    local inputController = tes3.worldController.inputController
    local pressedActivateKey = inputController:keybindTest(tes3.keybind.activate)
    local hungerActive = (
        common.data and
        common.data.mcmSettings.enableHunger
    )
    local lookingAtUtensil = ( 
        activators.currentActivator and
        activators.currentActivator.type == activators.activatorTypes.cookingUtensil
    )
    if ( pressedActivateKey and hungerActive and lookingAtUtensil ) then
        createCookingMenu()
    end
end

event.register("keyDown", onActivate )