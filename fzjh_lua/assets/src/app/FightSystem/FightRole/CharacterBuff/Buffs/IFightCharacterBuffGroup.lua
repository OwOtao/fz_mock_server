--[[
    author:Seven
    time:2023-12-02 15:54:45
    desc:
]]
local interface = require("third.class.interface")
local IFightCharacterBuffGroup = {}

--@desc: 获取拥有者
--@author:Seven
--@time:2023-12-02 15:56:45
--@owner: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IFightCharacterBuffGroup:setOwner(owner)
end

--@desc: 获取当前buff组拥有者
--@author:Seven
--@time:2023-12-03 17:12:44
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IFightCharacterBuffGroup:getOwner()
end

--@desc: 获取buff ID
--@author:Seven
--@time:2023-12-02 16:03:15
function IFightCharacterBuffGroup:getBuffId()
end

--@desc: 获取Buff类型
--@author:Seven
--@time:2023-12-02 16:02:49
--@return: number
function IFightCharacterBuffGroup:getBuffClass()
end

--@desc: 添加buff
--@author:Seven
--@time:2023-12-02 16:02:32
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function IFightCharacterBuffGroup:addBuffToGroup(buff)
end

--@desc: 根据buff索引删除
--@author:Seven
--@time:2023-12-02 16:02:15
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
function IFightCharacterBuffGroup:removeBuffFromGroup(buff)
end

--@desc: 获取当前buffid的所有buffindex列表
--@author:Seven
--@time:2023-12-02 15:59:53
--@return: buff index list
function IFightCharacterBuffGroup:getBuffIndexs()
end

--@desc: 获取当前buffid的数量
--@author:Seven
--@time:2023-12-02 15:59:33
--@return number
function IFightCharacterBuffGroup:getBuffCount()
end

--@desc: 设置当前buff的最大上限值
--@author:Seven
--@time:2023-12-02 16:10:22
--@value: number
function IFightCharacterBuffGroup:setBuffStackMax(value)
end

--@desc: 获取当前buff组的最大上限
--@author:Seven
--@time:2023-12-02 16:10:46
function IFightCharacterBuffGroup:getBuffStackMax()
end

return interface("IFightCharacterBuffGroup", IFightCharacterBuffGroup)
00000