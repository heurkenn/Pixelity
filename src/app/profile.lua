-- src/app/profile.lua
-- Persistent profile save for meta progression: unlocks and global statistics.

local profile = {}

local PROFILE_PATH = "profile.lua"

local DEFAULT_DATA = {
    unlocks = {
        mayors = {
            [1] = true
        },
        difficulties = {
            easy = true,
            normal = false,
            hard = false
        }
    },
    stats = {
        games_started = 0,
        buildings_placed = 0,
        money_spent = 0,
        obstacles_destroyed = 0,
        games_won = 0,
        best_global_score = 0
    }
}

local data = nil

local function deepCopy(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function serialize(value)
    if type(value) == "number" or type(value) == "boolean" then
        return tostring(value)
    end
    if type(value) == "string" then
        return string.format("%q", value)
    end
    if type(value) == "table" then
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

local function ensureDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = target[key] or {}
            ensureDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function profile.load()
    data = deepCopy(DEFAULT_DATA)

    if not love.filesystem.getInfo(PROFILE_PATH) then
        return data
    end

    local chunk = love.filesystem.load(PROFILE_PATH)
    if not chunk then
        return data
    end

    local ok, loaded = pcall(chunk)
    if ok and type(loaded) == "table" then
        data = loaded
        ensureDefaults(data, DEFAULT_DATA)
    end

    return data
end

function profile.save()
    if not data then
        profile.load()
    end
    love.filesystem.write(PROFILE_PATH, "return " .. serialize(data))
end

function profile.getData()
    if not data then
        return profile.load()
    end
    return data
end

function profile.isMayorUnlocked(mayorId)
    return profile.getData().unlocks.mayors[mayorId] == true
end

function profile.isDifficultyUnlocked(difficultyId)
    return profile.getData().unlocks.difficulties[difficultyId] == true
end

function profile.recordRunStarted()
    local profileData = profile.getData()
    profileData.stats.games_started = profileData.stats.games_started + 1
    profile.save()
end

function profile.recordBuildingsPlaced(count)
    if count <= 0 then
        return
    end
    local profileData = profile.getData()
    profileData.stats.buildings_placed = profileData.stats.buildings_placed + count
    profile.save()
end

function profile.recordMoneySpent(amount)
    if amount <= 0 then
        return
    end
    local profileData = profile.getData()
    profileData.stats.money_spent = profileData.stats.money_spent + amount
    profile.save()
end

function profile.recordObstacleDestroyed(count)
    count = count or 1
    if count <= 0 then
        return
    end
    local profileData = profile.getData()
    profileData.stats.obstacles_destroyed = profileData.stats.obstacles_destroyed + count
    profile.save()
end

function profile.updateBestScore(score)
    local profileData = profile.getData()
    if score > (profileData.stats.best_global_score or 0) then
        profileData.stats.best_global_score = score
        profile.save()
    end
end

function profile.finishRun(game, player, won)
    if game.run_recorded then
        return
    end

    local profileData = profile.getData()
    local mayorId = game.selected_mayor_id or (player.mayor and player.mayor.id) or 1
    local difficultyId = game.selected_difficulty_id or (player.difficulty and player.difficulty.id) or "easy"

    profileData.unlocks.mayors[mayorId + 1] = true
    if difficultyId == "easy" then
        profileData.unlocks.difficulties.normal = true
    elseif difficultyId == "normal" then
        profileData.unlocks.difficulties.hard = true
    end

    if won then
        profileData.stats.games_won = profileData.stats.games_won + 1
    end

    profile.updateBestScore(player.total_score or 0)
    game.run_recorded = true
    profile.save()
end

return profile
