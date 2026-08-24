--[[
    author:Seven
    time:2023-12-18 15:51:07
    desc: 操作命令申请结果对象封装
]]
local interface = require("third.class.interface")

local IOperationCommandResponse = {}

function IOperationCommandResponse:setResult(bool)
end

function IOperationCommandResponse:getResult()
end

function IOperationCommandResponse:setResultPrintText(text)
end

function IOperationCommandResponse:getResultPrintText()
end

function IOperationCommandResponse:setResultPopText(popText)
end

function IOperationCommandResponse:getResultPopText()
end

return interface("IOperationCommandResponse", IOperationCommandResponse)
00000