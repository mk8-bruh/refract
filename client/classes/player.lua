local player = floof.class("Player")

local light = require "data.light"

player.radius = 0.25
player.moveSpeed = 5
player.sensitivity = 0.002
player.previewRange = 10
player.lightMap = {
    r = light.red,
    g = light.green,
    b = light.blue,
    rg = light.yellow,
    gb = light.cyan,
    rb = light.magenta,
    rgb = light.white
}
player.keybinds = {
    up = "w",
    down = "s",
    left = "l",
    right = "r",
    shoot = "mouse0",
    red = "x",
    green = "c",
    blue = "v"
}

function player:init(world, position, direction, keybinds)
    self.position = position or vec.zero
    self.direction = direction and direction:normal() or vec.right
    self.radius = radius
    self.lightToggles = {red = true, green = true, blue = true}
    self.light = self.lightMap.rgb
    self.ray = nil
    self.cell = nil
    for _, cell in ipairs(world.cells) do
        if insidePolygon(self.position, cell.vertices) then
            self.cell = cell
        end
    end

    self.keybinds = setmetatable(keybinds or {}, {__index = player.keybinds})
end

function player:moveTo(position)
    for _, edge in ipairs(self.cell.edges) do
        if edge.wall then
            local v1, v2 = unpack(edge)
            if (v1 - cell.anchor):det(v2 - cell.anchor) < 0 then v1, v2 = v2, v1 end
            local e = (v2 - v1):normal()
            local normal = vec(-e.y, e.x)
            if normal:dot(self.position - v1) > 0 then
                local t = self.radius + edge.wall.thickness/2
                local p = nearestPoint(position, "segment", v1, v2)
                local d = position - p
                if d.len < t then
                    position = p + d:setLen(t)
                end
            end
        end
    end
    for _, neighbor in pairs(cell.neighbors) do
        for _, edge in ipairs(neighbor.edges) do
            if edge.wall then
                 local v1, v2 = unpack(edge)
                if (v1 - cell.anchor):det(v2 - cell.anchor) < 0 then v1, v2 = v2, v1 end
                local e = (v2 - v1):normal()
                local normal = vec(-e.y, e.x)
                if normal:dot(self.position - v1) > 0 then
                    local t = self.radius + edge.wall.thickness/2
                    local p = nearestPoint(position, "segment", v1, v2)
                    local d = position - p
                    if d.len < t then
                        position = p + d:setLen(t)
                    end
                end
            end
        end
    end
    self.position = position
    if not insidePolygon(self.position, self.cell.vertices) then
        for _, neighbor in pairs(self.cell.neighbors) do
            if insidePolygon(self.position, neighbor.vertices) then
                self.cell = neighbor
                break
            end
        end
    end
end

function player:move(delta)
    self:moveTo(self.position + delta)
end

function player:update(dt)
    local move_inp = vec(
        (love.keyboard.isDown(self.keybinds.right) and 1 or 0) - (love.keyboard.isDown(self.keybinds.left) and 1 or 0),
        (love.keyboard.isDown(self.keybinds.down ) and 1 or 0) - (love.keyboard.isDown(self.keybinds.up  ) and 1 or 0)
    ):rotate(self.direction.atan2 + math.pi/2)
    local delta = move_inp:setLen(moveSpeed * dt)
    self:move(delta)
    self.ray = traceRay(self.cell, self.position, self.direction, self.previewRange, self.light)
end

function player:mousedelta(x, y)
    self.direction = self.direction:rotate(x * self.sensitivity)
end

function player:keypressed(key)
    if key == self.keybinds.shoot then
        self.world.boltManager:shoot(self)
    elseif key == self.keybinds.red then
        self.lightToggles.red = not self.lightToggles.red
        self.light = self.lightMap[(self.lightToggles.red and "r" or "") .. (self.lightToggles.green and "g" or "") .. (self.lightToggles.blue and "b" or "")]
    elseif key == "x" then
        self.lightToggles.green = not self.lightToggles.green
        self.light = self.lightMap[(self.lightToggles.red and "r" or "") .. (self.lightToggles.green and "g" or "") .. (self.lightToggles.blue and "b" or "")]
    elseif key == "c" then
        self.lightToggles.blue = not self.lightToggles.blue
        self.light = self.lightMap[(self.lightToggles.red and "r" or "") .. (self.lightToggles.green and "g" or "") .. (self.lightToggles.blue and "b" or "")]
    end
end

function player:draw()
    love.graphics.setLineWidth(0.025)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", position.x, position.y, radius)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", position.x, position.y, radius)
end

return player