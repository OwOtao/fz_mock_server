--[[
    author:Seven
    time:2023-01-06 20:17:54
    desc: 招式结果生成工厂接口
]]
local interface = require("third.class.interface")

local IZhaoAttackFactory = {}

--@desc: 获取招式
--@author:Seven
--@time:2023-01-06 20:18:44
--@return: [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
function IZhaoAttackFactory:getZhaoAttack()
end

return interface("IZhaoAttackFactory", IZhaoAttackFactory)
0000000000000000