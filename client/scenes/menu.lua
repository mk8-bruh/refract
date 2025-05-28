local menu = {}

function menu:created()
    self.title = Title(self, "REFRACT")
    self.playButton = Button(self, "Play", function()
        
    end)

    self.layout = {
        self.title,
        self.playButton
    }
    self.spacing = 20
end

function menu:resize(w, h)
    local contentSize = self.spacing * (#self.layout - 1)
    for _, element in ipairs(self.layout) do
        contentSize = contentSize + (element.size or element:getSize()).y
    end
    local y = h/2 - contentSize/2
    for _, element in ipairs(self.layout) do
        local element_h = (element.size or element:getSize()).y
        element.position = vec(w/2, y + element_h/2)
        y = y + element_h + self.spacing
    end
end

function menu:draw()
    love.graphics.clear(1, 1, 1)
end

return floof.new(menu)