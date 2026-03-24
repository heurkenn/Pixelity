-- src/law.lua

local law = {}

law.types = {
    {
        id = "growing_street",
        name = "Rue grandissante",
        price = 4,
        description = "+10 par segment de 3 maisons",
        effects = {
            { type = "aligned_houses", segment_size = 3, bonus = 10 }
        }
    },
    {
        id = "success_avenue",
        name = "Avenue de la reussite",
        price = 4,
        description = "+15 par segment de 4 maisons",
        effects = {
            { type = "aligned_houses", segment_size = 4, bonus = 15 }
        }
    },
    {
        id = "wealth_boulevard",
        name = "Boulevard de la richesse",
        price = 4,
        description = "+25 par segment de 5 maisons",
        effects = {
            { type = "aligned_houses", segment_size = 5, bonus = 25 }
        }
    }
}

function law.getData(id)
    for _, item in ipairs(law.types) do
        if item.id == id then
            return item
        end
    end
    return nil
end

return law
