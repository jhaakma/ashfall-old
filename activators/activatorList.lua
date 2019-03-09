local this = {}

this.types = {
    waterSource = "waterSource",
    cookingUtensil = "cookingUtensil",
    woodSource = "woodSource",
}

this.list = {
    water = { 
        name = "Water", 
        type = this.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "ex_vivec_waterfall_01",
            "Ex_Vivec_waterfall_03",
            "Ex_Vivec_waterfall_05",
            "In_OM_waterfall",
            "In_OM_waterfall_small",
        }
    },
    well = { 
        name = "Well", 
        type = this.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "ex_nord_well",
        }
    },
    keg = { 
        name = "Keg", 
        type = this.types.waterSource,
        mcmSetting = "enableThirst",
        ids = {
            "kegstand",
        }
    },
    tree = { 
        name = "Tree",
        type = this.types.woodSource,
        mcmSetting = "enableTemerpatureEffects",
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
    wood = { 
        name = "Wood",
        type = this.types.woodSource,
        mcmSetting = "enableTemerpatureEffects",
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
    fire = { 
        name = "Fire", 
        --type = this.types.cookingUtensil,
        mcmSetting = "enableHunger",
        ids = {
            "firepit_f",
            "firepit_lit",
            "firepit_roaring",
            "light_pitfire",
            "light_logpile"
        }
    },
    --[[cookingPot = { 
        name = "Cooking Pot", 
        type = this.types.cookingUtensil,
        mcmSetting = "enableHunger",
        ids = {
            "furn_com_cauldron",
        }
    },]]--
}

return this