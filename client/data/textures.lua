local textures = {
    floor = love.graphics.newImage("textures/floor.png"),
    wall  = love.graphics.newImage("textures/wall.png" ),
    metal = love.graphics.newImage("textures/metal.png"),
    glass = love.graphics.newImage("textures/glass.png"),
}
local meshSize = 30
for k, t in pairs(textures) do
    t:setWrap("repeat")
    local mesh = love.graphics.newMesh({
        {-meshSize/2, -meshSize/2, -meshSize/2, -meshSize/2},
        { meshSize/2, -meshSize/2,  meshSize/2, -meshSize/2},
        { meshSize/2,  meshSize/2,  meshSize/2,  meshSize/2},
        {-meshSize/2,  meshSize/2, -meshSize/2,  meshSize/2}
    }, "fan")
    mesh:setTexture(t)
    textures[k] = mesh
end

return textures