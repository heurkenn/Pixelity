-- src/shop.lua
-- Shop data shaping, offer layout, buy/sell logic and mayor-aware prices.

local buildings = require("src.data.buildings")
local law = require("src.data.law")
local object = require("src.data.object")
local layout = require("src.layout")

local shop = {}
local BUILDING_RARITY_WEIGHTS = {
    common = 6,
    uncommon = 3,
    rare = 1
}
local LAW_RARITY_WEIGHTS = {
    common = 6,
    uncommon = 3,
    rare = 1
}

-- Copie superficiellement une table de donnees pour l'adapter au rendu UI.
local function cloneTable(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

-- Construit une entree de shop avec ses coordonnees cliquables.
local function buildButton(item, section, x, y, w, h)
    local button = cloneTable(item)
    button.section = section
    button.x = x
    button.y = y
    button.w = w
    button.h = h
    return button
end

-- Verifie si une valeur est deja presente dans une liste.
local function hasValue(list, value)
    for _, item in ipairs(list or {}) do
        if item == value then
            return true
        end
    end
    return false
end

-- Tire un sous-ensemble aleatoire d'identifiants sans doublon.
local function takeRandomIds(sourceIds, amount, excludedIds)
    local pool = {}
    local picked = {}

    for _, id in ipairs(sourceIds or {}) do
        if not hasValue(excludedIds, id) then
            table.insert(pool, id)
        end
    end

    while #picked < math.min(amount, #pool) do
        local pickIndex = love.math.random(1, #pool)
        table.insert(picked, table.remove(pool, pickIndex))
    end

    return picked
end

-- Tire des batiments sans doublon avec une probabilite dependante de leur rarete.
local function takeWeightedBuildingIds(sourceIds, amount, excludedIds)
    local pool = {}
    local picked = {}

    for _, id in ipairs(sourceIds or {}) do
        if not hasValue(excludedIds, id) then
            local buildingData = buildings.getData(id)
            table.insert(pool, {
                id = id,
                weight = BUILDING_RARITY_WEIGHTS[buildingData and buildingData.rarity or "common"] or 1
            })
        end
    end

    while #picked < math.min(amount, #pool) do
        local totalWeight = 0
        for _, entry in ipairs(pool) do
            totalWeight = totalWeight + entry.weight
        end

        local roll = love.math.random() * totalWeight
        local cursor = 0
        local selectedIndex = 1
        for index, entry in ipairs(pool) do
            cursor = cursor + entry.weight
            if roll <= cursor then
                selectedIndex = index
                break
            end
        end

        table.insert(picked, table.remove(pool, selectedIndex).id)
    end

    return picked
end

-- Tire des lois sans doublon avec une probabilite dependante de leur rarete.
local function takeWeightedLawIds(sourceIds, amount, excludedIds)
    local pool = {}
    local picked = {}

    for _, id in ipairs(sourceIds or {}) do
        if not hasValue(excludedIds, id) then
            local lawData = law.getData(id)
            table.insert(pool, {
                id = id,
                weight = LAW_RARITY_WEIGHTS[lawData and lawData.rarity or "common"] or 1
            })
        end
    end

    while #picked < math.min(amount, #pool) do
        local totalWeight = 0
        for _, entry in ipairs(pool) do
            totalWeight = totalWeight + entry.weight
        end

        local roll = love.math.random() * totalWeight
        local cursor = 0
        local selectedIndex = 1
        for index, entry in ipairs(pool) do
            cursor = cursor + entry.weight
            if roll <= cursor then
                selectedIndex = index
                break
            end
        end

        table.insert(picked, table.remove(pool, selectedIndex).id)
    end

    return picked
end

-- Calcule le prix reel d'un objet selon les modificateurs du maire.
local function getItemPrice(player, itemData)
    -- Some mayors alter only shop object prices, not the base object data itself.
    local multiplier = player and player.object_price_multiplier or 1
    return math.floor((itemData.price or 0) * multiplier)
end

-- Indique si une offre a ete retiree du shop courant.
local function isHidden(game, section, id)
    return game.shop_hidden_entries and game.shop_hidden_entries[section .. ":" .. tostring(id)] == true
end

-- Liste les lois encore autorisees pour le joueur et ce shop.
local function collectAvailableLawIds(game, player)
    local ids = {}
    for _, lawData in ipairs(law.types) do
        local copyCount = player and player.countLawCopies(lawData.id) or 0
        local canAppear = copyCount == 0 or (player.allow_duplicate_laws and copyCount < 2)
        if canAppear and not isHidden(game, "law", lawData.id) then
            table.insert(ids, lawData.id)
        end
    end
    return ids
end

-- Liste les batiments encore disponibles dans l'offre courante.
local function collectAvailableBuildingIds(game)
    local ids = {}
    for _, building in ipairs(buildings.types) do
        if not isHidden(game, "building", building.id) then
            table.insert(ids, building.id)
        end
    end
    return ids
end

-- Liste les objets encore disponibles selon le stock et les limites du joueur.
local function collectAvailableItemIds(game, player)
    local ids = {}
    if player.MAX_ITEMS <= 0 then
        return ids
    end
    for _, item in ipairs(object.types) do
        if not isHidden(game, "item", item.id) then
            table.insert(ids, item.id)
        end
    end
    return ids
end

-- Retourne le prix a afficher pour une entree du shop.
function shop.getDisplayPrice(player, entry)
    if entry.section == "item" then
        return getItemPrice(player, entry)
    end
    return entry.price
end

-- Marque une offre comme retiree du shop courant.
function shop.hideEntry(game, section, id)
    game.shop_hidden_entries = game.shop_hidden_entries or {}
    game.shop_hidden_entries[section .. ":" .. tostring(id)] = true
end

-- Genere un nouveau lot complet d'offres aleatoires pour le shop.
function shop.rollOffers(game, player)
    game.shop_offers = {
        laws = takeWeightedLawIds(collectAvailableLawIds(game, player), 3),
        buildings = takeWeightedBuildingIds(collectAvailableBuildingIds(game), 2),
        items = takeRandomIds(collectAvailableItemIds(game, player), 2)
    }
end

-- Nettoie et complete les offres actuelles pour garder un shop coherent.
function shop.prepareOffers(game, player)
    game.shop_offers = game.shop_offers or {
        laws = {},
        buildings = {},
        items = {}
    }

    local filteredLaws = {}
    for _, lawId in ipairs(game.shop_offers.laws or {}) do
        if not isHidden(game, "law", lawId) and hasValue(collectAvailableLawIds(game, player), lawId) then
            table.insert(filteredLaws, lawId)
        end
    end

    local filteredBuildings = {}
    for _, buildingId in ipairs(game.shop_offers.buildings or {}) do
        if not isHidden(game, "building", buildingId) then
            table.insert(filteredBuildings, buildingId)
        end
    end

    local filteredItems = {}
    for _, itemId in ipairs(game.shop_offers.items or {}) do
        if not isHidden(game, "item", itemId) then
            table.insert(filteredItems, itemId)
        end
    end

    game.shop_offers.laws = filteredLaws
    game.shop_offers.buildings = filteredBuildings
    game.shop_offers.items = filteredItems

    if #game.shop_offers.laws < 3 then
        local extraLawIds = takeWeightedLawIds(collectAvailableLawIds(game, player), 3 - #game.shop_offers.laws, game.shop_offers.laws)
        for _, lawId in ipairs(extraLawIds) do
            table.insert(game.shop_offers.laws, lawId)
        end
    end
    if #game.shop_offers.buildings < 2 then
        local extraBuildingIds = takeWeightedBuildingIds(collectAvailableBuildingIds(game), 2 - #game.shop_offers.buildings, game.shop_offers.buildings)
        for _, buildingId in ipairs(extraBuildingIds) do
            table.insert(game.shop_offers.buildings, buildingId)
        end
    end
    if #game.shop_offers.items < 2 then
        local extraItemIds = takeRandomIds(collectAvailableItemIds(game, player), 2 - #game.shop_offers.items, game.shop_offers.items)
        for _, itemId in ipairs(extraItemIds) do
            table.insert(game.shop_offers.items, itemId)
        end
    end
end

-- Reroll toutes les offres du shop contre un cout fixe en pieces.
function shop.refreshOffers(game, player)
    local price = 5
    if not player.spendMoney(price) then
        return false, "Pas assez de pieces pour rafraichir."
    end

    shop.rollOffers(game, player)

    return true, "Shop rafraichi pour 5 pieces."
end

-- Calcule les zones et cartes cliquables du shop pour le rendu courant.
function shop.updateLayout(game, player)
    local panelW = 760
    local panelX = (love.graphics.getWidth() - panelW) / 2
    local panelY = 46
    local panelH = 610
    local topSection = {
        x = panelX + 24,
        y = panelY + 56,
        w = panelW - 48,
        h = 248
    }
    local bottomY = panelY + 330
    local buildingSection = {
        x = panelX + 24,
        y = bottomY,
        w = math.floor((panelW - 72) * 0.66),
        h = 186
    }
    local objectSection = {
        x = buildingSection.x + buildingSection.w + 24,
        y = bottomY,
        w = panelX + panelW - (buildingSection.x + buildingSection.w + 48),
        h = 186
    }
    game.shop_layout = {
        panel = {
            x = panelX,
            y = panelY,
            w = panelW,
            h = panelH
        },
        laws = topSection,
        buildings = buildingSection,
        objects = objectSection
    }

    game.shop_buttons = {
        buildings = {},
        laws = {},
        items = {}
    }

    shop.prepareOffers(game, player)

    local lawArea = layout.insetRect(topSection, 12, 42)
    local lawRects = layout.distributeRowInRect(lawArea, #game.shop_offers.laws, 190, 150, 12)
    for index, lawId in ipairs(game.shop_offers.laws or {}) do
        local lawData = law.getData(lawId)
        local rect = lawRects[index]
        game.shop_buttons.laws[index] = buildButton(lawData, "law", rect.x, rect.y, rect.w, rect.h)
        game.shop_buttons.laws[index].display_price = shop.getDisplayPrice(player, game.shop_buttons.laws[index])
    end

    local buildingArea = layout.insetRect(buildingSection, 12, 40)
    local buildingRects = layout.distributeRowInRect(buildingArea, #game.shop_offers.buildings, 166, 118, 12)
    for index, buildingId in ipairs(game.shop_offers.buildings) do
        local buildingData = buildings.getData(buildingId)
        local rect = buildingRects[index]
        game.shop_buttons.buildings[index] = buildButton(buildingData, "building", rect.x, rect.y, rect.w, rect.h)
        game.shop_buttons.buildings[index].display_price = shop.getDisplayPrice(player, game.shop_buttons.buildings[index])
    end

    local itemArea = layout.insetRect(objectSection, 12, 40)
    local itemRects = layout.distributeRowInRect(itemArea, #game.shop_offers.items, 150, 118, 10)
    for index, itemId in ipairs(game.shop_offers.items or {}) do
        local item = object.getData(itemId)
        local rect = itemRects[index]
        game.shop_buttons.items[index] = buildButton(item, "item", rect.x, rect.y, rect.w, rect.h)
        game.shop_buttons.items[index].display_price = shop.getDisplayPrice(player, game.shop_buttons.items[index])
    end

    game.round_clear_buttons.refresh = {
        x = panelX + 24,
        y = panelY + panelH - 78,
        w = 180,
        h = 54
    }
    game.round_clear_buttons.continue = layout.centerRectInRect(
        {
            x = panelX,
            y = panelY + panelH - 78,
            w = panelW,
            h = 54
        },
        180,
        54
    )
end

-- Achete un batiment et l'ajoute au deck permanent du joueur.
function shop.buyBuilding(player, buildingId)
    local building = buildings.getData(buildingId)
    if not building then
        return false, "Batiment introuvable."
    end
    if not player.spendMoney(building.price) then
        return false, "Pas assez de pieces."
    end

    player.addOwnedBuilding(building.id)
    return true, building.name .. " ajoute au deck."
end

-- Achete une loi en respectant les limites et les doublons autorises.
function shop.buyLaw(player, lawId)
    local targetLaw = law.getData(lawId)
    if not targetLaw then
        return false, "Loi introuvable."
    end
    local copyCount = player.countLawCopies(lawId)
    if copyCount > 0 and not player.allow_duplicate_laws then
        return false, "Loi deja possedee."
    end
    if player.allow_duplicate_laws and copyCount >= 2 then
        return false, "Maximum 2 exemplaires de cette loi."
    end
    if #player.laws >= player.MAX_LAWS then
        return false, "Maximum " .. player.MAX_LAWS .. " lois."
    end
    if not player.spendMoney(targetLaw.price) then
        return false, "Pas assez de pieces."
    end

    player.addLaw(cloneTable(targetLaw))
    return true, targetLaw.name .. " achetee."
end

-- Achete un objet et l'ajoute a l'inventaire du joueur.
function shop.buyItem(player, itemId)
    local targetItem = object.getData(itemId)
    if not targetItem then
        return false, "Objet introuvable."
    end
    if #player.items >= player.MAX_ITEMS then
        return false, "Maximum " .. player.MAX_ITEMS .. " objets."
    end

    local price = getItemPrice(player, targetItem)
    if not player.spendMoney(price) then
        return false, "Pas assez de pieces."
    end

    player.addItem(cloneTable(targetItem))
    return true, targetItem.name .. " ajoute a l'inventaire."
end

-- Vend une loi depuis le classeur pour la moitie de son prix.
function shop.sellLaw(player, index)
    local lawToSell = player.laws[index]
    if not lawToSell then
        return false, "Loi introuvable."
    end

    local refund = math.floor((lawToSell.price or 0) / 2)
    player.removeLaw(index)
    player.addMoney(refund)
    return true, lawToSell.name .. " vendue pour " .. refund .. " pieces."
end

return shop
