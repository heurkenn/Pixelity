-- src/data/object.lua
-- Object catalog and consumable gameplay effects.

local object = {}

object.types = {
    {
        id = "explosive",
        name = "EXPLOSIF",
        price = 2,
        description = "Retire 1 obstacle et donne 1 a 3 pieces",
        effects = {
            { type = "remove_obstacle", reward_min = 1, reward_max = 3 }
        }
    }
}

-- Recupere les donnees d'un objet a partir de son identifiant.
function object.getData(id)
    for _, item in ipairs(object.types) do
        if item.id == id then
            return item
        end
    end
    return nil
end

return object
