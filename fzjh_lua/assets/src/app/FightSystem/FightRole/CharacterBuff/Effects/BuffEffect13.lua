--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
**效果类型ID=13，将Buff持有者身上指定类型的Buff转移到指定类型角色身上**

* 效果功能执行：被添加Buff的角色，在获得Buff时，将身上指定类型的N个Buff转移到指定类型角色身上。
  * effectTypeParam配置：可转移的Buff范围，配置格式：范围类型#抽取Buff数量#转移到的指定角色类型
    * 范围类型有：BuffAll=任何Buff、BuffClass=BuffClass类型、BuffID=BuffID类型
    * 抽取Buff数量，配置整数。每个抽取平均随机。
    * 转移到的指定角色类型：self=Buff施放者自身、target=Buff持有者当前锁定的攻击目标
       * 有可能出现Buff施放者是角色A，给角色B类型13的Buff，角色B锁定的攻击目标是角色C：结果就是角色A使用主动后，角色B的Buff转移给角色C
  * argsParam根据Buff范围配置对应参数：
    * 范围=BuffAll，参数不填
    * 范围=BuffClass，格式：BuffClass#BuffClass。BuffClass读取 `总Buff表.xlsx 的 [Buff类型;buffClass]`
    * 范围=BuffID，格式：BuffID#BuffID。BuffID读取 `总Buff表.xlsx 的 [buff编号;id]` 
  * 转移Buff 当前buff的所有状态
* 效果生效表现：
  * 提示文本位置：T5=角色头顶弹字提示(招式组合)
  * 招式组合结束，如果实际抽取到的Buff数量>0，在Buff施放者头顶弹出文本“窃取成功”。同时攻击目标身上buff删除（会显示buff删除文本）。
    * 文本配置在Buff效果表
  * 实际抽取到的Buff数量=0，不显示弹字。
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect13 = {}

function BuffEffect13:create()
    return BuffEffect13.new():__init()
end

function BuffEffect13:__init()
    self.__isInit = false
    return self
end

function BuffEffect13:updateEffectValue()
    local effectTypeParams = string.split(self.__basicEffect:getEffectTypeParam(), "#")

    --@desc 转移类型
    self.__transferBuffType = effectTypeParams[1]

    --@desc 转移buff抽取次数
    self.__transferBuffTimes = tonumber(effectTypeParams[2]) or 1

    --@desc 转移buff添加对象
    self.__transferBuffAddTarget = effectTypeParams[3]

    --@desc 根据转移类型定义的条件参数数组
    self.__transferParams = string.split(self.__basicEffect:getArgsParam(), "#")
end

function BuffEffect13:makeEffectOnAdd()
    if self.__isInit == false then
        self:updateEffectValue()
        self.__isInit = true
    end

    local buffOwner = self.__buff:getBuffOwner()

    local buffAddTarget = nil

    if self.__transferBuffAddTarget == "self" then
        buffAddTarget = self.__buff:getBuffCreator()
    elseif self.__transferBuffAddTarget == "target" then
        buffAddTarget = buffOwner:getTarget()
    else
        error("BuffEffect13 effectTypeParams 配置异常！")     
    end


    if buffOwner == buffAddTarget then
        return
    end

    local list = {}
    for v in buffOwner:getBuffGroupIterator() do
        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup#IFightCharacterBuffGroup]
        local buffGroup = v
        if self:__isMatch(buffGroup) then
            local buffList = buffOwner:getBuffByBuffId(buffGroup:getBuffId())

            if #buffList > 0 then
                table.appendArray(list, buffList)
            end
        end
    end

    for i = 1, self.__transferBuffTimes do
        if #list <= 0 then
            return
        end

        local index = FightUtil:random(1, #list)

        self:__transferBuff(table.remove(list, index), buffAddTarget)
    end
end

function BuffEffect13:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect13:makeEffectOnTransfer(buffEffect)
end

--@desc: 转移buff
--@author:Seven
--@time:2023-12-03 17:10:40
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function BuffEffect13:__transferBuff(buff, target)
    local removeBuff = buff:getBuffOwner():removeCharacterBuff(buff:getId())

    local newBuff = removeBuff:makeBuffEffectOnTransfer(target)

    target:addCharacterBuff(newBuff)
end

--@desc: 是否满足
--@author:Seven
--@time:2023-12-02 14:32:11
--@buffGroup: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuffGroup#IFightCharacterBuffGroup]
function BuffEffect13:__isMatch(buffGroup)
    if self.__transferBuffType == "BuffAll" then
        return true
    elseif self.__transferBuffType == "BuffClass" then
        for __, v in pairs(self.__transferParams) do
            if tonumber(v) == buffGroup:getBuffClass() then
                return true
            end
        end
    elseif self.__transferBuffType == "BuffID" then
        if table.contains(self.__transferParams, buffGroup:getBuffId()) then
            return true
        end
    end

    return false
end

return newClass("BuffEffect13", {ABuffEffect}, BuffEffect13)
00000000