local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local CallFunc = {}

function CallFunc:create(callbackFunc)
    local p = CallFunc.new()
    p:__init(callbackFunc)
    return p
end

function CallFunc:__init(callbackFunc)
    if type(callbackFunc) ~= "function" then
        error("CallFunc 参数类型错误！")
    end

    self.__callbackFunc = callbackFunc
end

function CallFunc:update(dt)
    self.__isFinished = true
end

function CallFunc:onFinish()
    self.__callbackFunc()
end

return NewClass("CallFunc", {AbsNodeAction}, CallFunc)
0000000000000