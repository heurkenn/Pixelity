-- src/menus/intro.lua
-- Owns the whole splash intro lifecycle: asset loading, state reset, update and draw.

local fonts = require("src.ui.fonts")

local intro = {}
local FRAME_DURATION = 0.1
local RANDOM_PHASE_DURATION = 2.2
local CENTER_PHASE_DURATION = 1.15
local CENTER_BURST_INTERVAL = 0.08
local MAX_RANDOM_EXPLOSIONS = 18
local FADE_OUT_DURATION = 0.35

-- Tente de charger une image en toute securite et avec filtrage pixel.
local function tryLoadImage(path)
    if not love.filesystem.getInfo(path) then
        return nil
    end

    local ok, image = pcall(love.graphics.newImage, path)
    if not ok or not image then
        return nil
    end

    image:setFilter("nearest", "nearest")
    return image
end

-- Charge toutes les frames d'explosion utilisees par l'intro.
local function loadExplosionFrames()
    local frames = {}
    if not love.filesystem.getInfo("assets/explosions") then
        return frames
    end

    local items = love.filesystem.getDirectoryItems("assets/explosions")
    table.sort(items)
    for _, item in ipairs(items) do
        if item:match("%.png$") then
            local image = tryLoadImage("assets/explosions/" .. item)
            if image then
                table.insert(frames, image)
            end
        end
    end

    return frames
end

-- Initialise l'etat de l'intro et ses assets au demarrage du jeu.
function intro.load(game)
    game.intro = {
        timer = 0,
        duration = RANDOM_PHASE_DURATION + CENTER_PHASE_DURATION,
        tag_alpha = 0,
        explosions = {},
        explosion_frames = loadExplosionFrames(),
        phase = "random",
        spawn_timer = 0,
        center_spawn_timer = 0,
        center_pattern_index = 0
    }
end

-- Reinitialise l'etat temporel de l'intro pour un nouveau passage.
function intro.reset(game)
    game.intro = game.intro or {}
    game.intro.timer = 0
    game.intro.tag_alpha = 0
    game.intro.explosions = {}
    game.intro.duration = RANDOM_PHASE_DURATION + CENTER_PHASE_DURATION
    game.intro.explosion_frames = game.intro.explosion_frames or loadExplosionFrames()
    game.intro.phase = "random"
    game.intro.spawn_timer = 0
    game.intro.center_spawn_timer = 0
    game.intro.center_pattern_index = 0
end

-- Ajoute une explosion ponctuelle a l'etat visuel de l'intro.
local function spawnExplosion(state, x, y, scale)
    table.insert(state.explosions, {
        x = x,
        y = y,
        alpha = 1,
        scale = scale or 1,
        timer = 0
    })
end

-- Fait apparaitre une explosion aleatoire hors de la zone du logo.
local function spawnRandomScreenExplosion(state)
    local margin = 40
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local centerX = screenW / 2
    local centerY = screenH * 0.34 + 46
    local safeHalfW = 250
    local safeHalfH = 110

    for _ = 1, 24 do
        local x = love.math.random(margin, screenW - margin)
        local y = love.math.random(margin, screenH - margin)
        if math.abs(x - centerX) > safeHalfW or math.abs(y - centerY) > safeHalfH then
            spawnExplosion(state, x, y, love.math.random(8, 15) / 10)
            return
        end
    end
end

