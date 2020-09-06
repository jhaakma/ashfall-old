local this = {}

this.teaTypes = {
    ["ingred_bittergreen_petals_01"] = {
        teaName = "Bittergreen Tea",
        teaDescription = "The overbearing aroma of Bittergreen tea helps to cleanse the mind of distracting thoughts.",
        effectDescription = "Fortify Magicka 15 points",
        duration = 3,
        spell = {
            id = "ashfall_tea_bittergreen",
            effects = {
                {
                    id = tes3.effect.fortifyMagicka,
                    amount = 15
                }
            }
        }
    },
    
    ["ingred_black_anther_01"] = { 
        teaName = "Black Anther Tea",
        teaDescription = "A popular drink among socialites and those who wish to stand out, Black Anther tea gives the skin a healthy, radiant glow.",
        effectDescription = "Light 5 points on Self",
        duration = 2,
        spell = {
            id = "ashfall_tea_anther",
            effects = {
                {
                    id = tes3.effect.light,
                    amount = 5
                }
            }
        }
    },
    
    ["ingred_chokeweed_01"] = { 
        teaName = "Chokeweed Tea",
        teaDescription = "Drinking Chokeweed tea helps to boost your immune system. Like any good medicine, it taste absolutely terrible.",
        effectDescription = "Resist Common Disease 30 points",
        duration = 4,
        spell = {
            id = "ashfall_tea_chokeweed",
            effects = {
                {
                    id = tes3.effect.resistCommonDisease,
                    amount = 30
                }
            }
        }
    },


    -- Interestingly, the propery of fire petals is resist fire
    ["ingred_gold_kanet_01"] = { 
        teaName = "Gold Kanet Tea",
        teaDescription = "Tea brewed from the Gold Kanet flower is known to enhance one's strength.",
        effectDescription = "Fortify Strength 5 points",
        duration = 3,
        spell = {
            id = "ashfall_tea_goldKanet",
            effects = {
                {
                    id = tes3.effect.fortifyAttribute,
                    attribute = tes3.attribute.strength,
                    amount = 5
                }
            }
        }
    },
    
    ["Ingred_golden_sedge_01"] = {
        teaName = "Golden Sage Tea",
        teaDescription = "A favourite among fighters, Golden Sage tea increases attack power.",
        effectDescription = "Fortify Attack Power 5 points",
        duration = 3,
        spell = {
            id = "ashfall_tea_goldSedge",
            effects = {
                {
                    id = tes3.effect.fortifyAttack,
                    amount = 5
                }
            }
        }
    },

    
    ["ingred_heather_01"] = {
        teaName = "Heather Tea",
        teaDescription = "Heather tea is a relaxing beverage that helps take the weight off your shoulders.",
        effectDescription = "Feather 10 points",
        duration = 4,
        spell = {
            id = "ashfall_tea_heather",
            effects = {
                {
                    id = tes3.effect.feather,
                    amount = 10
                }
            }
        }
    },
    


    ["Ingred_meadow_rye_01"] = { 
        teaName = "Meadow Rye Tea",
        teaDescription = "Tea brewed from Meadow Rye acts as a powerful stimulant, increasing one's speed.",
        effectDescription = "Fortify Speed 5 points",
        duration = 4,
        spell = {
            id = "ashfall_tea_meadowRye",
            effects = {
                {
                    id = tes3.effect.fortifyAttribute,
                    attribute = tes3.attribute.speed,
                    amount = 5
                }
            }
        }
    },

    ["Ingred_noble_sedge_01"] = {
        teaName = "Noble Sedge Tea",
        teaDescription = "A rare beverage, prized among Acrobats, the Noble Sledge tea improves one's Agility.",
        effectDescription = "Fortify Agility 10 points",
        duration = 4,
        spell = {
            id = "ashfall_tea_nobleSedge",
            effects = {
                {
                    id = tes3.effect.fortifyAttribute,
                    attribute = tes3.attribute.agility,
                    amount = 10
                }
            }
        }
    },
    
    ["ingred_stoneflower_petals_01"] = { 
        teaName = "Stoneflower Tea",
        teaDescription = "The pleasant, floral aroma of Stoneflower tea lingers on the breath longer after it is consumed.",
        effectDescription = "Fortify Speechcraft 10 points",
        duration = 3,
        spell = {
            id = "ashfall_tea_stoneflower",
            effects = {
                {
                    id = tes3.effect.fortifySkill,
                    skill = tes3.skill.speechcraft,
                    amount = 10
                }
            }
        }
    },
    
    ["Ingred_timsa-come-by_01"] = {
        teaName = "Timsa-come-by Tea",
        teaDescription = "Tea brewed from this rare plant makes one highly resistant to paralysis.",
        effectDescription = "Resist Paralysis 40 points",
        duration = 4,
        spell = {
            id = "ashfall_tea_timsa",
            effects = {
                {
                    id = tes3.effect.resistParalysis,
                    amount = 40
                }
            }
        }
    },
    
    ["ingred_belladonna_01"] = {
        teaName = "Belladonna Tea",
        teaDescription = "Belladonna berries make for a slighty bitter tea that provides a mild resistance against magicka.",
        effectDescription = "Resist Magicka 10 points",
        duration = 4,
        spell = {
            id = "ashfall_tea_bella",
            effects = {
                {
                    id = tes3.effect.resistMagicka,
                    amount = 10
                }
            }
        }
    },
    
    ["ingred_belladonna_02"] = {
        teaName = "Belladonna Tea",
        teaDescription = "Belladonna berries make for a slighty bitter tea that provides a mild resistance against magicka. Unripened berries have a slightly weaker effect.",
        effectDescription = "Resist Magicka 5 points",
        duration = 3,
        spell = {
            id = "ashfall_tea_bella",
            effects = {
                {
                    id = tes3.effect.resistMagicka,
                    amount = 5
                }
            }
        }
    },
    
    ["ingred_bc_coda_flower"] = {
        teaName = "Coda Flower Tea",
        teaDescription = "Tea made from the coda flower has a mild psychotropic effect that allows one to sense nearby lifeforms.",
        effectDescription = "Detect Animal 20 points",
        duration = 3,
        spell = {
            id = "ashfall_tea_coda",
            effects = {
                {
                    id = tes3.effect.detectAnimal,
                    amount = 20
                }
            }
        }
    },

    
    ["ingred_hackle-lo_leaf_01"] = {
        teaName = "Hackle-lo Tea",
        teaDescription = "Hackle-lo tea increases energy and alertness, allowing one to stay awake for longer.",
        effectDescription = "Tiredness drain reduced by 25%",
        duration = 5,
        onCallback = function()
            tes3.player.data.Ashfall.hackloTeaEffect = 0.75
        end,
        offCallback = function()
            tes3.player.data.Ashfall.hackloTeaEffect = nil
        end
    },

    ["ingred_kresh_fiber_01"] = {
        teaName = "Kreshweed Tea",
        teaDescription = "Kreshweed tea is a powerful laxative, making it an effective cure for food poisoning.",
        effectDescription = "Cures food poisoning",
        onCallback = function()
            tes3.player.data.Ashfall.foodPoison = 50
        end
    },

    ["ingred_trama_root_01"] = {
        teaName = "Trama Root Tea",
        teaDescription = "Trama Root tea is dark and bitter. The Ashlanders drink this tea for its calming effects.",
        effectDescription = "1.5x sleep recovery",
        duration = 8,
        onCallback = function()
            tes3.player.data.Ashfall.tramaRootTeaEffect = 1.5
        end,
        offCallback = function()
            tes3.player.data.Ashfall.tramaRootTeaEffect = nil
        end
    },

    ["ingred_roobrush_01"] = {
        teaName = "Roobrush Tea",
        teaDescription = "Roobrush tea has a smooth, slightly nutty flavor, and is used as a cure for dysentery.",
        effectDescription = "Cures Dysentery",
        onCallback = function()
            tes3.player.data.Ashfall.dysentery = 50
        end
    },

        
    ["ingred_comberry_01"] = { 
        teaName = "Comberry Tea",
        teaDescription = "A tea brewed from comberries is a well known home remedy for the flu.",
        effectDescription = "Cures the Flu",
        onCallback = function()
            tes3.player.data.Ashfall.flu = 50
        end,
    },
    
    ["ingred_fire_petal_01"] = {
        teaName = "Fire Petal Tea",
        teaDescription = "Fire Petal tea is a spicy beverage that helps keep one warm on cold nights.",
        effectDescription = "Reduce cold weather effects by 20%",
        duration = 4,
        onCallback = function()
            tes3.player.data.Ashfall.firePetalTeaEffect = 0.80
        end,
        offCallback = function()
            tes3.player.data.Ashfall.firePetalTeaEffect = nil
        end,
    },

    ["ingred_holly_01"] = { 
        teaName = "Holly Tea",
        teaDescription = "A sweet, fragrant tea often served in Solstheim for its ability to stave off the cold.",
        effectDescription = "Reduce cold weather effects by 10%",
        duration = 4,
        onCallback = function()
            tes3.player.data.Ashfall.hollyTeaEffect = 0.9
        end,
        offCallback = function()
            tes3.player.Ashfall.data.hollyTeaEffect = nil
        end,
    },

}
return this