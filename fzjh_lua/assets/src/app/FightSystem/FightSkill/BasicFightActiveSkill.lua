--[[
    author:Seven
    time:2022-12-05 15:39:56
    desc: 战斗用主动技能基础类
]]
local newClass = require("third.class.NewClass")

local BasicFightActiveZhaoCombination = require("app.FightSystem.FightSkill.ActiveZhao.BasicFightActiveZhaoCombination")

local BanSkillAttackFuncMap = require("app.FightSystem.FightRole.CharacterSkillSystem.BanSkillAttackFuncMap")

local FightCommons = require("app.FightSystem.FightCommons")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightFormula = require("app.FightSystem.FightFormula")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ACarryBuffAddToCharacter = require("app.FightSystem.FightRole.CharacterBuff.Utils.ACarryBuffAddToCharacter")

--@RefType [Constants]
local BUFF_CONSTANT = require("app.FightSystem.FightBuff.Constants")
local BUFF_ADDER_TRIGGER_TYPE = BUFF_CONSTANT.ADDER_TRIGGER_TYPE
local ADD_BUFF_NODE_TYEP = BUFF_CONSTANT.ADD_BUFF_NODE_TYEP

local BasicFightActiveSkill = {}

function BasicFightActiveSkill:__init(id, lv)
    --@RefType [src.app.FightSystem.FightSkill.ActiveZhao.BasicFightActiveZhaoCombination#BasicFightActiveZhaoCombination]
    self.__comb = BasicFightActiveZhaoCombination:create(id, lv)

    self.__cd = 0

    self.__isLock = false

    self.__carryBuffOnlyIdList = {}

    return self
end

function BasicFightActiveSkill:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function BasicFightActiveSkill:getId()
    return self.__comb:getActiveId()
end

function BasicFightActiveSkill:getLevel()
    return self.__comb:getActiveLevel()
end

function BasicFightActiveSkill:getName()
    return self.__comb:getCombName()
end

function BasicFightActiveSkill:getDesc()
    return self.__comb:getDesc()
end

function BasicFightActiveSkill:isAttackTypeSkill()
    return self.__comb:getActiveType() == FightCommons.ACTIVE_TYPE.ATTACK
end

function BasicFightActiveSkill:isReleaseTypeSkill()
    return self.__comb:getActiveType() == FightCommons.ACTIVE_TYPE.RELEASE
end

function BasicFightActiveSkill:getTiliCost()
    local value =
        FightFormula:calActiveAttackTiliCost(self.__comb:getTiliCost(), self.__character:getBuffMaxValue("activeTiliConstCorrectionFactor"), self.__character:getBuffAddAttr("activeTiliConst"))
    return value
end

function BasicFightActiveSkill:getNeiliCost()
    local value =
        FightFormula:calActiveActtackNeiliCost(self.__comb:getNeiliCost(), self.__character:getBuffMaxValue("activeNeiliConstCorrectionFactor"), self.__character:getBuffAddAttr("activeNeiliConst"))

    return value
end

function BasicFightActiveSkill:getCoolDownTime()
    return self.__comb:getCD()
end

function BasicFightActiveSkill:setCD(cd)
    if cd == nil then
        assert(false, self:getName() .. " 设置技能CD参数错误" .. cd)
    end

    if cd < 0 then
        assert(false, self:getName() .. "设置技能CD不可为负数")
    end

    self.__cd = cd
end

function BasicFightActiveSkill:getCD()
    return self.__cd
end

function BasicFightActiveSkill:releaseAreMet()
    local releaseCondiMeet, failureText = self:__isReleaseCondiAreMet()
    if not releaseCondiMeet then
        return releaseCondiMeet, failureText
    end

    local costMeet, failureText = self:__isMeetTheCost()
    if not costMeet then
        return costMeet, failureText
    end

    return true
end

--@desc: 是否满足消耗
--@author:Seven
--@time:2021-07-15 14:15:33
function BasicFightActiveSkill:__isMeetTheCost()
    --@desc 体力消耗（功能需求，需实时计算）
    local costTili = self:getTiliCost()
    if costTili > self.__character:getAttr("tili") then
        return false, TextResManager:getText("1002")
    end

    local costNeili = self:getNeiliCost()
    if costNeili > self.__character:getAttr("neili") then
        return false, TextResManager:getText("1001")
    end

    return true
end

--@desc: 是否满足释放条件
--@author:Seven
--@time:2022-12-06 14:45:19
function BasicFightActiveSkill:__isReleaseCondiAreMet()
    for i, v in ipairs(self.__comb:getReleaseConditions()) do
        --@RefType [src.app.FightSystem.FightSkill.ActiveSkillRelaseCondition.IActiveSkillReleaseCondition#IActiveSkillReleaseCondition]
        local condClass = v

        local isMet, failureText = condClass:canRelease(self.__character)

        if not isMet then
            return isMet, failureText
        end
    end

    return true
end

function BasicFightActiveSkill:__getUseConditions()
    assert(false, "BasicFightActiveSkill:__getUseConditions 该方法不可直接调用，请继承并重写！")
end

function BasicFightActiveSkill:__getTextUseConditions()
    assert(false, "BasicFightActiveSkill:__getTextUseConditions 该方法不可直接调用，请继承并重写！")
end

function BasicFightActiveSkill:isMeetUseCondition()
    local useConditionList = self:__getUseConditions()

    FightUtil:printLog(string.format("角色：%s，主动技能【%s】使用条件判断：", self.__character:getAttr("name"), self:getName()))

    local isMatch = true
    if not MapIsEmpty(useConditionList) then
        for _, condition in ipairs(useConditionList) do
            if condition:matchCondititon(self.__character) == false then
                isMatch = false
            end
        end
    end

    FightUtil:printLog(string.format("使用条件判断结束，结果：%s", isMatch))

    return isMatch
end

function BasicFightActiveSkill:getUseConditionTexts()
    local texts = {}

    local useConditionList = self:__getTextUseConditions()

    if MapIsEmpty(useConditionList) then
        return texts
    end

    for _, condition in ipairs(useConditionList) do
        local text = condition:getConditionText()

        if text ~= "" and text ~= nil then
            table.insert(texts, text)
        end
    end

    return texts
end

--@desc: 获取主动技能攻击招式
--@author:Seven
--@time:2022-12-06 20:53:53
--@return: [src.app.FightSystem.FightSkill.ActiveZhao.BasicFightActiveZhaoCombination#BasicFightActiveZhaoCombination]
function BasicFightActiveSkill:getAttackZhaoComb()
    return self.__comb
end

function BasicFightActiveSkill:getActiveType()
    return self.__comb:getActiveType()
end

--@desc: 该buff添加器应用于主动技能释放过程中
--@author:Seven
--@time:2023-03-11 14:50:55
--@return 添加器id数组
function BasicFightActiveSkill:getBuffLauncherIdArray()
    return self.__comb:getBuffLauncherIdArray()
end

--@desc: 主动技能是否满足释放
--@author:Seven
--@time:2023-12-21 14:35:52
--@return: true | false , string
function BasicFightActiveSkill:isMeetRelease()
    local isBan, tip = self.__character:activeSkillIsBan(0)

    if isBan == true then
        return false, tip
    end

    isBan, tip = self.__character:activeSkillIsBan(self:getActiveType())

    if isBan == true then
        return false, tip
    end

    -- 检查 methods 准备位类型禁用（11-14）
    local methods = self.__comb:getMethods()
    if methods ~= nil then
        local banTypeId = BanSkillAttackFuncMap.getMethodsBanTypeId(methods)
        if banTypeId ~= nil then
            isBan, tip = self.__character:activeSkillIsBan(banTypeId)
            if isBan == true then
                return false, tip
            end
        else
            error("BasicFightActiveSkill:isMeetRelease methods 值无对应禁用类型，activeId=" .. tostring(self.__comb:getActiveId()) .. " methods=" .. tostring(methods))
        end
    end

    --@desc 是否在cd中
    if self:getCD() > 0 then
        return false, TextResManager:getText("1010")
    end

    local result, msg = self:releaseAreMet()
    if result == false then
        return result, msg
    end

    return true
end

function BasicFightActiveSkill:getCarryBuffArray()
    local buffArray = self.__comb:getCarryBuffs()
    if MapIsEmpty(buffArray) then
        return {}
    end

    local list = {}

    for _, info in ipairs(buffArray) do
        local buffid = info[1]
        local arg1 = Helper:getDef(tonumber(info[2]), 0)
        local arg2 = Helper:getDef(tonumber(info[3]), 0)
        local arg3 = Helper:getDef(tonumber(info[4]), 0)
        local arg4
        if info[5] == nil then
            arg4 = 0
        else
            if tonumber(info[5]) == nil then
                arg4 = info[5]
            else
                arg4 = tonumber(info[5])
            end
        end

        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder#BasicCharacterBuffBuilder]
        local buffBuilder = require("app.FightSystem.FightRole.CharacterBuff.Buffs.Builder.BasicCharacterBuffBuilder"):create()

        local buff =
            buffBuilder:setBuffId(buffid):setCharacter(self.__character):setBuffCreator(self.__character):setFight(self.__character:getFight()):setBuffDynamicArgValue("dynamicArg1", arg1):setBuffDynamicArgValue(
            "dynamicArg2",
            arg2
        ):setBuffDynamicArgValue("dynamicArg3", arg3):setBuffDynamicArgValue("dynamicArg4", arg4):build()

        table.insert(list, buff)
    end

    return list
end

function BasicFightActiveSkill:getCarryBuffAdderGroupArray()
    local idList = self.__comb:getEnterBuffLauncherIdArray()

    if MapIsEmpty(idList) then
        return
    end

    local list = {}

    local CharacterBuffAdderGroupFactory = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.CharacterBuffAdderGroupFactory")

    for _, id in ipairs(idList) do
        table.insert(list, CharacterBuffAdderGroupFactory:getEnterFightBuffAdderGroup(id, self.__character, self.__character:getFight()))
    end

    return list
end

return newClass("BasicFightActiveSkill", {ACarryBuffAddToCharacter}, BasicFightActiveSkill)
00000