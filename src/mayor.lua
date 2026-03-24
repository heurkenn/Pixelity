-- src/mayor.lua

local mayor = {}

mayor.types = {
    {
        id = 1,
        name = "Urbaniste",
        description = "+5 fixe par maison.",
        portrait = "assets/mayors/urbaniste.png",
        effects = {
            { type = "flat_bonus_modifier", source = "house", value = 5 }
        }
    },
    {
        id = 2,
        name = "Clochard",
        description = "+10 par groupe de 3 cases vide ou Park.",
        portrait = "assets/mayors/clochard.png",
        effects = {
            { type = "empty_or_park_group_bonus", group_size = 3, value = 10 }
        }
    },
    {
        id = 3,
        name = "Vendu",
        description = "Double les pieces gagnees par les banques.",
        portrait = "assets/mayors/vendu.png",
        effects = {
            { type = "building_money_multiplier", source = "bank", multiplier = 2 }
        }
    },
    {
        id = 4,
        name = "Mineur",
        description = "1 chance sur 2 de conserver un explosif utilise.",
        portrait = "assets/mayors/mineur.png",
        effects = {
            { type = "explosive_preserve_chance", value = 0.5 }
        }
    },
    {
        id = 5,
        name = "Dictateur",
        description = "Passe a 7 lois max et autorise les doublons.",
        portrait = "assets/mayors/dictateur.png",
        effects = {
            { type = "max_laws_modifier", value = 2 },
            { type = "allow_duplicate_laws" }
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
