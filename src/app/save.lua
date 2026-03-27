-- src/app/save.lua
-- Handles save/load of the playable run state and menu save availability.

local buildings = require("src.data.buildings")
local boss_catalog = require("src.data.boss")
local constants = require("src.constants")
local law = require("src.data.law")
local object = require("src.data.object")
local mayor_effects = require("src.game.systems.mayor_effects")

local save = {}
local SAVE_PATH = "savegame.lua"

-- Retourne l'objet difficulte complet a partir de son identifiant.
local function getDifficultyById(id)
    for _, difficulty in ipairs(constants.DIFFICULTIES) do
        if difficulty.id == id then
            return difficulty
        end
    end
    return constants.DIFFICULTIES[1]
end

-- Serialize une valeur Lua simple en texte sauvegardable.
local function serialize(value)
    local valueType = type(value)
    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    end
    if valueType == "string" then
        return string.format("%q", value)
    end
    if valueType == "table" then
        local parts = {"{"}
        for key, item in pairs(value) do
            local encodedKey
            if type(key) == "number" then
                encodedKey = "[" .. key .. "]"
            else
                encodedKey = "[" .. string.format("%q", key) .. "]"
            end
            table.insert(parts, encodedKey .. "=" .. serialize(item) .. ",")
        end
        table.insert(parts, "}")
        return table.concat(parts)
    end
    return "nil"
end

-- Transforme une liste de cartes en simple liste d'identifiants.
local function cloneIdList(cards)
    local ids = {}
    for _, entry in ipairs(cards or {}) do
        table.insert(ids, entry.id)
    end
    return ids
end

-- Reconstitue les cartes temporaires posees pour les remettre en main en sauvegarde.
local function clonePendingToHandIds(game)
    local ids = {}
    for _, placement in ipairs(game.pending_placements or {}) do
        table.insert(ids, placement.card.id)
    end
    return ids
end

-- Rehydrate une liste de cartes depuis leurs identifiants sauvegardes.
local function restoreCardsFromIds(target, ids)
    for _, id in ipairs(ids or {}) do
        local buildingData = buildings.getData(id)
        if buildingData then
            table.insert(target, buildingData)
        end
    end
end

-- Rehydrate une liste de donnees catalogue depuis des identifiants sauvegardes.
local function restoreDataList(catalog, ids)
    local list = {}
    for _, id in ipairs(ids or {}) do
        local entry = catalog.getData(id)
        if entry then
            table.insert(list, entry)
        end
    end
    return list
end

-- Indique si une sauvegarde de run existe sur disque.
function save.exists()
    return love.filesystem.getInfo(SAVE_PATH) ~= nil
end

-- Met a jour le flag de presence de sauvegarde dans l'etat du jeu.
function save.refreshFlag(game)
    game.has_save = save.exists()
end

-- Supprime la sauvegarde de run et nettoie les traces runtime associees.
function save.clear(game)
    if save.exists() then
        love.filesystem.remove(SAVE_PATH)
    end
    if game then
        game.has_save = false
        game.shop_hidden_entries = {}
        game.shop_offers = nil
        game.round_clear = nil
    end
end

-- Sauvegarde l'etat persistant necessaire pour reprendre une run.
function save.saveRun(game, player, grid)
    if game.state ~= "playing" and game.state ~= "round_clear" then
        return false, "Aucune partie active a sauvegarder."
    end

    local restoredHandIds = cloneIdList(player.hand)
    local pendingIds = clonePendingToHandIds(game)
    for _, id in ipairs(pendingIds) do
        table.insert(restoredHandIds, id)
    end

    local payload = {
        version = 1,
        game = {
            state = game.state,
            round = game.round,
            rounds_played = game.rounds_played or game.round,
            target_score = game.target_score,
            current_resolution_score = game.current_resolution_score,
            selected_mayor_id = game.selected_mayor_id,
            selected_difficulty_id = game.selected_difficulty_id,
            round_clear = game.round_clear,
            boss_order = game.boss_order,
            current_boss_id = game.current_boss and game.current_boss.id or nil,
            shop_offers = game.shop_offers,
            shop_hidden_entries = game.shop_hidden_entries
        },
        player = {
            money = player.money,
            score = player.score,
            round_score = player.round_score,
            total_score = player.total_score,
            available_builds = player.available_builds,
            available_redraws = player.available_redraws,
            hand_size = player.hand_size,
            hand_can_redraw = player.hand_can_redraw,
            deck_empty = player.deck_empty,
            owned_buildings = player.owned_buildings,
            laws = cloneIdList(player.laws),
            items = cloneIdList(player.items),
            deck = cloneIdList(player.deck),
            hand = restoredHandIds,
            discard = cloneIdList(player.discard)
        },
        grid = {
            cells = grid.getCells(),
            levels = grid.getLevels()
        }
    }

    local ok = love.filesystem.write(SAVE_PATH, "return " .. serialize(payload))
    game.has_save = ok == true
    if ok then
        return true, "Partie sauvegardee."
    end
    return false, "Echec de sauvegarde."
