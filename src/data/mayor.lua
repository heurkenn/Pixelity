-- src/data/mayor.lua
-- Mayor catalog, portraits and persistent run modifiers.

local mayor = {}

mayor.types = {
    {
        id = 1,
        name = "Newbie",
        description = "Aucun effet.",
        portrait = "assets/mayors/urbaniste.png",
        effects = {}
    },
    {
        id = 2,
        name = "Leaf Enjoyer",
        description = "Les parcs valent x2, mais 0 s'ils touchent un autre type de batiment.",
        portrait = "assets/mayors/clochard.png",
        effects = {
            { type = "park_isolation_rule", multiplier = 2 }
        }
    },
    {
        id = 3,
        name = "Sellout",
        description = "Les banques donnent x2 pieces, mais les objets coutent x2.",
        portrait = "assets/mayors/vendu.png",
        effects = {
            { type = "building_money_multiplier", source = "bank", multiplier = 2 },
            { type = "item_price_multiplier", value = 2 }
        }
    },
    {
        id = 4,
        name = "Minor",
        description = "50% de garder un explosif, 10% de perdre 1/4 de l'argent en l'utilisant.",
        portrait = "assets/mayors/mineur.png",
        effects = {
            { type = "explosive_preserve_chance", value = 0.5 },
            { type = "explosive_money_loss", chance = 0.1, fraction = 0.25 }
        }
    },
    {
        id = 5,
        name = "Urban Planner",
        description = "+5 pour House et Immeuble, mais 3 Park max sur la grille.",
        portrait = "assets/mayors/dictateur.png",
        effects = {
            { type = "flat_bonus_modifier", source = "house", value = 5 },
            { type = "flat_bonus_modifier", source = "tower", value = 5 },
            { type = "max_building_on_grid", source = "park", value = 3 }
        }
    },
    {
        id = 6,
        name = "Dictator",
        description = "7 lois max, doublons autorises, mais aucun objet.",
        portrait = "assets/mayors/dictateur.png",
        effects = {
            { type = "max_laws_modifier", value = 2 },
            { type = "allow_duplicate_laws" },
            { type = "set_max_items", value = 0 }
        }
    }
}

function mayor.getData(id)
    for _, m in ipairs(mayor.types) do
        if m.id == id then
            return m
        end
    end
    return nil
end

return mayor
