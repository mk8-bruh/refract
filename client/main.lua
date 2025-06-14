vec = require "libs.vec"
floof = require "libs.floof"
require "libs.utils"

function love.load(args)
    -- sound library
    sounds = {
        music = {},
        sfx = {}
    }

    -- settings
    local settingsData = {
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
                local width, height = love.window.getDesktopDimensions(flags.display)
                love.window.setMode(width - 50, height - 100, {fullscreen = false, borderless = false, resizable = true})
            end
            love.resize(love.graphics.getDimensions())
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

    -- register callbacks
    floof.init()
    
    floof.checks.default = false

    -- load classes
    classes = {
        "Element", "VerticalLayout", "HorizontalLayout", "Title", "Button", "Label", "Slider", "ColorIndicator", "BoltManager", "ParticleManager", "RayPreview", "World", "Player"
    }
    for i, n in ipairs(classes) do
        local c = require("classes." .. n:lower())
        classes[n], _G[n], classes[i] = c, c
    end

    -- load scenes
    scenes = {
        "Menu", "Game", "Options"
    }
    for i, n in ipairs(scenes) do
        local s = require("scenes." .. n:lower())
        scenes[n], scenes[i] = s, s
        s.enabledSelf = false
    end

    function switchScene(scene, ...)
        if scenes[scene] then scene = scenes[scene] end
        if floof.is(scene) and scene.parent == floof.root then
            local prev = floof.root.activeChild
            if prev then
                if prev.leave then
                    prev:leave(scene)
                end
                prev.enabledSelf = false
            end
            scene.enabledSelf = true
            floof.root.activeChild = scene
            if scene.enter then
                scene:enter(prev, ...)
            end
        end
    end

    loadSettings()

    switchScene("Menu")
end

function love.quit()
    saveSettings()
end