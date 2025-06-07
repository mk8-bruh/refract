local HorizontalLayout = floof.class("HorizontalLayout", Element)

HorizontalLayout.align = "center"
HorizontalLayout.justify = "middle"
HorizontalLayout.scrollDeceleration = 250
HorizontalLayout.scrollSensitivity = 5

function HorizontalLayout:init(parent, items, params)
    self.parent = parent
    if params then copyData(params, self) end

    self.items = items or {}
    for i, item in ipairs(self.items) do item.parent = self end
    self.scroll = 0
    self.scrollVelocity = 0
end

function HorizontalLayout:getContentWidth()
    if #self.items == 0 then return 0 end
    local space = self.justify ~= "stretch" and self.justify ~= "space" and self.space or 0
    local w = space * (#self.items - 1)
    for i, item in ipairs(self.items) do
        w = w + item:getSize().x
    end
    return w
end

function HorizontalLayout:getContentHeight()
    local h = 0
    for i, item in ipairs(self.items) do
        h = math.max(h, item:getSize().y)
    end
    return h
end

function HorizontalLayout:getSize()
    return vec(self.width or self:getContentWidth(), self.height or self:getContentHeight())
end

function HorizontalLayout:update(dt)
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local cw, ch = self:getContentWidth(), self:getContentHeight()

    if self.scroll <= 0 then
        self.scrollVelocity = math.max(self.scrollVelocity, 0)
    elseif self.scroll >= cw - w then
        self.scrollVelocity = math.min(self.scrollVelocity, 0)
    end
    if not self.isPressed then
        self.scroll = self.scroll + self.scrollVelocity * dt
    end
    local d = self.scrollDeceleration * dt
    self.scrollVelocity = math.abs(self.scrollVelocity) <= d and 0 or self.scrollVelocity > 0 and self.scrollVelocity - d or self.scrollVelocity + d
    self.scroll = math.max(0, math.min(cw - w, self.scroll))

    if #self.items == 1 then
        local item = self.items[1]
        local justify = item.justifySelf or self.justify
        item:setPosition(
            cw > w and x - w/2 + item:getSize().x/2 - self.scroll or
            self.align == "left" and x - w/2 + item:getSize().x/2 or
            self.align == "right" and x + w/2 - item:getSize().x/2 or
            x,
            justify == "top" and y - h/2 + item:getSize().y/2 or
            justify == "bottom" and y + h/2 - item:getSize().y/2 or
            y
        )
    elseif #self.items > 1 then
        local space = self.space or 0
        local l = x - w/2 - self.scroll
        if cw <= w then
            if self.align == "center" then
                l = x - cw/2
            elseif self.align == "stretch" then
                space = (w - cw) / (#self.items - 1)
            elseif self.align == "space" then
                space = (w - cw) / (#self.items + 1)
                l = l + space
            end
        end
        for i, item in ipairs(self.items) do
            local iw, ih = item:getSize():unpack()
            local justify = item.justifySelf or self.justify
            item:setPosition(
                l + iw/2,
                justify == "top" and y - h/2 + ih/2 or
                justify == "bottom" and y + h/2 - ih/2 or
                y
            )
            if self.align == "stretch" then
                item.height = h
            end
            l = l + iw + space
        end
    end
end

function HorizontalLayout:added(object)
    table.insert(self.items, object)
end

function HorizontalLayout:removed(object)
    for i, item in ipairs(self.items) do
        if item == object then
            table.remove(self.items, i)
            break
        end
    end
end

function HorizontalLayout:scrolled(t)
    self.scroll = self.scroll + t * self.scrollSensitivity
    self.scrollVelocity = 0
end

function HorizontalLayout:moved(x, y, dx, dy, id)
    if type(id) ~= "number" then
        self.scroll = self.scroll - dx
        self.scrollVelocity = -dx / love.timer.getDelta()
    end
    return true
end

function HorizontalLayout:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", x - w/2, y - h/2, w, h)
    end, "replace", 1)
    love.graphics.setStencilTest("equal", 1)
end

return HorizontalLayout