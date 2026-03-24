-- src/shop.lua

local buildings = require("src.buildings")
local law = require("src.law")
local object = require("src.object")
local layout = require("src.layout")

local shop = {}

local function cloneTable(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function buildButton(item, section, x, y, w, h)
    local button = cloneTable(item)
    button.section = section
    button.x = x
    button.y = y
    button.w = w
    button.h = h
    return button
end

local function isHidden(game, section, id)
    return game.shop_hidden_entries and game.shop_hidden_entries[section .. ":" .. tostring(id)] == true
end

function shop.hideEntry(game, section, id)
    game.shop_hidden_entries = game.shop_hidden_entries or {}
    game.shop_hidden_entries[section .. ":" .. tostring(id)] = true
end

local function hasValue(list, value)
    for _, item in ipairs(list or {}) do
        if item == value then
            return true
        end
    end
    return false
end

function shop.prepareOffers(game, player)
    local availableBuildings = {}
    game.shop_offers = game.shop_offers or { buildings = {} }

    for _, building in ipairs(buildings.types) do
        if not isHidden(game, "building", building.id) then
            table.insert(availableBuildings, building.id)
        end
    end

    if #game.shop_offers.buildings == 0 then
        while #game.shop_offers.buildings < math.min(2, #availableBuildings) do
            local pickIndex = love.math.random(1, #availableBuildings)
            local pickedId = table.remove(availableBuildings, pickIndex)
            table.insert(game.shop_offers.buildings, pickedId)
        end
        return
    end

    local nextOffers = {}
    for _, buildingId in ipairs(game.shop_offers.buildings) do
        if not isHidden(game, "building", buildingId) then
            table.insert(nextOffers, buildingId)
        end
    end

    for _, buildingId in ipairs(availableBuildings) do
        if #nextOffers >= 2 then
            break
        end
        if not hasValue(nextOffers, buildingId) then
            table.insert(nextOffers, buildingId)
        end
    end

    game.shop_offers.buildings = nextOffers
end

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
    local availableLaws = {}

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

    for _, lawData in ipairs(law.types) do
        local alreadyOwned = player and player.hasLaw(lawData.id)
        if (not alreadyOwned or (player and player.allow_duplicate_laws)) and not isHidden(game, "law", lawData.id) then
            table.insert(availableLaws, lawData)
        end
    end

    while #availableLaws > 3 do
        table.remove(availableLaws)
    end

    local lawGap = 12
    local lawCardH = 150
    local lawCardW = 190
    local lawArea = layout.insetRect(topSection, 12, 42)
    local lawRects = layout.distributeRowInRect(lawArea, #availableLaws, lawCardW, lawCardH, lawGap)
    for index, lawData in ipairs(availableLaws) do
        local rect = lawRects[index]
        game.shop_buttons.laws[index] = buildButton(
            lawData,
            "law",
            rect.x,
            rect.y,
            rect.w,
            rect.h
        )
    end

    local buildingCardW = 166
    local buildingCardH = 118
    local buildingGap = 12
    local buildingArea = layout.insetRect(buildingSection, 12, 40)
    local buildingRects = layout.distributeRowInRect(buildingArea, #game.shop_offers.buildings, buildingCardW, buildingCardH, buildingGap)
    for index, buildingId in ipairs(game.shop_offers.buildings) do
        local building = buildings.getData(buildingId)
        local rect = buildingRects[index]
        game.shop_buttons.buildings[index] = buildButton(
            building,
            "building",
            rect.x,
            rect.y,
            rect.w,
            rect.h
        )
    end

    local availableItems = {}
    for _, item in ipairs(object.types) do
        if not isHidden(game, "item", item.id) then
            table.insert(availableItems, item)
        end
    end

    local itemArea = layout.insetRect(objectSection, 12, 40)
    local itemRects = layout.distributeRowInRect(itemArea, #availableItems, 150, 118, 10)
    for index, item in ipairs(availableItems) do
        local rect = itemRects[index]
        game.shop_buttons.items[index] = buildButton(
            item,
            "item",
            rect.x,
            rect.y,
            rect.w,
            rect.h
        )
    end

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

function shop.buyLaw(player, lawId)
    local targetLaw = nil
    targetLaw = law.getData(lawId)

    if not targetLaw then
        return false, "Loi introuvable."
    end
    if player.hasLaw(lawId) and not player.allow_duplicate_laws then
        return false, "Loi deja possedee."
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

function shop.buyItem(player, itemId)
    local targetItem = nil
    targetItem = object.getData(itemId)

    if not targetItem then
        return false, "Objet introuvable."
    end
    if #player.items >= player.MAX_ITEMS then
        return false, "Maximum " .. player.MAX_ITEMS .. " objets."
    end
    if not player.spendMoney(targetItem.price) then
        return false, "Pas assez de pieces."
    end

    player.addItem(cloneTable(targetItem))
    return true, targetItem.name .. " ajoute a l'inventaire."
end

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
