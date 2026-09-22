vec = require "libs.vec"
floof = require "libs.floof"
Object = floof.object
Element = floof.element
require "libs.utils"

-- sound library
sounds = {
    music = {},
    sfx = {}
}

-- dispatch a resize the same way floof's main loop does: global handlers first
-- (this is what keeps the Element layout root in sync with the window), then
-- the resize callback on every object in the hierarchy
local function resized(w, h)
    Object.invokeHandlers("resize", w, h)
    Object:broadcastAll("resize", w, h)
end

-- settings
local defaultSettings = {
    volume = {
        master = 50,
        music = 100,
        sfx = 100
    },
    displayMode = "Fullscreen",
    sensitivity = 100,
    keybinds = {
        up = "w",
        down = "s",
        left = "a",
        right = "d",
        shoot = "mouse1",
        red = "x",
        green = "c",
        blue = "v"
    }
}
local settingsData = copyData(defaultSettings, {})
local changeCallbacks = {
    volume_master = function(value)
        value = math.max(0, math.min(100, value))
        settingsData.volume.master = value
        love.audio.setVolume(value / 100)
    end,
    volume_music = function(value)
        value = math.max(0, math.min(100, value))
        settingsData.volume.music = value
        for i, track in ipairs(sounds.music) do
            track:setVolume(value / 100)
        end
    end,
    volume_sfx = function(value)
        value = math.max(0, math.min(100, value))
        settingsData.volume.sfx = value
        for i, track in ipairs(sounds.sfx) do
            track:setVolume(value / 100)
        end
    end,
    displayMode = function(value)
        if value == "Fullscreen" then
            settingsData.displayMode = value
            love.window.setMode(0, 0, {fullscreen = true})
        elseif value == "Windowed" then
            settingsData.displayMode = value
            local _, _, flags = love.window.getMode()
            local width, height = love.window.getDesktopDimensions(flags.displayindex)
            love.window.setMode(width - 50, height - 100, {fullscreen = false, borderless = false, resizable = true})
        end
        resized(love.graphics.getDimensions())
    end,
    sensitivity = function(value)
        value = math.max(10, math.min(200, value))
        settingsData.sensitivity = value
    end
}
settings = setmetatable({}, {
    __index = function(t, k)
        t = settingsData
        while k:match("_") do
            local k1, k2 = k:match("^(.-)_(.-)$")
            t, k = t[k1], k2
        end
        return t[k]
    end,
    __newindex = function(t, k, v)
        if changeCallbacks[k] then
            changeCallbacks[k](v)
        else
            t = settingsData
            while k:match("_") do
                local k1, k2 = k:match("^(.-)_(.-)$")
                t, k = t[k1], k2
            end
            t[k] = v
        end
    end
})

local defaultSettingsLocation = "settings.txt"
function resetSettings()
    copyData(defaultSettings, settingsData)
    for k, f in pairs(changeCallbacks) do
        f(settings[k])
    end
end
function loadSettings(fn)
    fn = fn or defaultSettingsLocation
    if love.filesystem.getInfo(fn) then
        local str = love.filesystem.read(fn)
        local data = deserialize(str)
        for k, v in pairs(data) do
            settingsData[k] = v
        end
        for k, f in pairs(changeCallbacks) do
            f(settings[k])
        end
    end
end
function saveSettings(fn)
    fn = fn or defaultSettingsLocation
    love.filesystem.write(fn, serialize(settingsData))
end

-- load classes
classes = {
    "VerticalLayout", "HorizontalLayout", "Title", "Button", "Label", "Slider", "ColorIndicator", "BoltManager", "ParticleManager", "RayPreview", "World", "Player"
}
for i, n in ipairs(classes) do
    local c = require("classes." .. n:lower())
    classes[n], _G[n], classes[i] = c, c, nil
end

-- load scenes
scenes = {
    "Menu", "Game", "Options"
}
for i, n in ipairs(scenes) do
    local s = require("scenes." .. n:lower())
    s.activeSelf = false
    scenes[n], scenes[i] = s, s
end

local currentScene = nil
function switchScene(scene, ...)
    if scenes[scene] then scene = scenes[scene] end
    if floof.instanceOf(scene, Object) and scene ~= currentScene then
        local previous = currentScene
        if previous then
            if floof.isCallable(previous.leave) then previous:leave(scene) end
            previous.activeSelf = false
        end
        currentScene = scene
        scene.activeSelf = true
        if floof.isCallable(scene.enter) then scene:enter(previous, ...) end
    end
end

function love.quit()
    saveSettings()
end

resetSettings()
loadSettings()
switchScene("Menu")

Object.initialize(arg)
