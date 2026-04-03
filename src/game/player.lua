-- src/game/player.lua

local player = {}
local buildings = require("src.data.buildings")

local DEFAULT_HAND_SIZE = 7
local DEFAULT_BUILD_ACTIONS = 3
local DEFAULT_REDRAWS = 2
local DEFAULT_MAX_LAWS = 5
local DEFAULT_MAX_ITEMS = 2
local DEFAULT_MAX_PENDING_PLACEMENTS = 4

-- Vide une table mutable sans en changer la reference.
local function clearTable(target)
    for key in pairs(target) do
        target[key] = nil
    end
end

-- Additionne les bonus de poses en attente donnes par les lois, avec modificateurs de plateau si presents.
local function getLawPendingPlacementBonus(grid)
    local total = 0
    local lawMultiplier = 1
    local fallbackBonus = 0

    if grid then
        local building_effects = require("src.game.systems.building_effects")
        for _, activeEffect in ipairs(building_effects.collectTriggeredEffects(grid, "board_modifier", "law_effect_multiplier")) do
            lawMultiplier = lawMultiplier * (activeEffect.effect.multiplier or 1)
            fallbackBonus = fallbackBonus + (activeEffect.effect.fallback_bonus or 0)
        end
    end

    for _, ownedLaw in ipairs(player.laws) do
        for _, effect in ipairs(ownedLaw.effects or {}) do
            if effect.type == "extra_pending_placements" then
                total = total + math.floor(((effect.value or 0) * lawMultiplier) + fallbackBonus)
            end
        end
    end

    return total
end

-- Compte combien d'exemplaires d'un type de batiment existent dans tous les paquets de la run.
function player.countBuildingCopiesByKey(buildingKey)
    local count = 0

    local function countInPile(cards)
        for _, card in ipairs(cards or {}) do
            if card.key == buildingKey then
                count = count + 1
            end
        end
    end

    countInPile(player.deck)
    countInPile(player.hand)
    countInPile(player.discard)

    return count
end

-- Compte combien d'exemplaires achetes d'un type de batiment appartiennent au deck permanent.
function player.countOwnedBuildingCopiesByKey(buildingKey)
    local count = 0

    for _, buildingId in ipairs(player.owned_buildings) do
        local buildingData = buildings.getData(buildingId)
        if buildingData and buildingData.key == buildingKey then
            count = count + 1
        end
    end

    return count
end

-- Retourne le nombre maximal de cartes posables avant un BUILD.
function player.getMaxPendingPlacements(grid)
    return DEFAULT_MAX_PENDING_PLACEMENTS + getLawPendingPlacementBonus(grid)
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
player.explosive_money_loss_chance = 0
player.explosive_money_loss_fraction = 0
player.bank_money_multiplier = 1
player.object_price_multiplier = 1
player.max_park_on_grid = nil
player.current_boss = nil
player.available_builds = DEFAULT_BUILD_ACTIONS
player.available_redraws = DEFAULT_REDRAWS
player.hand_size = DEFAULT_HAND_SIZE
player.hand_can_redraw = true
player.deck_empty = false

-- Assigne au joueur les donnees du maire choisi.
function player.setMayor(mayorID)
    local mayorData = require("src.data.mayor").getData(mayorID)
    if mayorData then
        player.mayor = mayorData
    end
end

-- Assigne la difficulte active de la run.
function player.setDifficulty(difficulty)
    player.difficulty = difficulty
end

-- Reinitialise completement l'etat du joueur pour une nouvelle run.
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
    player.explosive_money_loss_chance = 0
    player.explosive_money_loss_fraction = 0
    player.bank_money_multiplier = 1
    player.object_price_multiplier = 1
    player.max_park_on_grid = nil
    player.current_boss = nil
    player.available_builds = DEFAULT_BUILD_ACTIONS
    player.available_redraws = DEFAULT_REDRAWS
    player.hand_size = DEFAULT_HAND_SIZE
    player.hand_can_redraw = true
    player.deck_empty = false
