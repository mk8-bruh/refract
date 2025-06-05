local vec = require "libs.vec"

-- table-related utilities

function merge(a, b)
    local t = {}
    for k, v in pairs(a) do t[k] = v end
    for k, v in pairs(b) do t[k] = v end
    return t
end

function filter(t, f)
    for i = #t, 1, -1 do
        if not f(t[i]) then
            table.remove(t, i)
        end
    end
end

-- graphics

function applyCameraTransform(x, y, z, r)
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(z or 1)
    love.graphics.rotate(-(r or 0))
    love.graphics.translate(-x, -y)
end

-- basic geometry

function nearestPoint(x, type, o, p)
    local v = type:match("vector") and p or (p - o)
    if v == vec.zero then return o end
    local d = x - o
    local t = v:dot(d) / v.sqrLen
    if type:match("segment") then
        t = math.max(0, math.min(1, t))
    elseif type:match("ray") then
        t = math.max(0, t)
    end
    return o + t * v
end

function intersect(type1, o1, p1, type2, o2, p2)
    local v1, v2 = type1:match("vector") and p1 or (p1 - o1), type2:match("vector") and p2 or (p2 - o2)
    local v3 = o1 - o2
    local d = v1:det(v2)
    if d == 0 then return end
    local t1 = v2:det(v3) / d
    if (type1:match("segment") and (t1 < 0 or t1 > 1)) or (type1:match("ray") and t1 < 0) then return end
    local t2 = v1:det(v3) / d
    if (type2:match("segment") and (t2 < 0 or t2 > 1)) or (type2:match("ray") and t2 < 0) then return end
    return (o1 + t1 * v1 + o2 + t2 * v2) / 2
end

function intersectCircle(type, o, p, c, r)
    local v = type:match("vector") and p or (p - o)
    if v == vec.zero then return end
    local d = c - o
    local f = math.abs(v:normal():det(d))
    if f > r then return end
    local t = v:dot(d) / v.sqrLen - math.sqrt(r^2 - f^2) / v.len
    if (type:match("segment") and (t < 0 or t > 1)) or (type:match("ray") and t < 0) then return end
    return o + t * v
end

function insidePolygon(p, poly)
    for i = 1, #poly do
        local v1, v2 = poly[i], poly[i % #poly + 1]
        if (p - v1):det(v2 - v1) > 0 then
            return false
        end
    end
    return true
end

function circumcenter(a, b, c)
    return vec(
        (a:dot(a) * (b.y - c.y) + b:dot(b) * (c.y - a.y) + c:dot(c) * (a.y - b.y)),
        (a:dot(a) * (c.x - b.x) + b:dot(b) * (a.x - c.x) + c:dot(c) * (b.x - a.x))
    ) / 2 / (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y))
end

function circumradius(a, b, c)
    local A, B, C = (b - c).len, (a - c).len, (a - b).len
    return (A * B * C) / math.sqrt((A + B + C) * (A + B - C) * (A + C - B) * (B + C - A))
end

function circumCircleContains(p, a, b, c)
    return (p - circumcenter(a, b, c)).len <= circumradius(a, b, c)
end

-- Delaunay triangulation

function triangle(a, b, c)
    if a ~= b and b ~= c and c ~= a then
        return {a, b, c, index = {[a] = 1, [b] = 2, [c] = 3}}
    end
end

function superTriangle(points)
    local min_x, min_y = math.huge, math.huge
    local max_x, max_y = -math.huge, -math.huge
    for _, p in ipairs(points) do
        if p.x < min_x then min_x = p.x end
        if p.y < min_y then min_y = p.y end
        if p.x > max_x then max_x = p.x end
        if p.y > max_y then max_y = p.y end
    end
    local dx, dy = max_x - min_x, max_y - min_y
    local delta_max = math.max(dx, dy) * 10
    return triangle(
        vec(min_x - delta_max, min_y - delta_max),
        vec(min_x + delta_max * 2, min_y - delta_max),
        vec(min_x - delta_max, min_y + delta_max * 2)
    )
