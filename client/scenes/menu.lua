local menu = {check = true, tostring = "[menu scene]"}

function menu:init()
    self.title = Title(self, "REFRACT", {origin = "top center"})

    self.layout = VerticalLayout(self, {}, {origin = "top center", align = "top", justify = "stretch", space = 20})

    self.playButton = Button(self.layout, "Play", function()
        switchScene("Game")
    end)
    self.optionsButton = Button(self.layout, "Options", function()
        switchScene("Options")
    end)
    self.quitButton = Button(self.layout, "Quit", function()
        love.event.quit()
    end)

    self.footer = Label(self, "made by mk8 and Dejv", {origin = "bottom center", font = love.graphics.newFont("fonts/Roboto-Light.ttf", 15)})

    self.backgroundImage = love.graphics.newImage("textures/menu_bg.png")

    self.music = love.audio.newSource("audio/scifi.mp3", "stream")
    table.insert(sounds.music, self.music)
    self.music:setLooping(true)

    self:resize(love.graphics.getDimensions())
end

function menu:resize(w, h)
    self.title.anchor = vec(w/2, h * 0.25)
    self.footer.anchor = vec(w/2, h - 10)
    self.layout.width = w * 0.3
    self.layout.height = self.footer:getTop() - self.title:getBottom() - 30
    self.layout:setPosition(w/2, (self.footer:getTop() + self.title:getBottom()) / 2)
end

function menu:draw()
    local w, h = love.graphics.getDimensions()
    local img = self.backgroundImage
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = math.max(w / iw, h / ih)
    local drawW, drawH = iw * scale, ih * scale
    local offsetX, offsetY = (w - drawW) / 2, (h - drawH) / 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, offsetX, offsetY, 0, scale, scale)
end

function menu:enter(prev, ...)
    self.music:play()
end

function menu:leave(next)
    self.music:stop()
end

return floof.new(menu)