-- src/app/input_shared.lua
-- Shared input helpers reused by multiple app states.

local shared = {}

function shared.handleOptionsClick(game, layout, x, y)
    if layout.pointInRect(x, y, game.options_modal.close) or not layout.pointInRect(x, y, game.options_modal.panel) then
        game.options_open = false
        return true
    end

    for _, speedButton in ipairs(game.speed_buttons) do
        if layout.pointInRect(x, y, speedButton) then
            game.scoring_speed = speedButton.multiplier
            game.message = "Vitesse du scoring: x" .. speedButton.multiplier
            return true
        end
    end

    if layout.pointInRect(x, y, game.confirm_toggle_button) then
        game.confirm_empty_build_enabled = not game.confirm_empty_build_enabled
        return true
    end

    return true
end

return shared
