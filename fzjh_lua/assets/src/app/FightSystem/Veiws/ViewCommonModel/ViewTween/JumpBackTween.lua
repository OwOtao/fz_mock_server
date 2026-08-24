--[[
    author:Seven
    time:2023-10-31 11:04:47
    desc: 后跳插值
]]
local NewClass = require("third.class.NewClass")
local Tween = require("third.dotween.Tween")
local FightFormula = require("app.FightSystem.FightFormula")

local JumpBackTween = {}

function JumpBackTween:create(getter, setter, endValue, duration)
    local p = self.new()
    p:init(getter, setter, endValue, duration)
    return p
end

function JumpBackTween:init(getter, setter, endValue, duration)
    local beginValue = getter()

    Tween.init(
        self,
        getter,
        setter,
        function(percentage)
            return FightFormula:jumpBackward(beginValue, endValue, percentage)
        end,
        endValue,
        duration
    )
end

return NewClass("JumpBackTween", {Tween}, JumpBackTween)
0