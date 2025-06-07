local options = {check = true, tostring = "[options scene]"}

local function SettingsSlider(parent, name, property, min, max, params)
    local div = HorizontalLayout(parent, {}, {align = "center", space = 10, justify = "middle", property = property})
    local nameLabel = Label(div, name, {align = "right"})
    local slider = Slider(div, min, max, settings[property], function(self, value)
        settings[property] = value
        self.value = settings[property]
    end)
    local valueLabel = Label(div, tostring(settings[property]), {align = "left"})
    function slider:update(dt)
        valueLabel.text = tostring(math.floor(self.value + 0.5))
    end
    function div:update(dt)
        self.class.update(self, dt)

        nameLabel.width = self.width * 0.2
        slider.width = self.width * 0.6
        valueLabel.width = self.width * 0.2

        nameLabel.height = self.height
        slider.height = self.height * 0.7
        valueLabel.height = self.height
    end
    if params then copyData(params, div) end
    return div
end

function options:init()
    self.title = Title(self, "OPTIONS", {origin = "top center"})

    self.layout = VerticalLayout(self, {}, {width = 500, origin = "top center", align = "top", justify = "stretch", space = 20})

    self.displayModes = {"Fullscreen", "Windowed"}
    self.nextDisplayMode = {}
    for i, m in ipairs(self.displayModes) do
        self.nextDisplayMode[m] = self.displayModes[i % #self.displayModes + 1]
    end

    Label(self.layout, "Display")
    self.displayModeButton = Button(self.layout, settings.displayMode, function()
        local mode = self.nextDisplayMode[settings.displayMode]
        settings.displayMode = mode
        self.displayModeButton.text = mode
    end)

    Label(self.layout, "Volume")
    self.volumeMasterSlider = SettingsSlider(self.layout, "Master", "volume_master", 0, 100, {width = 500, height = 40})
    self.volumeMasterSlider = SettingsSlider(self.layout, "Music",  "volume_music",  0, 100, {width = 500, height = 40})
    self.volumeMasterSlider = SettingsSlider(self.layout, "SFX",    "volume_sfx",    0, 100, {width = 500, height = 40})

    Label(self.layout, "Input")
    self.sensitivitySlider = SettingsSlider(self.layout, "Sensitivity", "sensitivity", 10, 200, {width = 500, height = 40})

    self.backButton = Button(self, "Back", function()
        switchScene("Menu")
    end, {origin = "bottom center"})

    self.backgroundImage = love.graphics.newImage("textures/menu_bg.png")

    self:resize(love.graphics.getDimensions())
end

function options:enter(prev, ...)
    self.displayModeButton.text = settings["displayMode"]
    self.volumeMasterSlider.value = settings["volume_master"]
    self.sensitivitySlider.value = settings["sensitivity"]
end

function options:resize(w, h)
    self.title.anchor = vec(w/2, 30)
    self.backButton.anchor = vec(w/2, h - 10)
    self.layout.width = w * 0.5
    self.layout.height = self.backButton:getTop() - self.title:getBottom() - 30
    self.layout:setPosition(w/2, (self.backButton:getTop() + self.title:getBottom()) / 2)
end

function options:draw()
    local w, h = love.graphics.getDimensions()
    local img = self.backgroundImage
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = math.max(w / iw, h / ih)
    local drawW, drawH = iw * scale, ih * scale
    local offsetX, offsetY = (w - drawW) / 2, (h - drawH) / 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, offsetX, offsetY, 0, scale, scale)
end

return floof.new(options)