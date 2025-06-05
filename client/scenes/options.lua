local options = {check = true, tostring = "[options scene]"}

function options:init()
    self.title = Title(self, "OPTIONS")

    self.volumeUpButton = Button(self, "Volume +", function()
        settings.volume = math.min(1, settings.volume + 0.1)
        love.audio.setVolume(settings.volume)
        self.volumeLabel.text = string.format("Volume: %d%%", settings.volume * 100)
    end)

    self.volumeDownButton = Button(self, "Volume -", function()
        settings.volume = math.max(0, settings.volume - 0.1)
        love.audio.setVolume(settings.volume)
        self.volumeLabel.text = string.format("Volume: %d%%", settings.volume * 100)
    end)

    self.volumeLabel = Label(self, string.format("Volume: %d%%", settings.volume * 100))
    self.volumeLabel.color = {fill={0,0,0,0}, outline={0,0,0,0}, text={1,1,1}} 

    self.brightnessUpButton = Button(self, "Brightness +", function()
        settings.brightness = math.min(2, settings.brightness + 0.1)
        self.brightnessLabel.text = string.format("Brightness: %.0f%%", settings.brightness * 100)
    end)

    self.brightnessDownButton = Button(self, "Brightness -", function()
        settings.brightness = math.max(0, settings.brightness - 0.1)
        self.brightnessLabel.text = string.format("Brightness: %.0f%%", settings.brightness * 100)
    end)

    self.brightnessLabel = Label(self, string.format("Brightness: %.0f%%", settings.brightness * 100))
    self.brightnessLabel.color = {fill={0,0,0,0}, outline={0,0,0,0}, text={1,1,1}}

    self.backButton = Button(self, "Back", function()
        switchScene("Menu")
    end)

    self.displayModes = {"Fullscreen", "Windowed"}
    self.displayModeIndex = 1

    self.displayModeButton = Button(self, "Display: " .. self.displayModes[self.displayModeIndex], function()
        self.displayModeIndex = self.displayModeIndex % #self.displayModes + 1
        local mode = self.displayModes[self.displayModeIndex]
        self.displayModeButton.text = "Display: " .. mode

        if mode == "Windowed" then
            love.window.setMode(1920, 1080, {fullscreen = false, borderless = false})
        elseif mode == "Fullscreen" then
            love.window.setMode(0, 0, {fullscreen = true})
        end
    end)

    self.backgroundImage = love.graphics.newImage("textures/menu_bg.png")

    self.layout = {
        self.title,
        self.displayModeButton,
        self.brightnessLabel,
        self.brightnessUpButton,
        self.brightnessDownButton,
        self.volumeLabel,
        self.volumeUpButton,
        self.volumeDownButton,
        self.backButton
    }
    self.spacing = 20

    self:resize(love.graphics.getDimensions())
end

function options:resize(w, h)
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

function options:draw()
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

    -- Draw UI elements
    for _, element in ipairs(self.layout) do
        if element.draw then element:draw() end
    end

    -- Apply brightness overlay
    if settings.brightness < 1 then
        love.graphics.setColor(0, 0, 0, 1 - settings.brightness)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    elseif settings.brightness > 1 then
        love.graphics.setColor(1, 1, 1, settings.brightness - 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    end
    love.graphics.setColor(1, 1, 1, 1) -- Reset color
end

return floof.new(options)