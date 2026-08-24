local interface = require("third.class.interface")

local IZhaoAttack = {}

function IZhaoAttack:getHurtType()
end

--@desc: 该攻击占用时间
--@author:Seven
--@time:2021-07-13 15:40:42
function IZhaoAttack:getDuration()
end

--@desc: 执行攻击
--@author:Seven
--@time:2021-07-13 15:40:52
function IZhaoAttack:doAttack(attacker, target)
end

function IZhaoAttack:getAllQiDamageHurts()
end

function IZhaoAttack:getAllOneAttackHit()
end

function IZhaoAttack:getAllTargetOneAttackHit()
end

function IZhaoAttack:getAllAttackerOneAttackHit()
end

return interface("IZhaoAttack", IZhaoAttack)
0000000000