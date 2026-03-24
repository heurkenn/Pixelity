-- src/constants.lua

local constants = {}

constants.GRID_SIZE = 5
constants.TILE_SIZE = 64
constants.HAND_CARD_WIDTH = 120
constants.HAND_CARD_HEIGHT = 160
constants.HAND_GAP = 18
constants.BUILD_BATCH_LIMIT = 4
constants.BASE_RESOLUTION_STEP = 0.42
constants.BASE_SCORE_POPUP_DURATION = 0.45
constants.SCORING_SPEED_OPTIONS = { 1, 2, 4, 10 }

constants.DIFFICULTIES = {
    { id = "easy", name = "Facile", obstacle_count = 0 },
    { id = "normal", name = "Normal", obstacle_count = 2 },
    { id = "hard", name = "Difficile", obstacle_count = 4 }
}

return constants
