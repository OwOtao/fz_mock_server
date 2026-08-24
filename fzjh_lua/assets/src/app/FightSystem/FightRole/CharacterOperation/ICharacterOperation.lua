--[[
    author:Seven
    time:2023-12-07 20:36:33
    desc: 角色操作
]]
local interface = require("third.class.interface")

local ICharacterOperation = {}

--@desc: 设置操作类型
--@author:Seven
--@time:2023-12-08 16:13:15
--@co_type: [src.app.FightSystem.FightCommons#FightCommons.CHARACTER_OPERATION_TYPE]
function ICharacterOperation:setCharacterOperationType(co_type)
end

--@desc: 获取角色操作类型
--@author:Seven
--@time:2023-12-08 16:10:05
--@return [src.app.FightSystem.FightCommons#FightCommons.CHARACTER_OPERATION_TYPE]
function ICharacterOperation:getCharacterOperationType()
end

--@desc: 设置操作拥有者
--@author:Seven
--@time:2023-12-07 20:50:15
--@owner: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ICharacterOperation:setOperationOwenr(owner)
end

--@desc: 获取操作拥有者
--@author:Seven
--@time:2023-12-08 16:02:11
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function ICharacterOperation:getOwner()
end

--@desc: 设置操作id
--@author:Seven
--@time:2023-12-07 21:14:28
--@id: string
function ICharacterOperation:setOperationId(id)
end

--@desc: 获取id
--@author:Seven
--@time:2023-12-07 21:14:38
function ICharacterOperation:getOperationId()
end

--@desc: 操作名称
--@author:Seven
--@time:2023-12-07 21:13:05
--@name: string
function ICharacterOperation:setOperationName(name)
end

--@desc: 获取操作名称
--@author:Seven
--@time:2023-12-07 21:13:28
--@return: string
function ICharacterOperation:getOperationName()
end

--@desc: 操作CD最大值
--@author:Seven
--@time:2023-12-07 20:37:26
--@maxValue: number
function ICharacterOperation:setCdMax(maxValue)
end

--@desc: 获取该操作最大值
--@author:Seven
--@time:2023-12-07 20:38:02
--@return: number
function ICharacterOperation:getCdMax()
end

--@desc: 设置当前CD值
--@author:Seven
--@time:2023-12-07 20:38:17
--@cdValue: cd值
function ICharacterOperation:setCd(cdValue)
end

--@desc: 获取当前CD值
--@return: number
function ICharacterOperation:getCd()
end

--@desc: 设置是否禁用
--@author:Seven
--@time:2023-12-07 20:56:14
--@bool: boolean
function ICharacterOperation:setDisable(bool)
end

--@desc: 是否禁用操作行为
--@author:Seven
--@time:2023-12-07 20:55:51
--@return: boolean
function ICharacterOperation:isDisable()
end

--@desc: 是否可以执行操作
--@author:Seven
--@time:2023-12-20 11:26:39
--@return: true | false
function ICharacterOperation:canDoOperation()
end

--@desc: 操作的执行
--@author:Seven
--@time:2023-12-07 21:18:45
function ICharacterOperation:doOperation()
end

return interface("ICharacterOperation", ICharacterOperation)
00000000000000