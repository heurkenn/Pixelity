-- src/helpers/fonts.lua
-- Centralises font loading and outlined text rendering for the whole UI layer.

local fonts = {}

local text_font = nil
local title_font = nil
local intro_title_font = nil
local score_font = nil

local function setFontFilter(font)
    if font and font.setFilter then
        font:setFilter("nearest", "nearest")
    end
end

function fonts.load()
    if love.filesystem.getInfo("assets/ThaleahFat.ttf") then
        title_font = love.graphics.newFont("assets/ThaleahFat.ttf", 60)
        intro_title_font = love.graphics.newFont("assets/ThaleahFat.ttf", 80)
        score_font = love.graphics.newFont("assets/ThaleahFat.ttf", 45)
        setFontFilter(title_font)
        setFontFilter(intro_title_font)
        setFontFilter(score_font)
    end

    if love.filesystem.getInfo("assets/PixeloidSans.ttf") then
        text_font = love.graphics.newFont("assets/PixeloidSans.ttf", 14)
        setFontFilter(text_font)
    elseif love.filesystem.getInfo("assets/PixeloidSans-Bold.ttf") then
        text_font = love.graphics.newFont("assets/PixeloidSans-Bold.ttf", 14)
        setFontFilter(text_font)
    end
end

function fonts.applyDefault()
    if text_font then
        love.graphics.setFont(text_font)
    end
end

function fonts.getTextFont()
    return text_font
end

function fonts.getTitleFont()
    return title_font
end

function fonts.getIntroTitleFont()
    return intro_title_font or title_font
end

function fonts.getScoreFont()
    return score_font
end

local function withFont(font, drawFn)
    local previousFont = love.graphics.getFont()
    if font then
        love.graphics.setFont(font)
    end
    drawFn()
    love.graphics.setFont(previousFont)
end

function fonts.drawOutlinedText(text, x, y, options)
    options = options or {}
    local font = options.font
    local mode = options.mode or "print"
    local limit = options.limit
    local align = options.align or "left"
    local scale = options.scale or 1
    local outline = options.outline or 1

    withFont(font, function()
        local function drawAt(offsetX, offsetY, r, g, b, a)
            love.graphics.setColor(r, g, b, a or 1)
            if mode == "printf" then
                love.graphics.printf(text, x + offsetX, y + offsetY, limit, align, 0, scale, scale)
            else
                love.graphics.print(text, x + offsetX, y + offsetY, 0, scale, scale)
            end
        end

        drawAt(-outline, 0, 0, 0, 0, 1)
        drawAt(outline, 0, 0, 0, 0, 1)
        drawAt(0, -outline, 0, 0, 0, 1)
        drawAt(0, outline, 0, 0, 0, 1)
        drawAt(-outline, -outline, 0, 0, 0, 1)
        drawAt(outline, -outline, 0, 0, 0, 1)
        drawAt(-outline, outline, 0, 0, 0, 1)
        drawAt(outline, outline, 0, 0, 0, 1)
        drawAt(0, 0, 1, 1, 1, 1)
    end)
end

return fonts
