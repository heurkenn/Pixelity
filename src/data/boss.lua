-- src/data/boss.lua
-- Boss catalog used by boss rounds and the random boss order for each run.

local boss = {}

boss.types = {
    {
        id = "earthquake",
        name = "Earthquake",
        description = "An earthquake destroy 5 randoms cells each turn.",
        effects = {
            { type = "destroy_random_cells_on_build", count = 5 }
        }
    },
    {
        id = "tsunami",
        name = "Tsunami",
        description = "One row and one column a destroy each turn.",
        effects = {
            { type = "destroy_row_and_column_on_build" }
        }
    },
    {
        id = "lactose_dog",
        name = "Lactose Intelorant dog",
        description = "Park value are now -15 fixed.",
        effects = {
            { type = "fixed_building_value", source = "park", value = -15 }
        }
    },
    {
        id = "in_the_dark",
        name = "In the dark",
        description = "The buildings on the card are hidden.",
        effects = {
            { type = "hide_hand_cards" }
        }
    },
    {
        id = "renovation",
        name = "Renovation",
        description = "15 obstacle spawn at the beginning of the round.",
        effects = {
            { type = "spawn_obstacles_on_round_start", count = 15 }
        }
    }
}

function boss.getData(id)
    for _, bossData in ipairs(boss.types) do
        if bossData.id == id then
            return bossData
        end
    end
    return nil
end

return boss
