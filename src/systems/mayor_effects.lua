-- src/systems/mayor_effects.lua
-- Applies persistent mayor effects to player stats that live across the run.

local mayor_effects = {}

function mayor_effects.applyPersistentEffects(player)
    player.MAX_LAWS = 5
    player.MAX_ITEMS = 2
    player.allow_duplicate_laws = false
    player.explosive_preserve_chance = 0
    player.bank_money_multiplier = 1

    for _, effect in ipairs(player.mayor and player.mayor.effects or {}) do
        if effect.type == "max_laws_modifier" then
            player.MAX_LAWS = player.MAX_LAWS + effect.value
        elseif effect.type == "max_items_modifier" then
            player.MAX_ITEMS = player.MAX_ITEMS + effect.value
        elseif effect.type == "allow_duplicate_laws" then
            player.allow_duplicate_laws = true
        elseif effect.type == "explosive_preserve_chance" then
            player.explosive_preserve_chance = effect.value
        elseif effect.type == "building_money_multiplier" and effect.source == "bank" then
            player.bank_money_multiplier = effect.multiplier
        end
    end
end

return mayor_effects
