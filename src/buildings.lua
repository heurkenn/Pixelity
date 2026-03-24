-- src/buildings.lua

local buildings = {}

buildings.types = {
    {
        id = 1,
        name = "House",
        base_score = 10,
        price = 3,
        color = {0.2, 0.6, 1},
        sprite_path = "assets/house_sheets.png",
        effects = {
            { type = "adjacent_bonus", target = "house", value = 5 },
            { type = "adjacent_bonus", target = "park", value = 10 }
        }
    },
    {
        id = 2,
        name = "Park",
        base_score = 20,
        price = 4,
        color = {0.2, 0.8, 0.2},
        sprite_path = "assets/park_sheets.png",
        effects = {
            { type = "adjacent_bonus", target = "house", value = 3 }
        }
    },
    {
        id = 3,
        name = "Factory",
        base_score = 50,
        price = 5,
        color = {0.8, 0.2, 0.2},
        sprite_path = "assets/factory_sheets.png",
        effects = {}
    },
    {
        id = 4,
        name = "Bank",
        base_score = 15,
        price = 8,
        color = {0.8, 0.8, 0.2},
        sprite_path = "assets/bank_sheets.png",
        effects = {
            { type = "money_reward", source = "bank", value = 1 }
        }
    }
}

function buildings.getData(id)
    for _, b in ipairs(buildings.types) do
        if b.id == id then return b end
    end
    return nil
end

-- Load the GIF for a building 
function buildings.loadImages()
    for _, b in ipairs(buildings.types) do
        if love.filesystem.getInfo(b.sprite_path) then
            b.image = love.graphics.newImage(b.sprite_path)
            
            b.quads = {}
            for i = 0, 2 do
                b.quads[i+1] = love.graphics.newQuad(
                    i * 32, 0, 32, 32, 
                    b.image:getDimensions()
                )
            end
        else
            print("Warning: Sprite non trouvé pour " .. b.name)
        end
    end
end

return buildings
