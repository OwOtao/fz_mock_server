--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 效果类型7

        效果功能：删除角色身上符合条件类型的所有Buff

    * effectTypeParam配置Buff类型，格式：BuffAll=任何Buff、BuffClass=BuffClass类型、BuffID=BuffID类型
        * BuffAll：删除角色身上所有buff
        * BuffClass：删除角色身上指定BuffClassID的所有Buff
        * BuffID：删除角色身上指定BuffID的所有Buff

    * 在argsParam1配置类型对应Buff参数
        * BuffClass类型格式：BuffClass#BuffClass。BuffClass读取 总Buff表.xlsx 的 [Buff类型;buffClass]   、
        * BuffID类型格式：BuffID#BuffID。BuffID读取 总Buff表.xlsx 的 [buff编号;id]  
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect7 = {}

function BuffEffect7:create()
    return BuffEffect7.new():__init()
end

function BuffEffect7:__init()
    self.__isInit = false
    return self
end

function BuffEffect7:updateEffectValue()
    self.__removeType = self.__basicEffect:getEffectTypeParam()

    local argStr = tostring(self.__basicEffect:getArgsParam())

    if argStr ~= nil and argStr ~= "" then
        local args = string.split(argStr, "#")

        self.__removeArgMap =
            table.getMap(
            args,
            function(_, idOrClass)
                return idOrClass, true
            end
        )
    end
end

function BuffEffect7:makeEffectOnAdd()
    if self.__isInit == false then
        self.__isInit = true
        self:updateEffectValue()
    end

    local buffOwner = self.__buff:getBuffOwner()

    buffOwner:walkAllBuff(
        function(buff)
            if self:__isMatchCondition(buff) then
                buffOwner:removeCharacterBuff(buff:getId())
            end
        end
    )
end

function BuffEffect7:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect7:makeEffectOnTransfer(buffEffect)
end

function BuffEffect7:__isMatchCondition(buff)
    if self.__removeType == "BuffAll" then
        return true
    elseif self.__removeType == "BuffClass" then
        if self.__removeArgMap[tostring(buff:getBuffClass())] == true then
            return true
        end
    elseif self.__removeType == "BuffID" then
        if self.__removeArgMap[tostring(buff:getBuffId())] == true then
            return true
        end
    else
        error("未知移除类型")
    end
end

return newClass("BuffEffect7", {ABuffEffect}, BuffEffect7)
000000000