end

function delaunay(points)
    local triangles, edges = {}, {}
    local super = superTriangle(points)
    table.insert(triangles, triangle(unpack(super)))
    for i, point in ipairs(points) do
        edges[point] = {}
        local oldTriangles, newEdges = {}, {}
        for j = #triangles, 1, -1 do
            if circumCircleContains(point, unpack(triangles[j])) then
                table.insert(oldTriangles, table.remove(triangles, j))
            end
        end
        for j, triangle in ipairs(oldTriangles) do
            local e = {false, false, false}
            for k, other in ipairs(oldTriangles) do
                if triangle ~= other then
                    e[1] = e[1] or (other.index[triangle[1]] and other.index[triangle[2]])
                    e[2] = e[2] or (other.index[triangle[2]] and other.index[triangle[3]])
                    e[3] = e[3] or (other.index[triangle[3]] and other.index[triangle[1]])
                end
            end
            if not e[1] then table.insert(newEdges, {triangle[1], triangle[2]}) end
            if not e[2] then table.insert(newEdges, {triangle[2], triangle[3]}) end
            if not e[3] then table.insert(newEdges, {triangle[3], triangle[1]}) end
        end
        for j, edge in ipairs(newEdges) do
            table.insert(triangles, triangle(point, unpack(edge)))
        end
    end
    for i = #triangles, 1, -1 do
        local triangle = triangles[i]
        if triangle.index[super[1]] or triangle.index[super[2]] or triangle.index[super[3]] then
            table.remove(triangles, i)
        else
            for j = 1, #triangle do
                for k = j + 1, #triangle do
                    local v1, v2 = triangle[j], triangle[k]
                    if v2.x < v1.x or (v2.x == v1.x and v2.y < v1.y) then v1, v2 = v2, v1 end
                    local edge = {v1, v2}
                    edges[v1][v2], edges[v2][v1] = edge, edge
                end
            end
        end
    end
    return triangles, edges
end

-- procedural Voronoi graph

function fractalNoise(x, y, seed, layers)   
    local v = 0
    for l = 0, (layers or 1) - 1 do
        v = v + love.math.noise((2^l + seed) * x, (2^l + seed) * y) / 2^(l+1)
    end
    return v
end

function hash(n)
    n = bit.bxor(n, bit.rshift(n, 16))
    n = bit.band(n * 0x45d9f3b, 0xFFFFFFFF)
    n = bit.bxor(n, bit.rshift(n, 16))
    n = bit.band(n * 0x45d9f3b, 0xFFFFFFFF)
    n = bit.bxor(n, bit.rshift(n, 16))
    return n
end

function hashNoise2D(seed, x, y)
    return vec(
        hash(x * 3747613932 + y * 6682652638 + seed * 921451653) / 0xFFFFFFFF,
        hash(x * 1443055738 + y * 1274126177 + seed * 362827313) / 0xFFFFFFFF
    )
end

local genRadius = 1
local offsetRange = 0.5

