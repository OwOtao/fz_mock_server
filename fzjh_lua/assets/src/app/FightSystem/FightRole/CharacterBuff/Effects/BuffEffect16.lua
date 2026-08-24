--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    **效果类型ID=16，禁用战斗易武、恢复、逃跑**
        * 效果生效节点：4=使用战斗功能按钮(效果添加时)
            * 可以认为是添加效果后，角色获得禁用战斗易武、恢复、逃跑的状态，因而在逻辑上是效果添加时
        * 效果功能执行：无法使用功能按钮（可指定禁用功能）
            * 指定类型配置在 `效果类型参数;effectTypeParam`
            * 配置格式：功能类型#功能类型
            * 功能类型：healthy=恢复、changeWeapon=易武、runAway=逃跑
        * 效果生效表现：
            * 玩家点击禁用的功能按钮时，tips弹出对应功能使用失败文本。
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect16 = {}

function BuffEffect16:create()
    return BuffEffect16.new():__init()
end

function BuffEffect16:__init()
    self.__isInit = false
    return self
end

function BuffEffect16:updateEffectValue()
    self.__banFuncTypeArray = string.split(self.__basicEffect:getEffectTypeParam(), "#")

    self.__tip = self.__basicEffect:getActiveEffectUseZhaoTips()
end

function BuffEffect16:makeEffectOnAdd()
    if self.__isInit == false then
        self:updateEffectValue()
        self.__isInit = true
    end

    if MapIsEmpty(self.__banFuncTypeArray) then
        error("效果类型16，配置错误 没有解析出：" .. tostring(self.__basicEffect:getId()))
    end

    self.__indexArray = {}

    local owner = self.__buff:getBuffOwner()

    for i, v in ipairs(self.__banFuncTypeArray) do
        table.insert(self.__indexArray, owner:addBanActiveAttack(v, self.__tip))
    end
end

function BuffEffect16:makeEffectOnRemove()
    local owner = self.__buff:getBuffOwner()

    for i, v in ipairs(self.__indexArray) do
        owner:removeBanActiveAttack(v)
    end
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect16:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect16", {ABuffEffect}, BuffEffect16)
0000000000000