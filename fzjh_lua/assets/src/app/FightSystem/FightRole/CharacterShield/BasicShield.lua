--[[
    author:Seven
    time:2023-02-10 16:30:22
    desc: 护盾基础类
]]
local newClass = require("third.class.NewClass")

local BasicShield = {
    __id = -1,
    --@desc 护盾来源
    __source = nil,
    __value = 0,
    --@desc 优先级
    __priority = 0,
    __animId = nil
}

function BasicShield:setShieldId(id)
    self.__id = id
end

function BasicShield:getShieldId()
    return self.__id
end

function BasicShield:getShieldSource()
    if self.__source == nil then
        error("BasicShield:getShieldSource 护盾来源为空！！")
    end

    return self.__source
end

function BasicShield:setPriority(priority)
    if type(priority) ~= "number" then
        error("BasicShield setPriority 设置失败 priority 类型必须为数字")
    end
    self.__priority = priority
end

function BasicShield:getPriority()
    return self.__priority
end

function BasicShield:setShieldValue(value)
    if value == nil or value < 0 then
        error(" BasicShield:setShieldValue 设置护盾值，值不可为空或小于0，value:" .. tostring(value))
    end
    self.__value = value
end

function BasicShield:getShieldValue()
    if self.__value == nil then
        error("代码错误，护盾值为空！！！")
    end
    return self.__value
end

function BasicShield:setShieldAnimId(animId)
    self.__animId = animId
end

function BasicShield:getShieldAnimId()
    return self.__animId
end

return newClass("BasicShield", {}, BasicShield)
0