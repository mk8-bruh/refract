local menu = {check = true, tostring = "[menu scene]"}

function menu:init()
    self.title = Title(self, "REFRACT")
    self.playButton = Button(self, "Play", function()
        switchScene("Game")
    end)
    self.optionsButton = Button(self, "Options", function()
        switchScene("Options")
    end)
    self.quitButton = Button(self, "Quit", function()
        love.event.quit()
    end)

    self.backgroundImage = love.graphics.newImage("textures/menu_bg.png")

    self.music = love.audio.newSource("audio/scifi.mp3", "stream")
    self.music:setLooping(true)
    self.music:play()
    self.music:setVolume(settings.volume)

    self.layout = {
        self.title,
        self.playButton,
        self.optionsButton, -- Add the options button to the layout
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
        element.anchor = vec(w/2, y + element_h/2)
        element.width = w * 0.2
        y = y + element_h + self.spacing
    end
end

function menu:draw()
    -- Draw the background image, scaled to fill the screen (cover, not stretch)
    local w, h = love.graphics.getDimensions()
    local img = self.backgroundImage
    if img then
        local iw, ih = img:getWidth(), img:getHeight()
        local scale = math.max(w / iw, h / ih)
        local drawW, drawH = iw * scale, ih * scale
        local offsetX, offsetY = (w - drawW) / 2, (h - drawH) / 2
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(img, offsetX, offsetY, 0, scale, scale)
    end

    -- Draw other UI elements here (title, buttons, etc.)
    -- Example: self.title:draw(), self.playButton:draw(), etc.
end

return floof.new(menu)