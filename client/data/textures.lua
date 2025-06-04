local textures = {
    floor = love.graphics.newImage("floor.png"),
    wall  = love.graphics.newImage("wall.png" ),
    metal = love.graphics.newImage("metal.png"),
    glass = love.graphics.newImage("glass.png"),
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