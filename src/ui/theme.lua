-- src/ui/theme.lua
-- Centralise les couleurs principales de l'interface pour garder un style coherent.

local theme = {}

theme.text = { 1, 1, 1 }
theme.text_dim = { 0.58, 0.58, 0.58 }
theme.overlay = { 0, 0, 0, 0.6 }

theme.panel = { 0.12, 0.14, 0.18 }
theme.panel_alt = { 0.18, 0.22, 0.28 }
theme.panel_soft = { 0.16, 0.2, 0.26 }
theme.panel_highlight = { 0.2, 0.24, 0.3 }
theme.panel_outline = { 0.4, 0.46, 0.54, 0.9 }

theme.info_fill = { 0.14, 0.18, 0.22, 0.98 }
theme.progress_fill = { 0.22, 0.72, 0.42, 0.96 }

theme.buttons = {
    primary = { fill = { 0.18, 0.48, 0.32 }, text = { 1, 1, 1 } },
    secondary = { fill = { 0.24, 0.26, 0.34 }, text = { 1, 1, 1 } },
    danger = { fill = { 0.52, 0.2, 0.2 }, text = { 1, 1, 1 } },
    warning = { fill = { 0.22, 0.34, 0.48 }, text = { 1, 1, 1 } },
    selected = { fill = { 0.82, 0.64, 0.26 }, text = { 1, 1, 1 } },
    disabled = { fill = { 0.18, 0.18, 0.2, 0.85 }, text = { 0.58, 0.58, 0.58 } }
}

theme.shop_lights = {
    frame = { 0.08, 0.12, 0.16 },
    border = { 0.12, 0.52, 0.62 },
    a = { 0.16, 0.82, 0.54 },
    b = { 0.18, 0.48, 0.92 }
}

theme.goal_lights = {
    frame = { 0.26, 0.18, 0.12 },
    border = { 0.74, 0.16, 0.18 },
    a = { 0.98, 0.84, 0.18 },
    b = { 0.76, 0.18, 0.18 }
}

return theme
