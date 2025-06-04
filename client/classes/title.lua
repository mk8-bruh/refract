local title = floof.class("Title", Element)

title.color = {0, 0, 0}
title.font = love.graphics.newFont("fonts/Audiowide-Regular.ttf", 150)

function title:init(parent, text, anchor, origin, color, font)
    self.parent = parent
    self.text = text
    self.position = position
    self.color = color or title.color
    self.font = font or title.font

    -- Animation state
    self.typed = 0
    self.typing = true
    self.timer = 0
    self.typingSpeed = 0.17
    self.deletingSpeed = 0.03
    self.pauseTime = 1.7
    self.pause = 0

    -- Scatter offsets for each character
    self.scatterOffsets = {}
    self:generateScatter()
end

function title:generateScatter()
    self.scatterOffsets = {}
    for i = 1, #self.text do
        self.scatterOffsets[i] = love.math.random(-18, 18)
    end
end

function title:update(dt)
    if self.typing then
        self.timer = self.timer + dt
        if self.timer >= self.typingSpeed then
            self.timer = self.timer - self.typingSpeed
            self.typed = self.typed + 1
            if self.typed > #self.text then
                self.typed = #self.text
                self.typing = false
                self.pause = self.pauseTime
            end
        end
    else
        if self.pause > 0 then
            self.pause = self.pause - dt
        else
            self.timer = self.timer + dt
            if self.timer >= self.deletingSpeed then
                self.timer = self.timer - self.deletingSpeed
                self.typed = self.typed - 1
                if self.typed < 0 then
                    self.typed = 0
                    self.typing = true
                    self.pause = self.pauseTime
                    self:generateScatter() -- Generate new scatter when typing restarts
                end
            end
        end
    end
end

function title:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local shown = self.text:sub(1, self.typed)
    local offset_x = x - w/2

    for i = 1, #shown do
        local char = shown:sub(i, i)
        local scatter = self.scatterOffsets[i] or 0
        local char_w = self.font:getWidth(char)
        local draw_x = offset_x
        local draw_y = y - h/2 + scatter

        -- Draw black border (outline)
        love.graphics.setFont(self.font)
        love.graphics.setColor(0, 0, 0)
        for dx = -2, 2 do
            for dy = -2, 2 do
                if dx ~= 0 or dy ~= 0 then
                    love.graphics.print(char, draw_x + dx, draw_y + dy)
                end
            end
        end

        -- Draw white text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(char, draw_x, draw_y)

        offset_x = offset_x + char_w
    end
end

return title