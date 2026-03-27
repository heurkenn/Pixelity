-- src/app/game_state.lua
-- Central place to build the root game table used by main.lua and the app modules.

local game_state = {}

-- Construit l'etat racine du jeu avec toutes les cles partagees entre scenes.
function game_state.create()
    return {
        state = "splash",
        round = 1,
        rounds_played = 0,
        target_score = 100,
        has_save = false,
        menu_play_open = false,
        run_recorded = false,
        boss_order = nil,
        current_boss = nil,
        boss_intro = nil,
        pending_placements = {},
        selected_hand_index = nil,
        build_button = nil,
        redraw_button = nil,
        start_buttons = {
            mayors = {},
            difficulties = {},
            start = nil
        },
        debug_open = false,
        debug_scroll = 0,
        debug_scroll_max = 0,
        debug_buttons = nil,
        selected_mayor_id = 1,
        selected_difficulty_id = "easy",
        setup_step = "mayor",
        dealing_timer = 0,
        resolving = false,
        resolution_queue = {},
        resolution_index = 0,
        resolution_timer = 0,
        current_resolution_score = 0,
        highlight_cell = nil,
        current_score_popup = nil,
        boss_effect = nil,
        selected_item_index = nil,
        scoring_speed = 1,
        video_mode = "windowed",
        options_open = false,
        stats_open = false,
        codex_open = false,
        deck_view_open = false,
        selected_codex_law_index = nil,
        confirm_empty_build_enabled = true,
        options_reset_confirm_open = false,
        confirm_empty_build_open = false,
        options_button = nil,
        speed_buttons = {},
        video_mode_buttons = {},
        confirm_toggle_button = nil,
        options_reset_data_button = nil,
        options_reset_confirm_button = nil,
        confirm_modal = nil,
        round_clear = nil,
        victory_summary = nil,
        round_clear_buttons = nil,
        dragging = {
            active = false,
            hand_index = nil,
            card = nil,
            offset_x = 0,
            offset_y = 0,
            x = 0,
            y = 0
        },
        message = "",
        intro = nil,
        mayor_portraits = {}
    }
end

return game_state
