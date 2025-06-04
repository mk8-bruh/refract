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

    -- universal checking function
    function floof.checks.default(self, x, y)
        local ox, oy, ow, oh
        if self.position then
            ox, oy = self.position:unpack()
        elseif self.getPosition then
            ox, oy = self:getPosition():unpack()
        end
        if self.size then
            ow, oh = self.size:unpack()
        elseif self.getSize then
            ow, oh = self:getSize():unpack()
        end
        if self.origin then
            if self.origin:match("left"  ) then ox = ox + ow/2 end
            if self.origin:match("right" ) then ox = ox - ow/2 end
            if self.origin:match("top"   ) then oy = oy + oh/2 end
            if self.origin:match("bottom") then oy = oy - oh/2 end
        end
        if ox and oy and ow and oh then
            return math.abs(x - ox) <= ow/2 and math.abs(y - oy) <= oh/2
        end
    end

    -- load classes
    classes = {
        "Element", "Title", "Button", "ColorIndicator",
        "Player", "BoltManager", "ParticleManager", "Label"
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

    function SwitchScene(scene, ...)
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

    SwitchScene("Menu")
end

function love.quit()
    love.filesystem.write("settings.txt", serialize(settings))
end