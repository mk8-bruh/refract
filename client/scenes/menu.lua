local menu = Element{
    width = "100%", height = "100%", inLayout = false,
    __tostring = function(self) return "[menu scene]" end
}

menu.title = Title(menu, "REFRACT", {inLayout = false})

menu.layout = VerticalLayout(menu, {}, {inLayout = false, justifyChildren = "top", alignChildren = "stretch", space = 20})

menu.playButton = Button(menu.layout, "Play", function()
    switchScene("Game")
end)
menu.optionsButton = Button(menu.layout, "Options", function()
    switchScene("Options")
end)
menu.quitButton = Button(menu.layout, "Quit", function()
    love.event.quit()
end)

menu.footer = Label(menu, "made by mk8 and Dejv", {inLayout = false, font = love.graphics.newFont("fonts/Roboto-Light.ttf", 15)})

menu.backgroundImage = love.graphics.newImage("textures/menu_bg.png")

menu.music = love.audio.newSource("audio/scifi.mp3", "stream")
table.insert(sounds.music, menu.music)
menu.music:setLooping(true)

function menu:resize(w, h)
    self.title.x, self.title.y = w/2, h * 0.25 + self.title.h/2
    self.footer.x, self.footer.y = w/2, h - 10 - self.footer.h/2
    self.layout.w = w * 0.3
    self.layout.h = self.footer.t - self.title.b - 30
    self.layout.x, self.layout.y = w/2, (self.footer.t + self.title.b) / 2
end

function menu:predraw()
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

return menu