end

-- Reconstruit le deck de depart a partir de la base et des achats permanents.
function player.initDeck()
    clearTable(player.deck)
    clearTable(player.hand)
    clearTable(player.discard)

    for _, b in ipairs(buildings.types) do
        if b.name == "House" then
            for _ = 1, 10 do
                table.insert(player.deck, b)
            end
        elseif b.name == "Park" then
            for _ = 1, 6 do
                table.insert(player.deck, b)
            end
        elseif b.name == "Factory" then
            for _ = 1, 2 do
                table.insert(player.deck, b)
            end
        end
    end

    for _, buildingId in ipairs(player.owned_buildings) do
        local buildingData = buildings.getData(buildingId)
        if buildingData then
            table.insert(player.deck, buildingData)
        end
    end
end

-- Pioche aleatoirement jusqu'a remplir la main du joueur.
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

-- Demarre une nouvelle manche avec pioche et reset des actions.
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

-- Recomplete la main apres un BUILD.
function player.refillHandAfterBuild()
    player.drawHand()
    player.hand_can_redraw = #player.hand > 0
end

-- Retire une carte precise de la main.
function player.removeCardFromHand(index)
    if index >= 1 and index <= #player.hand then
        return table.remove(player.hand, index)
    end
    return nil
end

-- Remet une carte dans la main du joueur.
function player.returnCardToHand(card)
    if card then
        table.insert(player.hand, card)
    end
end

-- Envoie les cartes construites dans la defausse.
function player.commitPlacedCards(cards)
    for _, card in ipairs(cards) do
        table.insert(player.discard, card)
    end
end

-- Ajoute une carte arbitraire a la defausse.
function player.addCardToDiscard(card)
    if card then
        table.insert(player.discard, card)
    end
end

-- Defausse toute la main et en pioche une nouvelle.
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

-- Consomme une action BUILD si elle est encore disponible.
function player.consumeBuild()
    if player.available_builds <= 0 then
        return false
    end

    player.available_builds = player.available_builds - 1
    return true
end

-- Met a jour le score courant et le score de manche.
function player.setScores(totalScore, roundScore)
    player.score = totalScore
    player.round_score = roundScore
end

-- Met a jour le score global transfere en fin de manche.
function player.setTotalScore(totalScore)
    player.total_score = totalScore
end

-- Ajoute des pieces au joueur.
function player.addMoney(amount)
    player.money = player.money + amount
end

-- Depense des pieces si le joueur en a assez.
function player.spendMoney(amount)
    if player.money < amount then
        return false
    end

    player.money = player.money - amount
    return true
end

-- Indique si une loi donnee est deja possedee.
function player.hasLaw(lawId)
    for _, law in ipairs(player.laws) do
        if law.id == lawId then
            return true
        end
    end
    return false
end

-- Compte le nombre d'exemplaires d'une loi possedes.
function player.countLawCopies(lawId)
    local count = 0
    for _, law in ipairs(player.laws) do
        if law.id == lawId then
            count = count + 1
        end
    end
    return count
end

-- Ajoute une loi a la collection du joueur.
function player.addLaw(law)
    table.insert(player.laws, law)
end

-- Retire une loi de la collection a un index donne.
function player.removeLaw(index)
    if index >= 1 and index <= #player.laws then
        return table.remove(player.laws, index)
    end
    return nil
end

-- Ajoute un batiment achete a la liste persistante du deck.
function player.addOwnedBuilding(buildingId)
    table.insert(player.owned_buildings, buildingId)
end

-- Ajoute un objet a l'inventaire du joueur.
function player.addItem(item)
    table.insert(player.items, item)
end

-- Consomme un objet de l'inventaire a un index donne.
function player.consumeItem(index)
    if index >= 1 and index <= #player.items then
        return table.remove(player.items, index)
    end
    return nil
end

return player
