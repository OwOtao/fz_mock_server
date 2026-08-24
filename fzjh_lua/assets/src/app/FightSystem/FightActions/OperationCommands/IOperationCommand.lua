--[[
    author:Seven
    time:2023-12-18 14:41:23
    desc: 角色操作命令
]]
local interface = require("third.class.interface")

local IOperationCommand = {}

function IOperationCommand:setOperationCommandId(id)
end

function IOperationCommand:getOperationCommandId()
end

--@desc: 设置添加时的逻辑帧数
--@author:Seven
--@time:2023-12-26 15:24:24
--@frame: number
function IOperationCommand:setLogicFrame(frame)
end

--@desc: 获取添加时的逻辑帧数
--@return: number
function IOperationCommand:getLogicFrame()
end

--@desc: 设置命令者ID
--@author:Seven
--@time:2023-12-18 14:43:11
--@commanderId: 命令者ID
function IOperationCommand:setCommanderId(commanderId)
end

--@desc: 获取命令者ID
--@return 命令者ID
function IOperationCommand:getCommanderId()
end

--@desc: 设置命令类型ID
--@param commandTypeId: 命令类型ID
function IOperationCommand:setCommandTypeId(commandTypeId)
end

--@desc: 获取命令类型ID
--@return 命令类型ID
function IOperationCommand:getCommandTypeId()
end

--@desc: 设置命令名称
--@author:Seven
--@time:2023-12-20 17:35:17
--@name: string
function IOperationCommand:setCommandName(name)
end

--@desc: 获取命令名称
--@author:Seven
--@time:2023-12-20 17:35:29
function IOperationCommand:getCommandName()
end

--@desc: 设置命令优先级
--@author:Seven
--@time:2023-12-20 16:57:05
function IOperationCommand:setCommandPriority(value)
end

--@desc: 获取命令优先级
--@author:Seven
--@time:2023-12-20 16:57:37
--@return: number
function IOperationCommand:getCommandPriority()
end

--@desc: 设置命令参数
--@commandParam: 命令参数 []
function IOperationCommand:putCommandParam(commandParam)
end

--@desc: 获取命令参数
--@author:Seven
--@time:2023-12-18 20:58:21
--@index: 索引
function IOperationCommand:getCommandParam(index)
end

--@desc:加入队列时执行
--@author:Seven
--@time:2023-12-18 14:47:44
--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function IOperationCommand:onAddCommandQueue(operationCommandQueue)
end

--@desc: 从队列中移除时执行
--@operationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function IOperationCommand:onRemoveCommandQueue(operationCommandQueue)
end

--@desc: 当前命令是否满足执行条件
--@author:Seven
--@time:2023-12-21 14:48:05
--@fightContext: [src.app.FightSystem.Fight.BattleSystem#Fight]
--@return: true | false , failmsg
function IOperationCommand:canDoOperationCommand(fightContext)
end

return interface("IOperationCommand", IOperationCommand)
0000000000