local HorizontalLayout = Element:class("HorizontalLayout")

HorizontalLayout.scrollDeceleration = 250
HorizontalLayout.scrollSensitivity = 5

function HorizontalLayout:__init(parent, items, params)
    self.super.__init(self, mergeData({parent = parent}, params or {}), unpack(items or {}))
end

function HorizontalLayout:constructed()
    self.layoutDirection = "row"
    self.scrollVelocity = 0
end

function HorizontalLayout:update(dt)
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

function HorizontalLayout:scrolled(dx, dy)
    self.scroll = self.scroll - dy * self.scrollSensitivity
    self.scrollVelocity = 0
end

function HorizontalLayout:dragged(x, y, dx, dy, press, isTouch)
    if isTouch then
        self.scroll = self.scroll + dx
        self.scrollVelocity = dx / love.timer.getDelta()
    end
    return true
end

return HorizontalLayout
