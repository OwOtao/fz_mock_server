local interface = require("third.class.interface")

local IAnimator = {}

-- 播放状态
function IAnimator:play(stateId)
end

function IAnimator:getSpeed()
end

function IAnimator:setSpeed(speed)
end

-- 更新状态机
function IAnimator:update(ft)
end

return interface("IAnimator", IAnimator)
000