local NewClass = require("third.class.NewClass")
local NumberTween = require("third.dotween.NumberTween")
local Vector2Tween = require("third.dotween.Vector2Tween")
local isImplement = require("third.assertIsInstance.assertIsInstance")

local DoTween = {}

function DoTween:create()
    local p = self.new()
    return p
end

function DoTween:ctor()
    self.tweens = {}
end

function DoTween:doTween(tween)
    table.insert(self.tweens, tween)
    return tween
end

--[[
    @desc: 数字插值动画
    author:TangJian
    time:2021-03-16 15:12:39
    --@getter: 数字获取方法
	--@setter: 数字设置方法
	--@endValue: 最终目标数字
	--@duration: 动画持续时间
    @return: 返回tween, 可以添加事件监听
]]
function DoTween:doNumber(getter, setter, endValue, duration)
    local tween = NumberTween:create(getter, setter, endValue, duration)
    table.insert(self.tweens, tween)
    return tween
end

--[[
    @desc: 而为向量插值
    author:TangJian
    time:2021-03-16 15:15:08
    --@getter: 获取当前二维向量
	--@setter: 设置当前二维向量
	--@endValue: 最终目标二维向量
	--@duration:  动画持续时间
    @return: 返回tween, 可以添加事件监听
]]
function DoTween:doVector2(getter, setter, endValue, duration)
    local tween = Vector2Tween:create(getter, setter, endValue, duration)
    table.insert(self.tweens, tween)
    return tween
end

-- 更新所有tween
function DoTween:update(ft)
    for i = #self.tweens, 1, -1 do
        local tween = self.tweens[i]
        if tween:needKill() then
            table.remove(self.tweens, i)
        else
            tween:update(ft)
        end
    end
end

return NewClass("DoTween", {}, DoTween)
000000000