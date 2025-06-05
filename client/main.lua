vec = require "libs.vec"
geo = require "libs.geo"
floof = require "libs.floof"
require "libs.serial"

function love.load(args)
    if love.filesystem.getInfo("settings.txt") then
        local settingsString = love.filesystem.read("settings.txt")
        settings = deserialize(settingsString)
    else
        settings = {
            volume = 0.5,
            brightness = 1 
        }
        love.filesystem.write("settings.txt", serialize(settings))
    end

    floof.init()

    floof.checks.default = false

    -- load classes
    classes = {
        "Element", "Title", "Button", "Label", "ColorIndicator", "BoltManager", "ParticleManager", "RayPreview", "World", "Player"
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

function love.quit()
    love.filesystem.write("settings.txt", serialize(settings))
    switchScene("Menu")
end