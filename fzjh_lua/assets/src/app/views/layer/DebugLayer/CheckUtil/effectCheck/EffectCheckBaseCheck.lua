local newClass = require("third.class.NewClass")
local LogSystem = require("app.models.LogSystem.LogSystem")

local BaseCheck = {
    __effect = nil
}

function BaseCheck:create(effect)
    local p = BaseCheck.new()
    p:init(effect)
    return p
end

function BaseCheck:init(effect)
    self.__effect = clone(effect)
end

function BaseCheck:getFinalArg1()
    if not self.__effectParams then
        self.__effectParams = self.__effect:getEffectParams()
    end
    
    return Helper:GetValueFromScript(self.__effect:getArg1(), self.__effectParams)
end

function BaseCheck:getFinalArg2()
    if not self.__effectParams then
        self.__effectParams = self.__effect:getEffectParams()
    end
    
    return Helper:GetValueFromScript(self.__effect:getArg2(), self.__effectParams)
end

function BaseCheck:getFinalArg3()
    if not self.__effectParams then
        self.__effectParams = self.__effect:getEffectParams()
    end
    
    return Helper:GetValueFromScript(self.__effect:getArg3(), self.__effectParams)
end

function BaseCheck:getFinalArg4()
    if not self.__effectParams then
        self.__effectParams = self.__effect:getEffectParams()
    end
    
    return Helper:GetValueFromScript(self.__effect:getArg4(), self.__effectParams)
end

function BaseCheck:checkArg1()
    return true
end

function BaseCheck:checkArg2()
    return true
end

function BaseCheck:checkArg3()
    return true
end

function BaseCheck:checkArg4()
    return true
end

function BaseCheck:check()
    local effectType = self.__effect:getType()

    local effectId = self.__effect:getId()
    
    local isTrue, msg = self:checkArg1()

    local msgList = {}

    if isTrue == false then
        table.insert(msgList, "检测效果类型："..tostring(effectType).."  检测效果id:"..tostring(effectId).."  检测参数arg1：结果异常!!!  "..msg)
    end

    local isTrue, msg = self:checkArg2()

    if isTrue == false then
        table.insert(msgList, "检测效果类型："..tostring(effectType).."  检测效果id:"..tostring(effectId).."  检测参数arg2：结果异常!!!  "..msg)
    end

    local isTrue, msg = self:checkArg3()

    if isTrue == false then
        table.insert(msgList, "检测效果类型："..tostring(effectType).."  检测效果id:"..tostring(effectId).."  检测参数arg3：结果异常!!!  "..msg)
    end

    local isTrue, msg = self:checkArg4()

    if isTrue == false then
        table.insert(msgList, "检测效果类型："..tostring(effectType).."  检测效果id:"..tostring(effectId).."  检测参数arg4：结果异常!!!  "..msg)
    end

    return msgList
end

return newClass("BaseCheck", {}, BaseCheck)
0000000000000