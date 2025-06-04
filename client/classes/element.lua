local element = floof.class("Element")

function element:init(parent, anchor, origin)
    self.parent = parent
    self.anchor = anchor
    self.origin = origin
end

function element:getPosition()
    if self.anchor then
        local x, y, w, h = self.anchor:unpack()
        if self.size then
            w, h = self.size:unpack()
        elseif self.getSize then
            w, h = self:getSize():unpack()
        end
        if w and h and self.origin then
            if self.origin:match("left"  ) then x = x + w/2 end
            if self.origin:match("right" ) then x = x - w/2 end
            if self.origin:match("top"   ) then y = y + h/2 end
            if self.origin:match("bottom") then y = y - h/2 end
        end
        return vec(x, y)
    end
end

function element:setPosition(pos)
    local x, y = pos:unpack()
    if self.size then
        w, h = self.size:unpack()
    elseif self.getSize then
        w, h = self:getSize():unpack()
    end
    if w and h and self.origin then
        if self.origin:match("left"  ) then x = x - w/2 end
        if self.origin:match("right" ) then x = x + w/2 end
        if self.origin:match("top"   ) then y = y - h/2 end
        if self.origin:match("bottom") then y = y + h/2 end
    end
    if self.anchor then
        self.anchor = vec(x, y)
    else
        self.position = vec(x, y)
    end
end

function element:getSize()
    return vec(self.font:getWidth(self.text), self.font:getHeight())
end

return element