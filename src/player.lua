-- src/player.lua

local player = {}
local buildings = require("src.buildings")

local DEFAULT_HAND_SIZE = 5
local DEFAULT_BUILD_ACTIONS = 3
local DEFAULT_REDRAWS = 2
local DEFAULT_MAX_LAWS = 5
local DEFAULT_MAX_ITEMS = 2

local function clearTable(target)
    for key in pairs(target) do
        target[key] = nil
    end
end

player.score = 0
player.round_score = 0
player.total_score = 0
player.money = 0
player.mayor = nil
player.difficulty = nil
player.deck = {}
player.hand = {}
player.discard = {}
player.owned_buildings = {}
player.laws = {}
player.MAX_LAWS = DEFAULT_MAX_LAWS
player.items = {}
player.MAX_ITEMS = DEFAULT_MAX_ITEMS
player.allow_duplicate_laws = false
player.explosive_preserve_chance = 0
player.bank_money_multiplier = 1
player.available_builds = DEFAULT_BUILD_ACTIONS
player.available_redraws = DEFAULT_REDRAWS
player.hand_size = DEFAULT_HAND_SIZE
player.hand_can_redraw = true
player.deck_empty = false

function player.setMayor(mayorID)
    local mayorData = require("src.mayor").getData(mayorID)
    if mayorData then
        player.mayor = mayorData
    end
end

function player.setDifficulty(difficulty)
    player.difficulty = difficulty
end

function player.reset()
    player.score = 0
    player.round_score = 0
    player.total_score = 0
    player.money = 0
    player.mayor = nil
    player.difficulty = nil
    clearTable(player.deck)
    clearTable(player.hand)
    clearTable(player.discard)
    clearTable(player.owned_buildings)
    clearTable(player.laws)
    clearTable(player.items)
    player.MAX_LAWS = DEFAULT_MAX_LAWS
    player.MAX_ITEMS = DEFAULT_MAX_ITEMS
    player.allow_duplicate_laws = false
    player.explosive_preserve_chance = 0
    player.bank_money_multiplier = 1
    player.available_builds = DEFAULT_BUILD_ACTIONS
    player.available_redraws = DEFAULT_REDRAWS
    player.hand_can_redraw = true
    player.deck_empty = false
end

function player.initDeck()
    clearTable(player.deck)
    clearTable(player.hand)
    clearTable(player.discard)

    for _, b in ipairs(buildings.types) do
        if b.name == "House" then
            for _ = 1, 5 do
                table.insert(player.deck, b)
            end
        elseif b.name == "Park" then
            for _ = 1, 3 do
                table.insert(player.deck, b)
            end
        elseif b.name == "Factory" then
            table.insert(player.deck, b)
        end
    end

    for _, buildingId in ipairs(player.owned_buildings) do
        local buildingData = buildings.getData(buildingId)
        if buildingData then
            table.insert(player.deck, buildingData)
        end
    end
end

function player.drawHand()
    player.deck_empty = false

    while #player.hand < player.hand_size do
        if #player.deck == 0 then
            player.deck_empty = true
            break
        end

        local index = love.math.random(1, #player.deck)
        table.insert(player.hand, table.remove(player.deck, index))
    end
end

function player.startRound()
    player.available_builds = DEFAULT_BUILD_ACTIONS
    player.available_redraws = DEFAULT_REDRAWS
    for _, card in ipairs(player.hand) do
        table.insert(player.discard, card)
    end
    clearTable(player.hand)
    player.drawHand()
    player.hand_can_redraw = #player.hand > 0
end

function player.refillHandAfterBuild()
    player.drawHand()
    player.hand_can_redraw = #player.hand > 0
end

function player.removeCardFromHand(index)
    if index >= 1 and index <= #player.hand then
        return table.remove(player.hand, index)
    end
    return nil
end

function player.returnCardToHand(card)
    if card then
        table.insert(player.hand, card)
    end
end

function player.commitPlacedCards(cards)
    for _, card in ipairs(cards) do
        table.insert(player.discard, card)
    end
end

function player.addCardToDiscard(card)
    if card then
        table.insert(player.discard, card)
    end
end

function player.redrawHand()
    if player.available_redraws <= 0 or not player.hand_can_redraw or #player.hand == 0 then
        return false
    end

    for _, card in ipairs(player.hand) do
        table.insert(player.discard, card)
    end
    clearTable(player.hand)

    player.available_redraws = player.available_redraws - 1
    player.drawHand()
    player.hand_can_redraw = false
    return true
end

function player.consumeBuild()
    if player.available_builds <= 0 then
        return false
    end

    player.available_builds = player.available_builds - 1
    return true
end

function player.setScores(totalScore, roundScore)
    player.score = totalScore
    player.round_score = roundScore
end

function player.setTotalScore(totalScore)
    player.total_score = totalScore
end

function player.addMoney(amount)
    player.money = player.money + amount
end

function player.spendMoney(amount)
    if player.money < amount then
        return false
    end

    player.money = player.money - amount
    return true
end

function player.hasLaw(lawId)
    for _, law in ipairs(player.laws) do
        if law.id == lawId then
            return true
        end
    end
    return false
end

function player.addLaw(law)
    table.insert(player.laws, law)
end

function player.removeLaw(index)
    if index >= 1 and index <= #player.laws then
        return table.remove(player.laws, index)
    end
    return nil
end

function player.addOwnedBuilding(buildingId)
    table.insert(player.owned_buildings, buildingId)
end

function player.addItem(item)
    table.insert(player.items, item)
end

function player.consumeItem(index)
    if index >= 1 and index <= #player.items then
        return table.remove(player.items, index)
    end
    return nil
end

return player
