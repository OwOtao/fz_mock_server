--[[
    author:Seven
    time:2023-11-22 17:02:44
    desc: buff 环境相关
]]
local interface = require("third.class.interface")

local IBuffContext = {}

--@desc: 添加buff效果造成的伤害
--@author:Seven
--@time:2023-11-22 17:04:09
--@effectHurt: [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
function IBuffContext:addBuffEffectHurt(effectHurt)
end

--@desc: 遍历所有buff效果造成的伤害，返回true中断遍历，否则遍历完所有数据后返回false
--@author:Seven
--@time:2023-11-22 18:13:26
--@func: 自定义遍历方法
function IBuffContext:walkBuffEffcetHurts(func)
end

--@desc: 清空所有buff效果造成的伤害数据
--@author:Seven
--@time:2023-11-22 18:13:50
function IBuffContext:clearBuffEffectHurts()
end

--@desc: 添加一次性特效
--@author:Seven
--@time:2023-11-22 17:08:38
--@animEventName: 动画触发事件名
--@animId:特效动画id
--@ownerId: 特效目标
--@return:
function IBuffContext:addOneOffEffect(animEventName, animId, targetId)
end

--@desc: 弹出符合一次性特效数据
--@author:Seven
--@time:2023-11-22 17:13:16
--@return: array
function IBuffContext:popOneOffEffects(animEventName)
end

function IBuffContext:clearOneOffEffects()
end

--@desc: 记录添加buff的文本
--@author:Seven
--@time:2024-01-15 21:52:49
--@desc: string
function IBuffContext:recordAddBuffDesc(desc)
end

function IBuffContext:showAndClearAddBuffDesc()
end

--@desc: 记录删除buff的文本
--@author:Seven
--@time:2024-01-15 21:53:49
--@desc: string
function IBuffContext:recordDeleteDesc(desc)
end

function IBuffContext:showAndClearDeleteBuffDesc()
end

return interface("IBuffContext", IBuffContext)
00000000000000