end

-- Charge une sauvegarde de run et reconstruit l'etat jouable correspondant.
function save.loadRun(game, player, grid)
    if not save.exists() then
        return false, "Aucune sauvegarde."
    end

    local chunk = love.filesystem.load(SAVE_PATH)
    if not chunk then
        return false, "Sauvegarde illisible."
    end

    local ok, payload = pcall(chunk)
    if not ok or type(payload) ~= "table" then
        return false, "Sauvegarde invalide."
    end

    player.reset()
    player.setMayor(payload.game.selected_mayor_id)
    mayor_effects.applyPersistentEffects(player)
    player.setDifficulty(getDifficultyById(payload.game.selected_difficulty_id))

    player.money = payload.player.money or 0
    player.score = payload.player.score or 0
    player.round_score = payload.player.round_score or 0
    player.total_score = payload.player.total_score or 0
    player.available_builds = payload.player.available_builds or 3
    player.available_redraws = payload.player.available_redraws or 2
    player.hand_size = payload.player.hand_size or 7
    player.hand_can_redraw = payload.player.hand_can_redraw == true
    player.deck_empty = payload.player.deck_empty == true
    player.owned_buildings = payload.player.owned_buildings or {}
    player.laws = restoreDataList(law, payload.player.laws)
    player.items = restoreDataList(object, payload.player.items)
    player.deck = {}
    player.hand = {}
    player.discard = {}
    restoreCardsFromIds(player.deck, payload.player.deck)
    restoreCardsFromIds(player.hand, payload.player.hand)
    restoreCardsFromIds(player.discard, payload.player.discard)

    grid.init(#(payload.grid.cells or {}))
    for y, row in ipairs(payload.grid.cells or {}) do
        for x, value in ipairs(row) do
            grid.setCell(x, y, value)
        end
    end
    for y, row in ipairs(payload.grid.levels or {}) do
        for x, value in ipairs(row) do
            grid.setCellLevel(x, y, value)
        end
    end

    game.grid_ref = grid
    game.round = payload.game.round or 1
    game.rounds_played = payload.game.rounds_played or game.round
    game.target_score = payload.game.target_score or 100
    game.current_resolution_score = payload.game.current_resolution_score or player.score
    game.selected_mayor_id = payload.game.selected_mayor_id or 1
    game.selected_difficulty_id = payload.game.selected_difficulty_id or "easy"
    game.round_clear = payload.game.round_clear
    game.boss_order = payload.game.boss_order or nil
    game.current_boss = payload.game.current_boss_id and boss_catalog.getData(payload.game.current_boss_id) or nil
    player.current_boss = game.current_boss
    game.boss_intro = nil
    if game.state == "boss_intro" and game.current_boss then
        game.boss_intro = {
            timer = 0.9,
            continue_ready = true,
            explosions = {},
            spawn_timer = 0
        }
    end
    game.pending_placements = {}
    game.selected_hand_index = nil
    game.selected_item_index = nil
    game.resolving = false
    game.resolution_queue = {}
    game.resolution_index = 0
    game.resolution_timer = 0
    game.highlight_cell = nil
    game.current_score_popup = nil
    game.boss_effect = nil
    game.dealing_timer = 0
    game.shop_hidden_entries = payload.game.shop_hidden_entries or {}
    game.shop_offers = payload.game.shop_offers or nil
    game.state = payload.game.state or "playing"
    game.menu_play_open = false
    game.options_open = false
    game.codex_open = false
    game.deck_view_open = false
    game.confirm_empty_build_open = false
    game.message = "Sauvegarde chargee."
    game.has_save = true

    return true, "Sauvegarde chargee."
end

return save
