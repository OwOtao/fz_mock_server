local newClass = require("third.class.NewClass")

local PopTextVm = {}

function PopTextVm:create()
    return self.new()
end

function PopTextVm:setPrefix(prefix)
    self.__prefix = prefix
end

function PopTextVm:setValueString(value)
    self.__value = value
end

function PopTextVm:setColor(colorCode)
    self.__colorCode = colorCode
end

function PopTextVm:getColor()
    return self.__colorCode
end

function PopTextVm:getString()
    local prefix = ""
    if self.__prefix ~= nil then
        prefix = self.__prefix
    end

    if self.__value == nil then
        error("角色头顶冒字 value 值不可为空！")
    end

    local color = ""
    if self.__colorCode ~= nil then
        color = self.__colorCode
    end

    return color .. prefix .. tostring(self.__value)
end

return newClass("PopTextVm", {}, PopTextVm)
0