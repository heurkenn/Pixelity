-- src/data/boss.lua
-- Boss catalog used by boss rounds and the random boss order for each run.

local boss = {}

boss.types = {
    {
        id = "earthquake",
        name = "Earthquake",
        description = "La ville tremble, les assurances aussi : 5 cases aleatoires sont frappees a chaque BUILD.",
        effects = {
            { type = "destroy_random_cells_on_build", count = 5 }
        }
    },
    {
        id = "tsunami",
        name = "Tsunami",
        description = "Un peu d'eau, beaucoup de problemes : une ligne et une colonne sont detruites a chaque BUILD.",
        effects = {
            { type = "destroy_row_and_column_on_build" }
        }
    },
    {
        id = "lactose_dog",
        name = "Lactose Intelorant dog",
        description = "Il renifle tout le quartier : les Park valent maintenant -10 fixes.",
        effects = {
            { type = "fixed_building_value", source = "park", value = -10 }
        }
    },
    {
        id = "in_the_dark",
        name = "In the dark",
        description = "Quelqu'un a coupe le courant : les cartes en main restent cachees.",
        effects = {
            { type = "hide_hand_cards" }
        }
    },
    {
        id = "renovation",
        name = "Renovation",
        description = "Le chantier municipal a encore oublie de prevenir : 10 obstacles apparaissent au debut de la manche.",
        effects = {
            { type = "spawn_obstacles_on_round_start", count = 10 }
        }
    }
}

-- Recupere les donnees d'un boss a partir de son identifiant.
function boss.getData(id)
    for _, bossData in ipairs(boss.types) do
        if bossData.id == id then
            return bossData
        end
    end
    return nil
end

return boss
