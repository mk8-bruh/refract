vec = require "libs.vec"
geo = require "libs.geo"
floof = require "libs.floof"

function love.load(args)
    floof.init()

    floof.checks.default = false

    -- load classes
    classes = {
        "Element", "Title", "Button", "ColorIndicator",
        "BoltManager", "ParticleManager", "RayPreview", "World", "Player"
    }
    for i, n in ipairs(classes) do
        local c = require("classes." .. n:lower())
        classes[n], _G[n], classes[i] = c, c
    end

    -- load scenes
    scenes = {
        "Menu", "Game"
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

    switchScene("Menu")
end