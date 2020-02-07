local Activator = require("mer.ashfall.objects.Activator")
local this = {}

this.types = {
    waterSource = "waterSource",
    dirtyWaterSource = "dirtyWaterSource",
    cookingUtensil = "cookingUtensil",
    fire = "fire",
    campfire = "campfire",
    woodSource = "woodSource",
    branch = "branch"
}

this.list = {
    water = Activator:new{ 
        name = "Water (Dirty)", 
        type = this.types.dirtyWaterSource,
        mcmSetting = "enableThirst",
        ids = {
            "ex_vivec_waterfall_01",
            "ex_vivec_waterfall_03",
            "ex_vivec_waterfall_05",
            "in_om_waterfall",
            "in_om_waterfall_small",
        }
    },
    well = Activator:new{ 
        name = "Well", 
        type = this.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "ex_nord_well",
            "furn_well00",
            "rm_well"
        }
    },
    keg = Activator:new{ 
        name = "Keg", 
        type = this.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "kegstand",
        }
    },
    tree = Activator:new{ 
        name = "Tree",
        type = this.types.woodSource,
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
        type = this.types.woodSource,
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
        type = this.types.fire,
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
        type = this.types.campfire,
        mcmSetting = nil,
        ids = {
           "ashfall_campfire",
        }
    },

    cookingPot = Activator:new{ 
        name = "Cooking Pot", 
        type = this.types.cookingUtensil,
        mcmSetting = "enableCooking",
        ids = {
            "furn_com_cauldron",
        }
    },

    branch = Activator:new{
        name = "Branch",
        type = this.types.branch,
        mcmSetting = nil,
        ids = {
            "ashfall_branch"
        }
    }
}
return this