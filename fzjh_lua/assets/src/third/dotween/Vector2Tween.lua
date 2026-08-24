local NewClass = require("third.class.NewClass")
local Tween = require("third.dotween.Tween")

local Vector2Tween = {}

function Vector2Tween:create(getter, setter, endValue, duration)
    local p = self.new()
    p:init(getter, setter, endValue, duration)
    return p
end

function Vector2Tween:init(getter, setter, endValue, duration)
    local beginValue = getter()
    local currValue = beginValue
    Tween.init(
        self,
        getter,
        setter,
        function(percentage)
            local newValue = cc.pAdd(beginValue, cc.pMul(cc.pSub(endValue, beginValue), percentage))
            local retValue = cc.pAdd(getter(), cc.pSub(newValue, currValue))
            currValue = newValue
            return retValue
        end,
        endValue,
        duration
    )
end

return NewClass("Vector2Tween", {Tween}, Vector2Tween)
000