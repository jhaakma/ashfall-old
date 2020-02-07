local this = {}

this.teaTypes = {
    ["ingred_bittergreen_petals_01"] = { 
        teaDescription = "The overbearing aroma of Bittergreen tea helps to cleanse the mind of distracting thoughts.",
        effectDescription = "Fortify Magicka 15 points"
    },
    ["ingred_black_anther_01"] = { 
        teaDescription = "A popular drink among socialites and those who wish to stand out, Black Anther tea gives the skin a healthy, radiant glow.",
        effectDescription = "Light 3 points on Self"
    },
    ["ingred_chokeweed_01"] = { 
        teaDescription = "Drinking Chokeweed tea helps boost your immune system. Like any good medicine, it taste absolutely terrible.",
        effectDescription = "Resist Common Disease 25 points"
    },
    ["ingred_comberry_01"] = { 
        teaDescription = "Witchhunters and Crusaders are known to drink this tea before battle to help fend off magical attacks.",
        effectDescription = "Reflect 5 points"
    },
    ["ingred_fire_petal_01"] = {
        teaDescription = "Fire Petal tea is a spicy beverage that helps keep one warm on cold nights.",
        effectDescription = "Reduce cold weather effects by 15%"
    },
    -- Interestingly, the propery of fire petals is resist fire
    ["ingred_gold_kanet_01"] = { 
        teaDescription = "Gold Kanet tea is usually served to fortify one's strength.",
        effectDescription = "Fortify Strength 5 points"
    },
    ["Ingred_golden_sedge_01"] = { 
        teaDescription = "A favourite among fighters, Golden Sage tea increases attack power.",
        effectDescription = ""
    },
    ["ingred_hackle-lo_leaf_01"] = { 
        teaDescription = "Hackle-lo tea increases energy and alertness, allowing one to stay awake for longer.",
        effectDescription = ""
    },
    ["ingred_heather_01"] = { 
        teaDescription = "Heather tea is a relaxing beverage that makes the weight on your shoulders feel a litte lighter.",
        effectDescription = "Feather 10 points"
    },
    ["ingred_holly_01"] = { 
        teaDescription = "A sweet, fragrant tea often served in Solstheim for its ability to stave off the cold.",
        effectDescription = "Reduce cold weather effects by 10%"
    },
    ["ingred_kresh_fiber_01"] = { 
        teaDescription = "Ashlanders believe that drinking tea brewed from Kresh Fiber brings good fortune.",
        effectDescription = "Fortify Luck 5 points."
    },
    ["Ingred_meadow_rye_01"] = { 
        teaDescription = "Drinking this tea causes the mind to buzz and the limbs to fidget about.",
        effectDescription = "Fortify Speed 5 points"
    },
    ["Ingred_noble_sedge_01"] = { 
        teaDescription = "A rare beverage, prized among Acrobats, the Noble Sledge tea improves one's Agility.",
        effectDescription = "Fortify Agility 10 points"
    },
    ["ingred_roobrush_01"] = { 
        teaDescription = "Roobrush tea has a smooth, slightly nutty flavor. Drinking it helps steady the hands, allowing for more precise movements.",
        effectDescription = "Fortify Agility 5 points"
    },

    ["ingred_bc_coda_flower"] = {
        teaDescription = "Tea made from the coda flower produces a mild psychotropic effect: a feeling of transcendanc ",
        effectDescription = "Detect Animal 20 points"
    },
    
    -- has no beneficial effect apart fron detect key.
    ["ingred_stoneflower_petals_01"] = { 
        teaDescription = "The pleasant, floral aroma of Stoneflower tea lingers on the breath longer after it is consumed.",
        effectDescription = "Fortify Speechcraft 10 points"
    },
    ["Ingred_timsa-come-by_01"] = { 
        teaDescription = "Tea brewed from this rare plant makes one highly resistant to paralysis.",
        effectDescription = "Resis Paralysis 40 points"
    },
    ["ingred_belladonna_01"] = { 
        teaDescription = "Belladonna berries make for a slighty bitter tea that provides a mild resistance against magicka.",
        effectDescription = "Resist Magicka 10 points"
    },
    ["ingred_belladonna_02"] = { 
        teaDescription = "Belladonna berries make for a slighty bitter tea that provides a mild resistance against magicka.",
        effectDescription = "Resist Magicka 10 points"
    },
}
return this