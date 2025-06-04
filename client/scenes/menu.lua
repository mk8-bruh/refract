local menu = {check = true, tostring = "[menu scene]"}

function menu:init()
    self.title = Title(self, "REFRACT")
    self.playButton = Button(self, "Play", function()
        SwitchScene("Game")
    end)
    self.quitButton = Button(self, "Quit", function()
        love.event.quit()
    end)

    self.layout = {
        self.title,
        self.playButton,
        self.quitButton
    }
    self.spacing = 20

    self:resize(love.graphics.getDimensions())
end

function menu:resize(w, h)
    local contentSize = self.spacing * (#self.layout - 1)
    for _, element in ipairs(self.layout) do
        local s = element.size or element:getSize()
        contentSize = contentSize + s.y
    end
    local y = h/2 - contentSize/2
    for _, element in ipairs(self.layout) do
        local element_h = (element.size or element:getSize()).y
        element:setPosition(vec(w/2, y + element_h/2))
        element.width = w * 0.2
        y = y + element_h + self.spacing
    end
end

function menu:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
end

return floof.new(menu)