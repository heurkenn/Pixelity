-- src/data/rounds.lua
-- Fixed round progression for the first 15-round run structure.

local rounds = {}

rounds.targets = {
    100,
    150,
    200,
    300,
    450,
    600,
    800,
    1200,
    1600,
    1200,
    1800,
    2400,
    1800,
    2700,
    3600
}

rounds.boss_rounds = {
    [3] = true,
    [6] = true,
    [9] = true,
    [12] = true,
    [15] = true
}

function rounds.getTarget(roundNumber)
    return rounds.targets[roundNumber] or rounds.targets[#rounds.targets]
end

function rounds.isBossRound(roundNumber)
    return rounds.boss_rounds[roundNumber] == true
end

function rounds.getFinalRound()
    return #rounds.targets
end

return rounds
