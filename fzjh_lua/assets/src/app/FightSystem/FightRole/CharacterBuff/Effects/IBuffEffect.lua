--[[
    author:Seven
    time:2023-11-28 18:04:54
    desc: buff效果接口
]]
local interface = require("third.class.interface")

local IBuffEffect = {}

function IBuffEffect:setBasicEffect(basicEffect)
end

--@desc: 获取资源id
--@author:Seven
--@time:2023-11-30 15:29:43
--@return:string
function IBuffEffect:getResouceId()
end

--@desc: 效果id
--@author:Seven
--@time:2023-11-30 14:56:37
--@return string
function IBuffEffect:getEffectId()
end

--@desc: 获取效果类型
--@author:Seven
--@time:2023-11-30 14:56:51
--@return string
function IBuffEffect:getEffectType()
end

--@desc: 设置所属buff对象
--@author:Seven
--@time:2023-11-28 18:11:03
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
function IBuffEffect:setOwningBuff(buff)
end

--@desc: 添加节点生效时调用
--@author:Seven
--@time:2023-11-28 18:12:11
function IBuffEffect:makeEffectOnAdd()
end

--@desc: 移除节点生效时调用
--@author:Seven
--@time:2023-11-28 18:26:12
function IBuffEffect:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function IBuffEffect:makeEffectOnTransfer(buffEffect)
end

--@desc: 刷新效果内部数值（根据情况自身调用）
--@author:Seven
--@time:2023-11-29 14:16:28
function IBuffEffect:updateEffectValue()
end

return interface("IbuffEffect", IBuffEffect)
0000000000000