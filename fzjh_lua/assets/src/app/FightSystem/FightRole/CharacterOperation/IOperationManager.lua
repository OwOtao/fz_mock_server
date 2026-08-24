--[[
    author:Seven
    time:2023-12-08 11:10:00
    desc: 角色操作管理接口类
]]
local interface = require("third.class.interface")

local IOperationManager = {}

--@desc: 注册玩家操作
--@author:Seven
--@time:2023-12-08 11:17:21
--@index: 注册插槽位置
--@operation: [src.app.FightSystem.FightRole.CharacterOperation.ICharacterOperation#ICharacterOperation]
function IOperationManager:registerOperation(index, characterOperation)
end

--@desc: 删除玩家操作
--@author:Seven
--@time:2023-12-08 11:19:33
--@index: 取消注册位置
--@return [src.app.FightSystem.FightRole.CharacterOperation.ICharacterOperation#ICharacterOperation]
function IOperationManager:unregisterOperation(index)
end

--@desc: 获取操作插槽位置操作对象
--@author:Seven
--@time:2023-12-08 11:41:56
--@index: 操作插槽索引
--@return [src.app.FightSystem.FightRole.CharacterOperation.ICharacterOperation#ICharacterOperation]
function IOperationManager:getOperation(index)
end

function IOperationManager:getOperationById(operationId)
end

return interface("IOperationManager", IOperationManager)
000000