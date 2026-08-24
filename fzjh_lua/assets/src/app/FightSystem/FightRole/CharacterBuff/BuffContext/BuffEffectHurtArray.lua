--[[
    author:Seven
    time:2023-11-22 17:31:46
    desc: buff 造成伤害对象存放数组
]]
local newClass = require("third.class.NewClass")
local isImplement = require("third.assertIsInstance.assertIsInstance")
local BuffEffectHurtArray = {}

function BuffEffectHurtArray:create()
    return BuffEffectHurtArray.new()
end

function BuffEffectHurtArray:ctor()
    self.__list = {}
end

function BuffEffectHurtArray:addHurt(hurt)
    table.insert(self.__list, hurt)
end

function BuffEffectHurtArray:clear()
    self.__list = {}
end

function BuffEffectHurtArray:getIterator()
    local i = 1
    return function()
        local item = self.__list[i]
        i = i + 1
        return item
    end
end

return newClass("BuffEffectHurtArray", {}, BuffEffectHurtArray)
00000000