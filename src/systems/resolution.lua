-- src/systems/resolution.lua
-- Owns score popup timing, score transfer animation and round-clear countdown flow.

local constants = require("src.constants")
local layout = require("src.layout")

local resolution = {}

function resolution.getResolutionStep(game)
    return constants.BASE_RESOLUTION_STEP / game.scoring_speed
end

function resolution.getScorePopupDuration(game)
    return constants.BASE_SCORE_POPUP_DURATION / game.scoring_speed
end

function resolution.updateScorePopup(game, player, dt)
    if not game.current_score_popup then
        return false
    end

    local popup = game.current_score_popup
    popup.t = math.min(1, popup.t + (dt / popup.duration))

    if popup.t >= 1 then
        game.current_resolution_score = game.current_resolution_score + popup.points
        player.setScores(game.current_resolution_score, game.current_resolution_score)
        game.current_score_popup = nil
    end

    return false
end

function resolution.spawnScorePopup(game, stepData)
    local endX, endY = layout.getScoreAnchor()
    local startX = endX - 16
    local startY = endY + 38

    if stepData.step_type == "law" then
        game.highlight_cell = {
            label = stepData.law_name,
            points = stepData.points
        }
    else
        local cellX, cellY = layout.getCellScreenPosition(stepData.x, stepData.y)
        startX = cellX + constants.TILE_SIZE + 6
        startY = cellY + 12
        game.highlight_cell = { x = stepData.x, y = stepData.y, points = stepData.points }
    end

    game.current_score_popup = {
        step_type = stepData.step_type,
        label = stepData.law_name,
        points = stepData.points,
        start_x = startX,
        start_y = startY,
        end_x = endX + 92,
        end_y = endY + 2,
        t = 0,
        duration = resolution.getScorePopupDuration(game)
    }
end

function resolution.updateResolution(game, player, onFinishResolution, dt)
    if not game.resolving then
        return
    end
    if resolution.updateScorePopup(game, player, dt) or game.current_score_popup then
        return
    end

    game.resolution_timer = game.resolution_timer + dt
    if game.resolution_timer < resolution.getResolutionStep(game) then
        return
    end

    game.resolution_timer = 0
    game.resolution_index = game.resolution_index + 1

    local stepData = game.resolution_queue[game.resolution_index]
    if not stepData then
        onFinishResolution(game, player)
        return
    end

    resolution.spawnScorePopup(game, stepData)
end

function resolution.updateRoundClear(game, player, dt)
    if game.state ~= "round_clear" or not game.round_clear then
        return
    end

    local clear = game.round_clear

    if clear.phase == "banner" then
        clear.banner_timer = clear.banner_timer - dt
        if clear.banner_timer <= 0 then
            clear.phase = "countdown"
        end
        return
    end

    if clear.phase == "countdown" then
        if clear.countdown_delay > 0 then
            clear.countdown_delay = math.max(0, clear.countdown_delay - dt)
            return
        end

        clear.countdown_elapsed = clear.countdown_elapsed + dt
        local speed = 60 + (clear.countdown_elapsed * clear.countdown_elapsed * 260)
        local decrement = math.max(1, math.floor(speed * dt))
        local transferred = math.min(clear.score_display, decrement)
        clear.score_display = clear.score_display - transferred
        clear.global_score_display = clear.global_score_display + transferred

        if clear.score_display <= 0 then
            clear.score_display = 0
            player.setTotalScore(clear.global_score_display)
            clear.phase = "countdown_done"
        end
    end
end

return resolution
