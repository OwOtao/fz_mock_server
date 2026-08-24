--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=17，装备武器切换目标**
        效果功能执行：Buff添加后，立刻将Buff持有者的**当前武器**改为**武器切换目标**指向的武器ID，
            * 武器切换目标：执行装备武器切换目标效果后，会根据武器切换目标当前值决定目标武器。
        其他判断改为配置在 `表[总Buff表效果]` 字段 `effectTypeParam` ，类型2和类型3必须有配置。
        * * 配置格式为：'条件类型#判断方式#判断值#条件不符提示文本ID|条件类型#判断方式#判断值#条件不符提示文本ID|...' , 支持配置多组条件、用 | 间隔，配置的多个条件需要每个条件都判断为成功、才算可选条件成功。
            * 条件类型=2、判断(武器切换目标的武器)是否符合(判断方式)对应的需求
                * 判断方式：等于/不等于/跳过
                    * 如果 判断方式 = 跳过，不判断(武器切换目标的武器)是否符合(判断方式)对应的需求，其他参数填0
                * 判断值：填武器一级分类（对应 `表[武器分类管理].firstType`）
                * 条件不符提示文本ID：读取`表[通用提示文本]`的ID
            * 条件类型=3、判断(武器切换目标的武器战斗状态)是否符合(判断方式)对应的需求
                * 判断方式：等于/不等于/跳过
                    * 如果 判断方式 = 跳过，不判断(武器切换目标的武器战斗状态)是否符合(判断方式)对应的需求，其他参数填0
                * 判断值：填武器战斗状态【正常（normal）、击飞（fly）、损坏（destroy）、丢弃（giveUp）】
                * 条件不符提示文本ID：读取`表[通用提示文本]`的ID
        * 同时支持空手也是切换武器的一种，可以空手切武器、武器切空手。
]]
local newClass = require("third.class.NewClass")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect17 = {}

function BuffEffect17:create()
    return BuffEffect17.new():__init()
end

function BuffEffect17:__init()
    self.__isInit = false
    return self
end

function BuffEffect17:updateEffectValue()
    local params = self.__basicEffect:getEffectTypeParam()
    if params == nil then
        assert(false, "BuffEffect17:updateEffectValue() EffectTypeParam 不可为空")
    end

    --@desc 条件类型#判断方式#判断值#条件不符提示文本ID
    local switchTypeArrayStrs = string.split(params, "|")

    self.__switchTypeArray = {}
    for _, switchTypeStrs in ipairs(switchTypeArrayStrs) do
        local switchTypeTable = string.split(switchTypeStrs, "#")
        table.insert(
            self.__switchTypeArray,
            {
                switchTypeTable[1],
                switchTypeTable[2],
                switchTypeTable[3],
                switchTypeTable[4]
            }
        )
    end
end

function BuffEffect17:makeEffectOnAdd()
    if self.__isInit == false then
        self:updateEffectValue()
        self.__isInit = true
    end

    local owner = self.__buff:getBuffOwner()

    local isSuccess = true
    for _, switchTypeStrs in ipairs(self.__switchTypeArray) do
        --@desc 条件类型
        local __switchType = switchTypeStrs[1]

        --@desc 判断方式
        local __judgeType = switchTypeStrs[2]

        --@desc 判断值
        local __judgeValue = switchTypeStrs[3]

        --@desc 条件不符提示文本ID
        local __judgeTextId = switchTypeStrs[4]

        local __success, failMsg = owner:judgeSwitchWeapon(__switchType, __judgeType, __judgeValue, __judgeTextId)

        if not __success and owner:isPlayer() then
            owner:getFight():popText(failMsg)
            isSuccess = false
            break
        end
    end

    if isSuccess then
        owner:switchWeapon()
        local prepActMap = {}
        for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
            local activeSkill = owner:getPrepActiveSkillByPosIndex(i)
            if activeSkill then
                prepActMap[tostring(i)] = activeSkill
            end
        end
        self.__buff:getBuffOwner():getFight():notifyVeiwEvent(require "app.FightSystem.Veiws.ViewEvents.Events.PlayerRefreshAcitveSkillsViewEvent":create(owner:getId(), prepActMap))
    end
end

function BuffEffect17:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect17:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect17", {ABuffEffect}, BuffEffect17)
00000000000000