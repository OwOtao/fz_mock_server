--[[
    author:Seven
    time:2023-11-28 20:03:30
    desc: buff 接口
]]
local interface = require("third.class.interface")

local IFightCharacterBuff = {}

--@desc: 设置buff上下文对象
--@author:Seven
--@time:2023-11-28 20:07:36
--@IBuffContext: [src.app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext#IBuffContext]
function IFightCharacterBuff:setBuffContext(IBuffContext)
end

--@desc: 获取buff上下文对象
--@author:Seven
--@time:2023-11-28 21:01:35
--@return [src.app.FightSystem.FightRole.CharacterBuff.BuffContext.IBuffContext#IBuffContext]
function IFightCharacterBuff:getBuffContext()
end

--@desc: 设置buff所属角色对象
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IFightCharacterBuff:setOwner(character)
end

--@desc: 获取buff拥有者
--@author:Seven
--@time:2023-11-29 15:13:55
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IFightCharacterBuff:getBuffOwner()
end

--@desc: 设置buff创建者（即施放者）
--@author:Seven
--@time:2023-11-28 20:04:44
--@buffCreator: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IFightCharacterBuff:setBuffCreator(buffCreator)
end

--@desc: 获取buff创建者（即施放者）
--@author:Seven
--@time:2023-11-29 15:14:51
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IFightCharacterBuff:getBuffCreator()
end

--@desc: 获取当前buff的onlyid
--@author:Seven
--@time:2023-11-28 20:11:34
function IFightCharacterBuff:getId()
end

--@desc: 设置一个onlyid
--@author:Seven
--@time:2023-11-30 12:08:45
--@id: number
function IFightCharacterBuff:setId(id)
end

--@desc: 获取当前buff的buffClass类型
--@author:Seven
--@time:2023-11-28 20:12:16
function IFightCharacterBuff:getBuffClass()
end

--@desc: 获取buff的id
--@author:Seven
--@time:2023-11-28 20:47:19
function IFightCharacterBuff:getBuffId()
end

--@desc: 获取删除文本
--@author:Seven
--@time:2024-01-15 21:36:49
--@return: string
function IFightCharacterBuff:getDeleteBuffDesc()
end

--@desc: 获取添加buff文本
--@author:Seven
--@time:2023-11-29 20:27:28
--@return: string
function IFightCharacterBuff:getAddBuffDesc()
end

--@desc: 获取叠加类型
--@author:Seven
--@time:2023-11-28 20:11:04
function IFightCharacterBuff:getStackType()
end

--@desc: 获取叠加上限最大值 < 0 代表无上限或该叠加类型无需判断上限
--@author:Seven
--@time:2023-03-13 16:26:33
function IFightCharacterBuff:getStackTimesMax()
end

--@desc: 添加动态参数
--@author:Seven
--@time:2023-03-06 20:14:24
--@argName: 动态参数属性名
--@value: 动态参数值
function IFightCharacterBuff:setBuffDynamicArg(argName, value)
end

--@desc: 获取动态参数
--@author:Seven
--@time:2023-11-28 20:10:50
--@argName: 动态参数属性名
function IFightCharacterBuff:getBuffDynamicArg(argName)
end

--@desc: 获取buff所携带的图标
--@author:Seven
--@time:2023-03-15 15:18:17
function IFightCharacterBuff:getBuffIcon()
end

--@desc: 设置buff的存活次数
--@author:Seven
--@time:2023-11-28 20:48:31
--@value: number
function IFightCharacterBuff:setBuffLives(value)
end

--@desc: 获取buff存活次数
--@author:Seven
--@time:2023-11-28 20:47:58
--@return:number
function IFightCharacterBuff:getBuffLives()
end

--@desc: 是否可以删除
--@author:Seven
--@time:2023-11-28 20:49:45
--@return: true | false
function IFightCharacterBuff:isRemovable()
end

--@desc: 把自己标记为删除状态
--@author:Seven
--@time:2023-11-28 20:52:15
function IFightCharacterBuff:removeSelf()
end

--@desc: 是否已删除
--@author:Seven
--@time:2023-11-29 20:26:49
--@return: true | false
function IFightCharacterBuff:isRemove()
end

--@desc: 添加生效时调用
--@author:Seven
--@time:2023-11-28 20:54:23
function IFightCharacterBuff:makeBuffEffectOnAdd()
end

--@desc: 删除生效时调用
--@author:Seven
--@time:2023-11-28 20:54:52
function IFightCharacterBuff:makeBuffEffectOnRemove()
end

--@desc: buff 被转移时调用
--@author:Seven
--@time:2023-11-28 21:00:26
--@newOwner: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@return [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function IFightCharacterBuff:makeBuffEffectOnTransfer(newOwner)
end

--@desc: buff 生效时调用（根据生效节点类型调用)
--@author:Seven
--@time:2023-11-29 20:33:00
--@makeEffectOnNode:
--@args: table 参数列表
function IFightCharacterBuff:buffMakeEffectOnNode(makeEffectOnNode, args)
end

--@desc: 注册buff效果生效节点监听器
--@author:Seven
--@time:2023-11-29 17:58:14
--@effectNode: [src.app.FightSystem.FightBuff.Constants#Constants.BUFF_MAKE_EFFECT_ON_NODE_TYPE]
--@listerner: function
function IFightCharacterBuff:registerMakeEffectListener(effectNode, listerner)
end

--@desc: buff效果迭代器
--@author:Seven
--@time:2023-12-03 20:02:32
--@return: function
function IFightCharacterBuff:getEffectIterator()
end

--@desc: 根据效果顺序索引查找效果
--@author:Seven
--@time:2023-12-03 20:14:49
--@index: number
function IFightCharacterBuff:getEffectByOrderIndex(index)
end

--@desc: 获取buff携带的护盾
--@author:Seven
--@time:2024-01-02 15:30:13
--@return animId:string , priority:number
function IFightCharacterBuff:getShieldAnimAndPriority()
end

--@desc: 获取buff的buffEffectClass
function IFightCharacterBuff:getEffectClass()
end

return interface("IFightCharacterBuff", IFightCharacterBuff)
00000