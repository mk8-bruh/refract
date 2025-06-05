local element = floof.class("Element")

element.origin = "middle center"

function element:init(parent, anchor, origin)
    self.parent = parent
    self.anchor = anchor
    self.origin = origin
end

function element:getPosition()
    if self.anchor then
        local x, y = self.anchor:unpack()
        local w, h = self:getSize():unpack()
        return vec(
            self.origin:match("left") and x + w/2 or self.origin:match("center") and x or self.origin:match("right" ) and x - w/2,
            self.origin:match("top" ) and y + h/2 or self.origin:match("middle") and y or self.origin:match("bottom") and y - h/2
        )
    end
end

function element:getSize()
    return self.size
end

function element:check(px, py)
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    if x and y and w and h then
        return math.abs(px - x) <= w/2 and math.abs(py - y) <= h/2
    end
end

return element