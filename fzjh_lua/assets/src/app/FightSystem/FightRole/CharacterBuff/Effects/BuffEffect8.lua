--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 效果类型8

        效果功能：免疫主动招式的Buff
        **效果类型ID=8，免疫主动招式的Buff**
            * 效果功能执行：指定类型Buff无法添加到角色身上
            * Buff配置与 效果类型ID=7 相同
        * 效果生效表现：
            * 角色被添加Buff不成功时触发表现：T2=界面中间Tips弹字提示、T3=界面战斗信息区新增描述文本
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect8 = {}

function BuffEffect8:create()
    return BuffEffect8.new():__init()
end

function BuffEffect8:__init()
    self.__isInit = false
    return self
end

function BuffEffect8:updateEffectValue()
    --@desc 免疫类型
    self.__immuneType = self.__basicEffect:getEffectTypeParam()

    local argStr = tostring(self.__basicEffect:getArgsParam())

    if argStr ~= nil and argStr ~= "" then
        self.__immuneArgs = string.split(argStr, "#")
    end
end

function BuffEffect8:makeEffectOnAdd()
    if self.__isInit == false then
        self.__isInit = true
        self:updateEffectValue()
    end

    local buffOwner = self.__buff:getBuffOwner()

    self.__immuneObjectIds = {}

    if self.__immuneType == "BuffAll" then
        table.insert(self.__immuneObjectIds, buffOwner:addImmuneBuff("BuffAll"))
    elseif self.__immuneType == "BuffClass" then
        if table.getn(self.__immuneArgs) > 0 then
            for _, buffClass in ipairs(self.__immuneArgs) do
                buffClass = tonumber(buffClass)
                table.insert(self.__immuneObjectIds, buffOwner:addImmuneBuff("BuffClass", buffClass))
            end
        end
    elseif self.__immuneType == "BuffID" then
        if table.getn(self.__immuneArgs) > 0 then
            for _, buffid in ipairs(self.__immuneArgs) do
                table.insert(self.__immuneObjectIds, buffOwner:addImmuneBuff("BuffID", buffid))
            end
        end
    end
end

function BuffEffect8:makeEffectOnRemove()
    for _, id in ipairs(self.__immuneObjectIds) do
        self.__buff:getBuffOwner():removeImmuneBuff(self.__immuneType, id)
    end
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect8:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect8", {ABuffEffect}, BuffEffect8)
00