local newClass = require("third.class.NewClass")

local BaseCondition = {}

function BaseCondition:create(...)
    local p = BaseCondition.new()
    p:init(...)
    return p
end

function BaseCondition:ctor()
end

function BaseCondition:init(role, res)
    self.__res = res

    self.__role = role
end

function BaseCondition:getRole()
    return self.__role
end

function BaseCondition:getId()
    return self.__res.id
end

function BaseCondition:getType()
    return self.__res.type
end

function BaseCondition:getAttrId()
    return self.__res.class
end

function BaseCondition:getLogic()
    return self.__res.logic
end

function BaseCondition:getValue()
    return self.__res.value
end

function BaseCondition:getParam()
    return self.__res.param
end

function BaseCondition:compare(roleValue)
    local isMeets =
        switch(
        self:getLogic(),
        {
            ["大于"] = function()
                return roleValue > self:getValue()
            end,
            ["大于等于"] = function()
                return roleValue >= self:getValue()
            end,
            ["小于"] = function()
                return roleValue < self:getValue()
            end,
            ["小于等于"] = function()
                return roleValue <= self:getValue()
            end,
            ["等于"] = function()
                return roleValue == self:getValue()
            end,
            ["不等于"] = function()
                return roleValue ~= self:getValue()
            end,
            default = false
        }
    )

    self.__compareValue = roleValue

    return isMeets
end

function BaseCondition:checkCondition()
    local result = self:check()

    LogSystem:log(
        "玄络条件检测",
        "条件ID : ",
        self:getId(),
        " 类型：",
        self:getType(),
        " 实际值 : ",
        self.__compareValue,
        " 条件值 : ",
        self:getValue(),
        " 判断符 : ",
        self:getLogic(),
        " 检测结果 : ",
        result and "通过" or "不通过"
    )

    return result
end

function BaseCondition:check()
    return false
end

return newClass("BaseCondition", {}, BaseCondition)
0000