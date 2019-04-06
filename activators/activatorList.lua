local Activator = require("mer.ashfall.objects.Activator")
local this = {}

this.list = {
    water = Activator:new{ 
        name = "Water", 
        type = Activator.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "ex_vivec_waterfall_01",
            "Ex_Vivec_waterfall_03",
            "Ex_Vivec_waterfall_05",
            "In_OM_waterfall",
            "In_OM_waterfall_small",
        }
    },
    well = Activator:new{ 
        name = "Well", 
        type = Activator.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "ex_nord_well",
        }
    },
    keg = Activator:new{ 
        name = "Keg", 
        type = Activator.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "kegstand",
        }
    },
    tree = Activator:new{ 
        name = "Tree",
        type = Activator.types.woodSource,
        mcmSetting = "enableTemperatureEffects",
        ids = {
            "flora_ash_log",
            "flora_ashtree",
            "flora_bc_knee",
            "flora_bc_log",
            "flora_bc_tree",
            "flora_bm_log",
            "flora_bm_snow_log",
            "flora_bm_snowstump",
            "flora_bm_treestump",
            "flora_emp_parasol",
            "flora_root_wg",
            "flora_tree",
            "vurt_baobab",
            "vurt_bctree",
            "vurt_bentpalm",
            "vurt_decstree",
            "vurt_neentree",
            "vurt_palm",
            "vurt_unicy",
        }
    },
    wood = Activator:new{ 
        name = "Wood",
        type = Activator.types.woodSource,
        mcmSetting = "enableTemperatureEffects",
        ids = {
            "flora_ashtree",
            "flora_ash_log",
            "flora_bc_knee",
            "flora_bc_log",
            "flora_bc_tree",
            "flora_bm_log",
            "flora_bm_snow_log",
            "flora_bm_snowstump",
            "flora_bm_treestump",
            "flora_emp_parasol",
            "flora_root_wg",
            "flora_tree",
            "vurt_baobab",
            "vurt_bctree",
            "vurt_bentpalm",
            "vurt_decstree",
            "vurt_neentree",
            "vurt_palm",
            "vurt_unicy",
        }
    },
    fire = Activator:new{ 
        name = "Fire", 
        type = Activator.types.fire,
        mcmSetting = "enableCooking",
        ids = {
            "firepit_f",
            "firepit_lit",
            "firepit_roaring",
            "light_pitfire",
            "light_logpile"
        }
    },
    campfire = Activator:new{
        name = "Campfire", 
        type = Activator.types.campfire,
        mcmSetting = "enableCooking",
        ids = {
            "ashfall_campfire",   
        }
    },
    cookingPot = Activator:new{ 
        name = "Cooking Pot", 
        type = Activator.types.cookingUtensil,
        mcmSetting = "enableCooking",
        ids = {
            "furn_com_cauldron",
        }
    },
}
return this