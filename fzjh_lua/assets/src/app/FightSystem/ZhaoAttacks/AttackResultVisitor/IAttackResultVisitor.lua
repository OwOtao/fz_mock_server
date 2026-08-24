--[[
    author:Seven
    time:2023-02-24 18:00:12
    desc: 攻击结果访问者接口
        用于访问攻击结果，根据各自需求，针对结果进行处理
]]
local interface = require("third.class.interface")

local IAttackResultVisitor = {}

--@desc: 访问没一击结果
--@author:Seven
--@time:2023-02-25 10:56:49
--@oneResult: [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function IAttackResultVisitor:visitOneAttackResult(oneAttackResult)
end

return interface("IAttackResultVisitor", IAttackResultVisitor)
000000000000000