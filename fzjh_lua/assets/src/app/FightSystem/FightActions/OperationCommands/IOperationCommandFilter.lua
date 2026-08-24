--[[
    author:Seven
    time:2023-12-18 15:15:41
    desc: 命令过滤器
]]
local interface = require("third.class.interface")

local IOperationCommandFilter = {}

--@desc: 设置命令队列对象
--@author:Seven
--@time:2023-12-18 19:49:07
--@IOperationCommandQueue: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function IOperationCommandFilter:setOperationCommandQueue(IOperationCommandQueue)
end

--@desc: 获取命令队列对象
--@author:Seven
--@time:2023-12-18 19:49:07
--@return [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandQueue#IOperationCommandQueue]
function IOperationCommandFilter:getOperationCommandQueue()
end

--@desc: 执行过滤器
--@IOperationCommand: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommand#IOperationCommand]
--@IOperationCommandResponse: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
--@filterChain: [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandFilter#IOperationCommandFilter]
--@return void
function IOperationCommandFilter:doFilter(IOperationCommand, IOperationCommandResponse, filterChain)
end

return interface("IOperationCommandFilter", IOperationCommandFilter)
0000000