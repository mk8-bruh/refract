local World = floof.class("World")

local walls = require "data.walls"
local textures = require "data.textures"

World.viewSize = 15
World.viewOffset = 4

World.minRoomCount = 8
World.maxRoomCount = 12
World.minRoomSize = 10
World.boundaryWall = walls[1]
World.roomWall = walls[1]

World.backgroundImage = love.graphics.newImage("textures/background.png")
World.backgroundScale = 0.02

World.groundTexture = textures.floor

function World:init(parent, size, seed)
    self.parent = parent
    self.particleManager = ParticleManager(self)
    self.rayPreview = RayPreview(self)
    self.boltManager = BoltManager(self)

    self.players = {}

    self.size = size
    self.seed = seed or os.time()
    self.cells, self.edges, self.boundary, self.rooms = generateMap(self.seed, self.size/2, self.minRoomCount, self.maxRoomCount, self.minRoomSize, self.boundaryWall, self.roomWall)
end

function World:added(object)
    if object:is(ParticleManager) then
        object.z = 1
    elseif object:is(RayPreview) then
        object.z = 2
    elseif object:is(BoltManager) then
        object.z = 3
    elseif object:is(Player) then
        object.z = 4
        table.insert(self.players, object)
    end
end

function World:removed(object)
    if object:is(Player) then
        for i, player in ipairs(self.players) do
            if player == object then
                table.remove(self.players, i)
                break
            end
        end
        if self.tracking == object then
            self.tracking = nil
        end
    end
end

function World:predraw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    if self.tracking then
        applyCameraTransform(
            self.tracking.position.x + self.tracking.direction.x * self.viewOffset,
            self.tracking.position.y + self.tracking.direction.y * self.viewOffset,
            h / self.viewSize,
            self.tracking.direction.atan2 + math.pi/2
        )
    else
        local min, max
        for i, player in ipairs(self.players) do
            if not min then
                min, max = player.position, player.position
            else
                min, max =
                    vec(math.min(min.x, player.position.x), math.min(min.y, player.position.y)),
                    vec(math.max(max.x, player.position.x), math.max(max.y, player.position.y))
            end
        end
        local center = (min + max) / 2
        local zoom = math.min(h/self.viewSize, (vec(w, h) / (max - min + vec.one)):unpack())
        applyCameraTransform(center.x, center.y, zoom, 0)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.backgroundImage, 0, 0, 0, self.backgroundScale, self.backgroundScale, self.backgroundImage:getWidth()/2, self.backgroundImage:getHeight()/2)

    love.graphics.stencil(function()
        for _, cell in ipairs(self.cells) do
            love.graphics.polygon("fill", vec.flattenArray(cell.vertices))
        end
    end)
    love.graphics.setStencilTest("equal", 1)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.draw(self.groundTexture, 0, 0, 0, 2, 2)
    love.graphics.setStencilTest()
end

function World:postdraw()
    for _, cell in pairs(self.cells) do
        if cell.wall then
            love.graphics.stencil(function()
                love.graphics.polygon(vec.flattenArray(cell.vertices))
            end, "replace", cell.wall.mask, true)
        end
    end
    for _, edge in ipairs(self.edges) do
        if edge.wall then
            love.graphics.stencil(function()
                love.graphics.setLineWidth(edge.wall.thickness)
                love.graphics.line(vec.flattenArray(edge))
                love.graphics.circle("fill", edge[1].x, edge[1].y, edge.wall.thickness/2)
                love.graphics.circle("fill", edge[2].x, edge[2].y, edge.wall.thickness/2)
            end, "replace", edge.wall.mask, true)
        end
    end
    for i, w in ipairs(walls) do
        love.graphics.setStencilTest("equal", w.mask)
        love.graphics.setColor(w.tint)
        love.graphics.draw(w.texture)
    end
end

return World