function generateVoronoiCell(seed, x, y)
    x, y = math.floor(x), math.floor(y)
    local cell = {
        position = vec(x, y),
        anchor = nil,
        vertices = {},
        edges = {},
        neighbors = {}
    }
    cell.anchor = vec(x, y) + ((1 - offsetRange)/2 * vec.one) + (offsetRange * hashNoise2D(seed, x, y))
    local points, cellPositions = {}, {}
    for x = x - genRadius, x + genRadius do
        for y = y - genRadius, y + genRadius do
            local p = vec(x, y) + ((1 - offsetRange)/2 * vec.one) + (offsetRange * hashNoise2D(seed, x, y))
            table.insert(points, p)
            cellPositions[p] = vec(x, y)
        end
    end
    local triangles, edges = delaunay(points)
    filter(triangles, function(triangle) return triangle.index[cell.anchor] end)
    for i, triangle in ipairs(triangles) do
        triangle.circumcenter = circumcenter(unpack(triangle))
        triangle.longtitude = (triangle.circumcenter - cell.anchor).atan2
        table.remove(triangle, triangle.index[cell.anchor])
    end
    table.sort(triangles, function(a, b) return a.longtitude < b.longtitude end)
    for i, triangle in ipairs(triangles) do
        table.insert(cell.vertices, triangle.circumcenter)
        local edge = {triangle.circumcenter, triangles[i % #triangles + 1].circumcenter}
        table.insert(cell.edges, edge)
        cell.neighbors[edge] = cellPositions[triangles[i % #triangles + 1].index[triangle[1]] and triangle[1] or triangle[2]]
    end
    return cell
end

-- map generation

function generateMap(seed, radius, minRoomCount, maxRoomCount, minRoomSize, boundaryWall, roomWall)
    local rng = love.math.newRandomGenerator(seed or os.time())

    cells = {byPosition = {}} -- { position, anchor, vertices[ index -> point ], edges[ index -> edge, neighbor -> edge ], neighbors[ edge -> neighbor ] } [ index -> cell ] byPosition[ position -> cell ]
    edges = {} -- { pointA, pointB, length, wall } [ pointA -> pointB -> edge]
    boundary = {cells = {}, edges = {}} -- cells[ index -> cell, edge -> cell ], edges[ index -> edge, cell -> array<edge>]
    rooms = {} -- { cells[ index -> cell ], edges[ index -> edge, room -> array<edge> ], neighbors[ index -> room, edge -> room ] }

    -- generate polygons
    for x = -radius, radius do
        for y = -radius, radius do
            if x^2 + y^2 <= radius^2 * 1.1 then
                local cell = generateVoronoiCell(seed, x, y)
                table.insert(cells, cell)
                cells.byPosition[cell.position] = cell
                for i, v in ipairs(cell.vertices) do
                    edges[v] = {}
                end
            end
        end
    end

    -- link neighbors
    for i, cell in ipairs(cells) do
        boundary.edges[cell] = {}
        for j, edge in ipairs(cell.edges) do
            local v1, v2 = unpack(edge)
            if v2.x < v1.x or (v2.x == v1.x and v2.y < v1.y) then v1, v2 = v2, v1 end
            local e = edges[v1][v2]
            if not e then
                e = {
                    v1, v2, length = (v1 - v2).len
                }
                table.insert(edges, e)
                edges[v1][v2], edges[v2][v1] = e, e
            end
            cell.edges[j] = e
            local n = cells.byPosition[cell.neighbors[edge]]
            cell.neighbors[edge] = nil
            if n then
                cell.neighbors[e] = n
                cell.edges[n] = e
            else
                table.insert(boundary.edges, e)
                table.insert(boundary.edges[cell], e)
                table.insert(boundary.cells, cell)
                boundary.cells[e] = cell
                e.wall = boundaryWall
            end
        end
    end

    -- initialize rooms
    local queue = {}
    for i = 1, rng:random(minRoomCount, maxRoomCount) do
        local cell, isValid
        local iterations = 0
        repeat
            cell = cells[rng:random(#cells)]
            isValid = true
            for j, room in ipairs(rooms) do
                if (room.cells[1].anchor - cell.anchor).len < minRoomSize/2 then
                    isValid = false
                    break
                end
            end
            iterations = iterations + 1
        until isValid == true or iterations > 20
        if isValid then
            local room = {cells = {cell}, edges = {}, neighbors = {}}
            cell.room = room
            table.insert(rooms, room)
            table.insert(queue, cell)
        end
    end

    -- flood fill
    while #queue > 0 do
        for i = #queue, 1, -1 do
            local cell = table.remove(queue, i)
            cell.queued = nil
            if not cell.room then
                local room, weight = nil, 0
                for r, w in pairs(cell.roomWeights) do
                    if w > weight then
                        room, weight = r, w
                    end
                end
                cell.room = room
                table.insert(room.cells, cell)
                cell.roomWeights = nil
            end
            local room = cell.room
            for edge, neighbor in pairs(cell.neighbors) do
                local other = neighbor.room
                if not other then
                    if not neighbor.queued then
                        neighbor.queued = true
                        neighbor.roomWeights = {}
                        table.insert(queue, neighbor)
                    end
                    neighbor.roomWeights[room] = (neighbor.roomWeights[room] or 0) + edge.length
                elseif other ~= room then
                    if not room.edges[other] then
                        room.edges[other] = {}
                        table.insert(room.neighbors, other)
                    end
                    if not other.edges[room] then
                        other.edges[room] = {}
                        table.insert(other.neighbors, room)
                    end
                    if not room.neighbors[edge] then
                        table.insert(room.edges, edge)
                        table.insert(room.edges[other], edge)
                        room.neighbors[edge] = other
                    end
                    if not other.neighbors[edge] then
                        table.insert(other.edges, edge)
                        table.insert(other.edges[room], edge)
                        other.neighbors[edge] = room
                    end
                    edge.wall = roomWall
                end
            end
        end
    end

    -- create doors
    for i, room in ipairs(rooms) do
        for j, other in ipairs(room.neighbors) do
            local door = nil
            for k, edge in ipairs(room.edges[other]) do
                if not door or edge.length > door.length then
                    door = edge
                end
            end
            if door then
                door.wall = nil
            end
        end
    end

    return cells, edges, boundary, rooms
end

-- ray tracing

function traceRay(cell, origin, direction, range, light, power)
    if not (cell and origin and direction and range) then return end
    direction = direction:normal()
    power = power or 1
    local r = {
        cell = cell,
        origin = origin,
        direction = direction,
        length = range,
        light = light,
        power = power,
        hit = nil,
    }
    for _, edge in ipairs(cell.edges) do
        local v1, v2 = unpack(edge)
        if (v1 - cell.anchor):det(v2 - cell.anchor) < 0 then v1, v2 = v2, v1 end
        local normal = (v2 - v1):normal()
        normal = vec(-normal.y, normal.x)
        local p = intersect("vector ray", origin, direction, "segment", v1, v2)
        if p and direction:dot(normal) < 0 then
            local d = (p - origin).len
            if not range or d < range  then
                r.length = d
                local neighbor = cell.neighbors[edge]
                if not edge.wall and not neighbor.wall then
                    r = traceRay(neighbor, origin, direction, range, light, power) or r
                    r.cell = cell
                    return r
                end
                r.hit = {
                    point = p,
                    normal = normal,
                    edge = edge,
                    cell = neighbor
                }
                local wall = cell.wall ~= edge.wall and edge.wall or neighbor and neighbor.wall
                local n1 = cell.wall and cell.wall.material.density or 1
                local n2 = wall and wall.material.density or 1
                local alpha = (-normal):signedAngle(direction)
                local refl  = normal:rotate(-alpha)
                local sin_beta = math.sin(alpha) * n1/n2
                if math.abs(sin_beta) < 1 then
                    local refr = (-normal):rotate(math.asin(sin_beta))
                    if light and wall.split and wall.split[light] then
                        if wall.split[light].refract and neighbor then
                            r.refract = traceRay(neighbor, p, refr, range - d, wall.split[light].refract, power/2)
                        end
                        if wall.split[light].reflect then
                            r.reflect = traceRay(cell,     p, refl, range - d, wall.split[light].reflect, power/2)
                        end
                    elseif wall.material.refract and neighbor then
                        r.refract = traceRay(neighbor, p, refr, range - d, light, power)
                    elseif wall.material.reflect then
                        r.reflect = traceRay(cell,     p, refl, range - d, light, power)
                    end
                else
                    r.reflect = traceRay(cell, p, refl, range - d, light, power)
                end
                return r
            end
        end
    end
    return r
end

function tracePartial(range, cell, origin, direction, light, power)
    if not (cell and origin and direction and range) then return end
    direction = direction:normal()
    power = power or 1
    local r = {
        cell = cell,
        origin = origin,
        direction = direction,
        length = range,
        light = light,
        power = power,
        hit = nil,
    }
    for _, edge in ipairs(cell.edges) do
        local v1, v2 = unpack(edge)
        if (v1 - cell.anchor):det(v2 - cell.anchor) < 0 then v1, v2 = v2, v1 end
        local normal = (v2 - v1):normal()
        normal = vec(-normal.y, normal.x)
        local p = intersect("vector ray", origin, direction, "segment", v1, v2)
        if p and direction:dot(normal) < 0 then
            local d = (p - origin).len
            if not range or d < range  then
                r.length = d
                local neighbor = cell.neighbors[edge]
                if not edge.wall and not neighbor.wall then
                    r = tracePartial(range, neighbor, origin, direction, light, power) or r
                    r.cell = cell
                    return r
                end
                r.hit = {
                    point = p,
                    normal = normal,
                    edge = edge,
                    cell = neighbor
                }
                local wall = cell.wall ~= edge.wall and edge.wall or neighbor and neighbor.wall
                local n1 = cell.wall and cell.wall.material.density or 1
                local n2 = wall and wall.material.density or 1
                local alpha = (-normal):signedAngle(direction)
                local refl  = normal:rotate(-alpha)
                local sin_beta = math.sin(alpha) * n1/n2
                if math.abs(sin_beta) < 1 then
                    local refr = (-normal):rotate(math.asin(sin_beta))
                    if light and wall.split and wall.split[light] then
                        if wall.split[light].refract and neighbor then
                            r.refract = {neighbor, p, refr, wall.split[light].refract, power/2}
                        end
                        if wall.split[light].reflect then
                            r.reflect = {cell, p, refl, wall.split[light].reflect, power/2}
                        end
                    elseif wall.material.refract and neighbor then
                        r.refract = {neighbor, p, refr, light, power}
                    elseif wall.material.reflect then
                        r.reflect = {cell, p, refl, light, power}
                    end
                else
                    r.reflect = {cell, p, refl, light, power}
                end
                return r
            end
        end
    end
    return r
end

local maxRayLength = 30
function drawRay(ray, width, from, to, opacity, overrideColor)
    opacity = opacity or 1
    from, to = from or 0, to or maxRayLength
    local len = math.min(ray.length, maxRayLength)
    if to > len then
        if ray.reflect then
            drawRay(ray.reflect, width, from - len, to - len, opacity, overrideColor)
        end
        if ray.refract then
            drawRay(ray.refract, width, from - len, to - len, opacity, overrideColor)
        end
    end
    if from < len and to > 0 and (overrideColor or ray.light) then
        from, to = math.max(math.min(from, len), 0), math.max(math.min(to, len), 0)
        local p1, p2 = ray.origin + ray.direction:setLen(from), ray.origin + ray.direction:setLen(to)
        love.graphics.push("all")
        local r, g, b = unpack(overrideColor or ray.light.color)
        love.graphics.setColor(r, g, b, opacity)
        love.graphics.circle("fill", p1.x, p1.y, width/2)
        love.graphics.circle("fill", p2.x, p2.y, width/2)
        love.graphics.setLineWidth(width)
        love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        love.graphics.pop()
    end
end

function drawPartial(ray, width, from, to, opacity, overrideColor)
    opacity = opacity or 1
    from, to = from or 0, to or maxRayLength
    local len = math.min(ray.length, maxRayLength)
    if from < len and to > 0 and (overrideColor or ray.light) then
        from, to = math.max(math.min(from, len), 0), math.max(math.min(to, len), 0)
        local p1, p2 = ray.origin + ray.direction:setLen(from), ray.origin + ray.direction:setLen(to)
        love.graphics.push("all")
        local r, g, b = unpack(overrideColor or ray.light.color)
        love.graphics.setColor(r, g, b, opacity)
        love.graphics.circle("fill", p1.x, p1.y, width/2)
        love.graphics.circle("fill", p2.x, p2.y, width/2)
        love.graphics.setLineWidth(width)
        love.graphics.line(p1.x, p1.y, p2.x, p2.y)
        love.graphics.pop()
    end
end