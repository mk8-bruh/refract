local options = Element{
    width = "100%", height = "100%", inLayout = false,
    __tostring = function(self) return "[options scene]" end
}

local function SettingsSlider(parent, name, property, min, max, params)
    local div = HorizontalLayout(parent, {}, mergeData({justifyChildren = "center", alignChildren = "middle", space = 10, property = property}, params or {}))
    div.nameLabel = Label(div, name, {textAlign = "right", width = "20%", height = "100%"})
    div.slider = Slider(div, min, max, settings[property], function(self, value)
        settings[property] = value
        self.value = settings[property]
    end, {width = "60%", height = "70%"})
    div.valueLabel = Label(div, tostring(settings[property]), {textAlign = "left", width = "20%", height = "100%"})
    function div.slider:update(dt)
        div.valueLabel.text = tostring(math.floor(self.value + 0.5))
    end
    return div
end

options.title = Title(options, "OPTIONS", {inLayout = false})

options.layout = VerticalLayout(options, {}, {inLayout = false, justifyChildren = "top", alignChildren = "stretch", space = 20})

options.displayModes = {"Fullscreen", "Windowed"}
options.nextDisplayMode = {}
for i, m in ipairs(options.displayModes) do
    options.nextDisplayMode[m] = options.displayModes[i % #options.displayModes + 1]
end

Label(options.layout, "Display")
options.displayModeButton = Button(options.layout, settings.displayMode, function()
    local mode = options.nextDisplayMode[settings.displayMode]
    settings.displayMode = mode
    options.displayModeButton.text = mode
end)

Label(options.layout, "Volume")
options.volumeMasterSlider = SettingsSlider(options.layout, "Master", "volume_master", 0, 100, {h = 40})
options.volumeMusicSlider  = SettingsSlider(options.layout, "Music",  "volume_music",  0, 100, {h = 40})
options.volumeSfxSlider    = SettingsSlider(options.layout, "SFX",    "volume_sfx",    0, 100, {h = 40})

Label(options.layout, "Input")
options.sensitivitySlider = SettingsSlider(options.layout, "Sensitivity", "sensitivity", 10, 200, {h = 40})

options.backButton = Button(options, "Back", function()
    switchScene("Menu")
end, {inLayout = false})

options.backgroundImage = love.graphics.newImage("textures/menu_bg.png")

function options:enter(prev, ...)
    self.displayModeButton.text          = settings["displayMode"  ]
    self.volumeMasterSlider.slider.value = settings["volume_master"]
    self.volumeMusicSlider.slider.value  = settings["volume_music" ]
    self.volumeSfxSlider.slider.value    = settings["volume_sfx"   ]
    self.sensitivitySlider.slider.value  = settings["sensitivity"  ]

    print(settings["displayMode"], settings["volume_master"], settings["volume_music"], settings["volume_sfx"], settings["sensitivity"])
end

function options:resize(w, h)
    self.title.x, self.title.y = w/2, 30 + self.title.h/2
    self.backButton.x, self.backButton.y = w/2, h - 10 - self.backButton.h/2
    self.layout.w = w * 0.5
    self.layout.h = self.backButton.t - self.title.b - 30
    self.layout.x, self.layout.y = w/2, (self.backButton.t + self.title.b) / 2
end

function options:predraw()
    local w, h = love.graphics.getDimensions()
    local img = self.backgroundImage
    local iw, ih = img:getWidth(), img:getHeight()
    local scale = math.max(w / iw, h / ih)
    local drawW, drawH = iw * scale, ih * scale
    local offsetX, offsetY = (w - drawW) / 2, (h - drawH) / 2
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, offsetX, offsetY, 0, scale, scale)
end

return options
