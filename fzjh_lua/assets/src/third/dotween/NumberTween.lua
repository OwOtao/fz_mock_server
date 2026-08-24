local NewClass = require("third.class.NewClass")
local Tween = require("third.dotween.Tween")

local NumberTween = {}

function NumberTween:create(getter, setter, endValue, duration)
    local p = self.new()
    p:init(getter, setter, endValue, duration)
    return p
end

function NumberTween:init(getter, setter, endValue, duration)
    local beginValue = getter()

    Tween.init(
        self,
        getter,
        setter,
        function(percentage)
            return beginValue + (endValue - beginValue) * percentage
        end,
        endValue,
        duration
    )
end

return NewClass("NumberTween", {Tween}, NumberTween)
00000