local Title = floof.class("Title", Element)

Title.color = {
    outline = {0, 0, 0},
    fill = {1, 1, 1}
}
Title.font = love.graphics.newFont("fonts/Audiowide-Regular.ttf", 150)
Title.outlineWidth = 2
Title.scatter = 18
Title.typingSpeed = 0.17
Title.deletingSpeed = 0.03
Title.pauseTime = 1.7

function Title:init(parent, text, params)
    self.parent = parent
    self.text = text
    if params then copyData(params, self) end

    self.typed = 0
    self.typing = true
    self.timer = 0
    self.pause = 0

    self:generateScatter()
end

function Title:generateScatter()
    self.scatterOffsets = {}
    for i = 1, #self.text do
        self.scatterOffsets[i] = love.math.random(-self.scatter, self.scatter)
    end
end

function Title:update(dt)
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
                    self:generateScatter()
                end
            end
        end
    end
end

function Title:draw()
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

        love.graphics.setFont(self.font)
        love.graphics.setColor(self.color.outline)
        for dx = -self.outlineWidth, self.outlineWidth do
            for dy = -self.outlineWidth, self.outlineWidth do
                if dx ~= 0 or dy ~= 0 then
                    love.graphics.print(char, draw_x + dx, draw_y + dy)
                end
            end
        end

        love.graphics.setColor(self.color.fill)
        love.graphics.print(char, draw_x, draw_y)

        offset_x = offset_x + char_w
    end
end

function Title:getSize()
    return vec(self.font:getWidth(self.text), self.font:getHeight() + self.scatter * 2)
end

return Title