--[[
    author:Seven
    time:2023-12-18 14:42:01
    desc: 操作命令队列
]]
local interface = require("third.class.interface")

local IOperationCommandQueue = {}

--@desc: 添加操作命令
--@author:Seven
--@time:2023-12-18 15:14:11
--@IOperationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
function IOperationCommandQueue:addOperationCommand(IOperationCommand)
end

--@desc: 移除操作命令
--@IOperationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function IOperationCommandQueue:removeOperationCommand(IOperationCommand)
end

--@desc: 弹出队头操作命令
--@author:Seven
--@time:2023-12-18 16:38:39
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function IOperationCommandQueue:popFirstOperationCommand()
end

--@desc: 获取第一个操作命令
--@author:Seven
--@time:2023-12-20 16:10:55
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function IOperationCommandQueue:getFirstOperationCommand()
end

--@desc: 添加命令过滤器
--@author:Seven
--@time:2023-12-18 17:27:14
--@IOperationCommandFilter: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
function IOperationCommandQueue:addOpeartionCommandFilter(IOperationCommandFilter)
end

--@desc: 移除命令过滤器
--@author:Seven
--@time:2023-12-18 17:27:22
--@IOperationCommandFilter: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
function IOperationCommandQueue:removeOpeartionCommandFilter(IOperationCommandFilter)
end

--@desc: 根据角色id获取该角色的所有命令
--@author:Seven
--@time:2023-12-20 16:14:22
--@commanderId: 命令者id
--@return: array [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
function IOperationCommandQueue:getOperationCommandByCommanderId(commanderId)
end

--@desc: 清楚角色所有操作
--@author:Seven
--@time:2023-12-26 11:03:00
--@commanderId: 角色id
function IOperationCommandQueue:removeCommanderAllOperationCommand(commanderId)
end

--@desc: 根据命令释放者id获取队列中命令数量
--@author:Seven
--@time:2023-12-18 16:52:50
--@commanderId: 命令者id
--@return number
function IOperationCommandQueue:getOperationCommandCountByCommanderId(commanderId)
end

--@desc: 获取队列中命令数量
--@author:Seven
--@time:2023-12-18 16:53:47
function IOperationCommandQueue:getTotalOperationCommandCount()
end

--@desc: 获取命令者
--@author:Seven
--@time:2023-12-18 17:16:44
--@commanderId: 命令者id
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function IOperationCommandQueue:getCommander(commanderId)
end

return interface("IOperationCommandQueue", IOperationCommandQueue)
000000