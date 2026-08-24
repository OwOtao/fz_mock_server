--[[
    author:Seven
    time:2023-2-7 16:06:23
    desc: 基础伤害类
]]
local class = require("third.class.NewClass")

local ABasicHurt = {
    __attrName = "",
    __value = 0,
}

function ABasicHurt:__setAttrName(name)
    self.__attrName = name
end

function ABasicHurt:getAttrName()
    return self.__attrName
end

function ABasicHurt:__setHurtValue(value)
    self.__value = value
end

--@desc: 获取实际伤害
--@author:Seven
--@time:2023-02-07 16:30:30
function ABasicHurt:getHurtValue()
    if self.__value == nil then
        error("ABasicHurt:getHurtValue 未初始化伤害值")
    end
    return self.__value
end

return class("ABasicHurt", {}, ABasicHurt)
000000