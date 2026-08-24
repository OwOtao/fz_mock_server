local interface = require("third.class.interface")

local IAnimatorState = {}

-- 状态Id
function IAnimatorState:getId()
end

-- 标准化的时间
function IAnimatorState:getNormalizedTime()
end

function IAnimatorState:setNormalizedTime(normalizedTime)
end

-- 速度缩放数值
function IAnimatorState:getSpeed()
end

function IAnimatorState:setSpeed(speed)
end

-- 状态总时长, 单位秒
function IAnimatorState:getDuration()
end

-- 状态开始
function IAnimatorState:start(animator)
end

-- 状态更新
function IAnimatorState:update(animator, ft)
end

-- 状态结束
function IAnimatorState:exit(animator)
end

return interface("IAnimatorState", IAnimatorState)
0