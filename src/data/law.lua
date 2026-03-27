-- src/data/law.lua
-- Law catalog and passive scoring effects.

local law = {}

law.types = {
    {
        id = "growing_street",
        name = "Rue grandissante",
        price = 3,
        rarity = "common",
        description = "Les voisins commencent a se saluer : +10 par segment de 3 maisons.",
        effects = {
            { type = "aligned_houses", segment_size = 3, bonus = 10 }
        }
    },
    {
        id = "success_avenue",
        name = "Avenue de la reussite",
        price = 4,
        rarity = "uncommon",
        description = "Quand une rue marche, tout le monde veut son commerce : +15 par segment de 4 maisons.",
        effects = {
            { type = "aligned_houses", segment_size = 4, bonus = 15 }
        }
    },
    {
        id = "wealth_boulevard",
        name = "Boulevard de la richesse",
        price = 5,
        rarity = "rare",
        description = "Les impots montent aussi vite que la skyline : +75 par segment de 5 maisons.",
        effects = {
            { type = "aligned_houses", segment_size = 5, bonus = 70 }
        }
    },
    {
        id = "worksite_expansion",
        name = "Extension de chantier",
        price = 5,
        rarity = "uncommon",
        description = "Le voisinage adore les marteaux-piqueurs : +2 poses avant BUILD.",
        effects = {
            { type = "extra_pending_placements", value = 2 }
        }
    },
    {
        id = "en_bas_du_bloc",
        name = "En bas du bloc",
        price = 4,
        rarity = "common",
        description = "Le maire fait profiter les p'tit commerce... : +1 par paire adjacente a chaque BUILD.",
        effects = {
            { type = "adjacent_towers_bonus", bonus = 1 }
        }
    }
}

-- Recupere les donnees d'une loi a partir de son identifiant.
function law.getData(id)
    for _, item in ipairs(law.types) do
        if item.id == id then
            return item
        end
    end
    return nil
end

return law
