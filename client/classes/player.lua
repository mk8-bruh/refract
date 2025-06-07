local Player = floof.class("Player")

local light = require "data.light"

Player.radius = 0.25
Player.moveSpeed = 5
Player.sensitivity = 0.002
Player.lightMap = {
    r = light.red,
    g = light.green,
    b = light.blue,
    rg = light.yellow,
    gb = light.cyan,
    rb = light.magenta,
    rgb = light.white
}
Player.power = 1
Player.keybinds = {
    up = "w",
    down = "s",
    left = "a",
    right = "d",
    shoot = "mouse1",
    red = "x",
    green = "c",
    blue = "v"
}

function Player:init(world, position, direction, sensitivity, keybinds)
    self.parent = world
    self.world = world
    self.position = position or vec.zero
    self.direction = direction and direction:normal() or position ~= vec.zero and -position:normal() or vec.up
    self.radius = radius
    self.lightToggles = {red = true, green = true, blue = true}
    self.light = self.lightMap.rgb
    self.cell = nil
    for _, cell in ipairs(self.world.cells) do
        if insidePolygon(self.position, cell.vertices) then
            self.cell = cell
        end
    end
    self.sensitivity = sensitivity
    self.keybinds = setmetatable(keybinds or {}, {__index = Player.keybinds})
end

function Player:moveTo(position)
    for _, edge in ipairs(self.cell.edges) do
        if edge.wall then
            local t = self.radius + edge.wall.thickness/2
            local p = nearestPoint(position, "segment", unpack(edge))
            local d = position - p
            if d.len < t then
                position = p + d:setLen(t)
            end
        end
    end
    for _, neighbor in pairs(self.cell.neighbors) do
        for _, edge in ipairs(neighbor.edges) do
            if edge.wall then
                local t = self.radius + edge.wall.thickness/2
                local p = nearestPoint(position, "segment", unpack(edge))
                local d = position - p
                if d.len < t then
                    position = p + d:setLen(t)
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

function Player:move(delta)
    self:moveTo(self.position + delta)
end

function Player:update(dt)
    if self.isActive then
        local move_inp = vec(
            (love.keyboard.isDown(self.keybinds.right) and 1 or 0) - (love.keyboard.isDown(self.keybinds.left) and 1 or 0),
            (love.keyboard.isDown(self.keybinds.down ) and 1 or 0) - (love.keyboard.isDown(self.keybinds.up  ) and 1 or 0)
        ):rotate(self.direction.atan2 + math.pi/2)
        local delta = move_inp:setLen(self.moveSpeed * dt)
        self:move(delta)
    end
end

function Player:mousedelta(x, y)
    self.direction = self.direction:rotate(x * Player.sensitivity * (self.sensitivity or 100) / 100)
end

function Player:keypressed(key)
    if key == self.keybinds.shoot then
        if self.light then
            self.world.boltManager:shoot(self)
        end
    elseif key == self.keybinds.red then
        self.lightToggles.red = not self.lightToggles.red
    elseif key == self.keybinds.green then
        self.lightToggles.green = not self.lightToggles.green
    elseif key == self.keybinds.blue then
        self.lightToggles.blue = not self.lightToggles.blue
    end
    self.light = self.lightMap[(self.lightToggles.red and "r" or "") .. (self.lightToggles.green and "g" or "") .. (self.lightToggles.blue and "b" or "")]
end

function Player:draw()
    love.graphics.setLineWidth(0.025)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("line", self.position.x, self.position.y, self.radius)
end

return Player