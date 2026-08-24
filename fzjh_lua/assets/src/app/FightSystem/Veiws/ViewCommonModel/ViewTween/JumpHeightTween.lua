--[[
    author:Seven
    time:2023-10-31 11:04:47
    desc: 前跳插值
]]
local NewClass = require("third.class.NewClass")
local Tween = require("third.dotween.Tween")
local FightFormula = require("app.FightSystem.FightFormula")

local JumpHeightTween = {}

function JumpHeightTween:create(getter, setter, heigithestValue, duration)
    local p = self.new()
    p:init(getter, setter, heigithestValue, duration)
    return p
end

function JumpHeightTween:init(getter, setter, heigithestValue, duration)
    local beginValue = getter()

    Tween.init(
        self,
        getter,
        setter,
        function(percentage)
            return FightFormula:jumpHeight(heigithestValue, percentage)
        end,
        heigithestValue,
        duration
    )
end

return NewClass("JumpHeightTween", {Tween}, JumpHeightTween)
00