-- src/data/buildings.lua
-- Building catalog, prices, scoring metadata and sprite loading.

local buildings = {}

buildings.types = {
    {
        id = 1,
        key = "house",
        name = "House",
        base_score = 5,
        price = 3,
        rarity = "common",
        color = {0.2, 0.6, 1},
        sprite_path = "assets/house_sheets.png",
        effects = {
            { trigger = "scoring", type = "adjacent_bonus", target = "house", value = 5 },
            { trigger = "scoring", type = "adjacent_bonus", target = "park", value = 10 },
            { trigger = "scoring", type = "adjacent_bonus", target = "factory", value = -9 }
        }
    },
    {
        id = 2,
        key = "park",
        name = "Park",
        base_score = 15,
        price = 4,
        rarity = "common",
        color = {0.2, 0.8, 0.2},
        sprite_path = "assets/park_sheets.png",
        effects = {
            { trigger = "scoring", type = "adjacent_bonus", target = "house", value = 3 },
            { trigger = "scoring", type = "adjacent_bonus", target = "factory", value = -20 }
        }
    },
    {
        id = 3,
        key = "factory",
        name = "Factory",
        base_score = 50,
        price = 5,
        rarity = "uncommon",
        color = {0.8, 0.2, 0.2},
        sprite_path = "assets/factory_sheets.png",
        effects = {}
    },
    {
        id = 4,
        key = "bank",
        name = "Bank",
        base_score = 5,
        price = 6,
        rarity = "rare",
        color = {0.8, 0.8, 0.2},
        sprite_path = "assets/bank_sheets.png",
        effects = {
            { trigger = "round_reward", type = "money_reward", source = "bank", value = 1 }
        }
    },
    {
        id = 5,
        key = "tower",
        name = "Immeuble",
        base_score = 10,
        price = 5,
        rarity = "uncommon",
        color = {0.58, 0.58, 0.68},
        sprite_path = "assets/building_sheets.png",
        effects = {
            -- Stacking another Immeuble on top raises its level, doubling its final score.
            { trigger = "scoring", type = "stack_multiplier", source = "tower", multiplier = 2 }
        }
    },
    {
        id = 6,
        key = "casino",
        name = "Casino",
        base_score = 10,
        price = 8,
        rarity = "rare",
        color = {1.0, 0.60, 0.0},
        sprite_path = "assets/casino_sheets.png",
        effects = {
            {
                trigger = "on_build",
                type = "weighted_money",
                source = "casino",
                outcomes = {
                    { chance = 0.5, value = 2 },
                    { chance = 0.2, value = 5 },
                    { chance = 0.3, value = -1 }
                }
            }
        }
    },
    {
        id = 7,
        key = "townhall",
        name = "Mairie",
        base_score = 20,
        price = 12,
        rarity = "legendary",
        unique = true,
        color = {0.95, 0.9, 0.68},
        sprite_path = "assets/townhall_sheets.png",
        effects = {
            { trigger = "board_modifier", type = "mayor_effect_multiplier", multiplier = 2 },
            { trigger = "board_modifier", type = "law_effect_multiplier", multiplier = 1.5, fallback_bonus = 1 }
        }
    },
    {
        id = 8,
        key = "bourgeois_king",
        name = "Bourgeois Roi",
        base_score = 15,
        price = 6,
        rarity = "rare",
        color = {0.96, 0.79, 0.34},
        sprite_path = "assets/bourgeois_king_sheets.png",
        effects = {
            { trigger = "scoring", type = "adjacent_bonus", target = "mec_donatien", value = 8 },
            { trigger = "round_reward", type = "adjacent_money_reward", target = "mec_donatien", value = 1 }
        }
    },
    {
        id = 9,
        key = "mec_donatien",
        name = "MecDonatien",
        base_score = 10,
        price = 6,
        rarity = "uncommon",
        color = {0.42, 0.84, 0.92},
        sprite_path = "assets/mec_donatien_sheets.png",
        effects = {
            { trigger = "scoring", type = "adjacent_bonus", target = "bourgeois_king", value = 8 }
        }
    }
}

-- Recupere les donnees d'un batiment a partir de son identifiant.
function buildings.getData(id)
    for _, b in ipairs(buildings.types) do
        if b.id == id then
            return b
        end
    end
    return nil
end

-- Charge les sprites de batiments disponibles dans les assets.
function buildings.loadImages()
    for _, b in ipairs(buildings.types) do
        if love.filesystem.getInfo(b.sprite_path) then
            b.image = love.graphics.newImage(b.sprite_path)
            b.quads = {}
            for i = 0, 2 do
                b.quads[i + 1] = love.graphics.newQuad(i * 32, 0, 32, 32, b.image:getDimensions())
            end
        else
            print("Warning: Sprite non trouve pour " .. b.name)
        end
    end
end

return buildings
