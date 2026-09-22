local VerticalLayout = Element:class("VerticalLayout")

VerticalLayout.scrollDeceleration = 250
VerticalLayout.scrollSensitivity = 5

function VerticalLayout:__init(parent, items, params)
    self.super.__init(self, mergeData({parent = parent}, params or {}), unpack(items or {}))
end

function VerticalLayout:constructed()
    self.scrollVelocity = 0
end

function VerticalLayout:update(dt)
    if self.scrollVelocity ~= 0 then
        if not self.isPressed then
            local previous = self.scroll
            self.scroll = previous + self.scrollVelocity * dt
            if self.scroll == previous then self.scrollVelocity = 0 end
        end
        local d = self.scrollDeceleration * dt
        self.scrollVelocity = math.abs(self.scrollVelocity) <= d and 0 or self.scrollVelocity > 0 and self.scrollVelocity - d or self.scrollVelocity + d
    end
end

function VerticalLayout:scrolled(dx, dy)
    self.scroll = self.scroll + dy * self.scrollSensitivity
    self.scrollVelocity = 0
end

function VerticalLayout:dragged(x, y, dx, dy, press, isTouch)
    if isTouch then
        self.scroll = self.scroll + dy
        self.scrollVelocity = dy / love.timer.getDelta()
    end
    return true
end

return VerticalLayout
