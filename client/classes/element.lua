local Element = floof.class("Element")

Element.origin = "middle center"

function Element:init(parent, anchor, origin)
    self.parent = parent
    self.anchor = anchor
    self.origin = origin
end

function Element:getPosition()
    local x, y = (self.anchor or vec.zero):unpack()
    local w, h = self:getSize():unpack()
    return vec(
        self.origin:match("left") and x + w/2 or self.origin:match("center") and x or self.origin:match("right" ) and x - w/2,
        self.origin:match("top" ) and y + h/2 or self.origin:match("middle") and y or self.origin:match("bottom") and y - h/2
    )
end

function Element:setPosition(x, y)
    local w, h = self:getSize():unpack()
    self.anchor = vec(
        self.origin:match("left") and x - w/2 or self.origin:match("center") and x or self.origin:match("right" ) and x + w/2,
        self.origin:match("top" ) and y - h/2 or self.origin:match("middle") and y or self.origin:match("bottom") and y + h/2
    )
end

function Element:getSize()
    return vec(self.width or self.getContentWidth and self:getContentWidth() or 0, self.height or self.getContentHeight and self:getContentHeight() or 0)
end

function Element:getLeft()
    return self:getPosition().x - self:getSize().x/2
end
function Element:getRight()
    return self:getPosition().x + self:getSize().x/2
end
function Element:getTop()
    return self:getPosition().y - self:getSize().y/2
end
function Element:getBottom()
    return self:getPosition().y + self:getSize().y/2
end

function Element:check(px, py)
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    return math.abs(px - x) <= w/2 and math.abs(py - y) <= h/2
end

return Element