--[[
    author:Seven
    time:2023-12-19 16:05:48
    desc:
]]
local IOperationCommandResponse = require("app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse")

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightActions.OperationCommands.IOperationCommandResponse#IOperationCommandResponse]
local OperationCommandResponse = {
    __isResult = true
}

function OperationCommandResponse:create()
    return OperationCommandResponse.new()
end

function OperationCommandResponse:setResult(bool)
    if type(bool) ~= "boolean" then
        error("OperationCommandResponse:setResult(bool) - invalid bool")
    end

    self.__isResult = bool
end

function OperationCommandResponse:getResult()
    return self.__isResult
end

function OperationCommandResponse:setResultPrintText(text)
    self.__preintText = text
end

function OperationCommandResponse:getResultPrintText()
    return self.__preintText
end

function OperationCommandResponse:setResultPopText(popText)
    self.__popText = popText
end

function OperationCommandResponse:getResultPopText()
    return self.__popText
end

return newClass("OperationCommandResponse", {IOperationCommandResponse}, OperationCommandResponse)
00000000000