-- Declenche un motif d'explosions centre sur le logo de l'intro.
local function spawnCenterBurst(state)
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() * 0.34 + 46
    local burstPatterns = {
        {
            { x = -180, y = -16, scale = 1.55 },
            { x = -70, y = -8, scale = 1.7 },
            { x = 70, y = -8, scale = 1.7 },
            { x = 180, y = -16, scale = 1.55 }
        },
        {
            { x = -118, y = 42, scale = 1.55 },
            { x = 0, y = 24, scale = 1.85 },
            { x = 118, y = 42, scale = 1.55 }
        },
        {
            { x = -225, y = 20, scale = 1.3 },
            { x = -20, y = -44, scale = 1.45 },
            { x = 225, y = 20, scale = 1.3 }
        }
    }

    state.center_pattern_index = state.center_pattern_index + 1
    local pattern = burstPatterns[((state.center_pattern_index - 1) % #burstPatterns) + 1]
    for _, point in ipairs(pattern) do
        spawnExplosion(state, centerX + point.x, centerY + point.y, point.scale)
    end
end

-- Met a jour les phases et les explosions de l'intro principale.
function intro.update(game, dt)
    local state = game.intro
    if not state then
        return
    end

    state.timer = state.timer + dt
    state.tag_alpha = math.min(1, math.max(0, (state.timer - 0.7) / 1.1))

    if #state.explosion_frames > 0 then
        if state.phase == "random" then
            state.spawn_timer = state.spawn_timer + dt
            while state.spawn_timer >= 0.11 and #state.explosions < MAX_RANDOM_EXPLOSIONS do
                state.spawn_timer = state.spawn_timer - 0.11
                spawnRandomScreenExplosion(state)
            end

            if state.timer >= RANDOM_PHASE_DURATION then
                state.phase = "center"
                state.center_spawn_timer = 0
            end
        elseif state.phase == "center" then
            state.center_spawn_timer = state.center_spawn_timer + dt
            while state.timer < state.duration and state.center_spawn_timer >= CENTER_BURST_INTERVAL do
                state.center_spawn_timer = state.center_spawn_timer - CENTER_BURST_INTERVAL
                spawnCenterBurst(state)
            end
        end
    end

    for index = #state.explosions, 1, -1 do
        local effect = state.explosions[index]
        effect.timer = (effect.timer or 0) + dt
        local maxLifetime = #state.explosion_frames * FRAME_DURATION
        local remaining = math.max(0, maxLifetime - effect.timer)
        effect.alpha = math.min(1, remaining / 0.2)

        if effect.timer >= maxLifetime then
            table.remove(state.explosions, index)
        end
    end
end

-- Indique si l'intro est terminee et peut laisser place au menu.
function intro.isFinished(game)
    return game.intro
        and game.intro.timer >= game.intro.duration
        and #game.intro.explosions == 0
end

-- Dessine l'intro complete avec logo, tag et explosions.
function intro.draw(game)
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local state = game.intro
    if not state then
        return
    end
    local titleFont = fonts.getIntroTitleFont()
    local titleText = "Pixelity"
    local titleX = 0

    if titleFont then
        titleX = math.floor((screenW - titleFont:getWidth(titleText)) / 2)
    end

    love.graphics.clear(0, 0, 0)

    fonts.drawOutlinedText(titleText, titleX, math.floor(screenH * 0.31), {
        font = titleFont,
        outline = 1
    })

    love.graphics.setColor(1, 1, 1, math.min(1, state.tag_alpha or 0))
    love.graphics.printf("@Heurk3nnn", 0, math.floor(screenH * 0.31) + 122, screenW, "center")

    for _, effect in ipairs(state.explosions or {}) do
        local alpha = math.max(0, math.min(1, effect.alpha or 0))
        local scale = effect.scale or 1
        local frameIndex = math.min(#state.explosion_frames, math.floor((effect.timer or 0) / FRAME_DURATION) + 1)
        local explosionImage = state.explosion_frames[frameIndex]
        if explosionImage then
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.draw(
                explosionImage,
                effect.x,
                effect.y,
                0,
                scale,
                scale,
                explosionImage:getWidth() / 2,
                explosionImage:getHeight() / 2
            )
        end
    end

    local fadeAlpha = math.max(0, math.min(1, (state.timer - (state.duration - FADE_OUT_DURATION)) / FADE_OUT_DURATION))
    if fadeAlpha > 0 then
        love.graphics.setColor(0, 0, 0, fadeAlpha)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    end
end

return intro
