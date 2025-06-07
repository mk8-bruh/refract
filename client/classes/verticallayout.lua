local VerticalLayout = floof.class("VerticalLayout", Element)

VerticalLayout.align = "middle"
VerticalLayout.justify = "center"
VerticalLayout.scrollDeceleration = 250
VerticalLayout.scrollSensitivity = 5

function VerticalLayout:init(parent, items, params)
    self.parent = parent
    if params then copyData(params, self) end

    self.items = items or {}
    for i, item in ipairs(self.items) do item.parent = self end
    self.scroll = 0
    self.scrollVelocity = 0
end

function VerticalLayout:getContentWidth()
    local w = 0
    for i, item in ipairs(self.items) do
        w = math.max(w, item:getSize().x)
    end
    return w
end

function VerticalLayout:getContentHeight()
    if #self.items == 0 then return 0 end
    local space = self.align ~= "stretch" and self.align ~= "space" and self.space or 0
    local h = space * (#self.items - 1)
    for i, item in ipairs(self.items) do
        h = h + item:getSize().x
    end
    return h
end

function VerticalLayout:getContentSize()
    return vec(self:getContentWidth(), self:getContentHeight())
end

function VerticalLayout:getSize()
    return vec(self.width or self:getContentWidth(), self.height or self:getContentHeight())
end

function VerticalLayout:update(dt)
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local cw, ch = self:getContentWidth(), self:getContentHeight()

    if self.scroll <= 0 then
        self.scrollVelocity = math.max(self.scrollVelocity, 0)
    elseif self.scroll >= ch - h then
        self.scrollVelocity = math.min(self.scrollVelocity, 0)
    end
    if not self.isPressed then
        self.scroll = self.scroll + self.scrollVelocity * dt
    end
    local d = self.scrollDeceleration * dt
    self.scrollVelocity = math.abs(self.scrollVelocity) <= d and 0 or self.scrollVelocity > 0 and self.scrollVelocity - d or self.scrollVelocity + d
    self.scroll = math.min(0, math.max(ch - h, self.scroll))

    if #self.items == 1 then
        local item = self.items[1]
        local justify = item.justifySelf or self.justify
        item:setPosition(
            justify == "left" and x - w/2 + item:getSize().x/2 or
            justify == "right" and x + w/2 - item:getSize().x/2 or
            x,
            ch > h and y - h/2 + item:getSize().y/2 - self.scroll or
            self.align == "top" and y - h/2 + item:getSize().y/2 or
            self.align == "bottom" and y + h/2 - item:getSize().y/2 or
            y
        )
    elseif #self.items > 1 then
        local space = self.space or 0
        local t = y - h/2 - self.scroll
        if ch <= h then
            if self.align == "middle" then
                t = y - ch/2
            elseif self.align == "stretch" then
                space = (h - ch) / (#self.items - 1)
            elseif self.align == "space" then
                space = (h - ch) / (#self.items + 1)
                t = t + space
            end
        end
        for i, item in ipairs(self.items) do
            local iw, ih = item:getSize():unpack()
            local justify = item.justifySelf or self.justify
            item:setPosition(
                justify == "left" and x - w/2 + iw/2 or
                justify == "right" and x + w/2 - iw/2 or
                x,
                t + ih/2
            )
            if self.justify == "stretch" then
                item.width = w
            end
            t = t + ih + space
        end
    end
end

function VerticalLayout:added(object)
    table.insert(self.items, object)
end

function VerticalLayout:removed(object)
    for i, item in ipairs(self.items) do
        if item == object then
            table.remove(self.items, i)
            break
        end
    end
end

function VerticalLayout:scrolled(t)
    self.scroll = self.scroll - t * self.scrollSensitivity
    self.scrollVelocity = 0
end

function VerticalLayout:moved(x, y, dx, dy, id)
    if type(id) ~= "number" then
        self.scroll = self.scroll - dy
        self.scrollVelocity = -dy / love.timer.getDelta()
    end
    return true
end

function VerticalLayout:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", x - w/2, y - h/2, w, h)
    end, "replace", 1)
    love.graphics.setStencilTest("equal", 1)
end

return VerticalLayout