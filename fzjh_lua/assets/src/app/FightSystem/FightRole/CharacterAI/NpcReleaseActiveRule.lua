local newClass = require("third.class.NewClass")

local fubenai = require("script.npc.fubenai")["fubenai"]

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local IReleaseActiveAIRule = require("app.FightSystem.FightRole.CharacterAI.IReleaseActiveAIRule")

local function parseCondition(str)
    local con = {}

    if str == "0" or str == 0 then
        return con
    end

    local compareSym = string.sub(str, 0, 1)
    local perSymbolIndex = string.find(str, "%%")

    local value, tag
    if perSymbolIndex then
        value = string.sub(str, 2, perSymbolIndex - 1) / 100
        tag = 0
    else
        value = string.sub(str, 2)
        tag = 1
    end

    local con = {
        --@desc 0标识百分比，1标识数值直接使用
        tag = tag,
        value = tonumber(value),
        symbol = compareSym
    }

    return con
end

--@SuperType [src.app.FightSystem.FightRole.CharacterAI.IReleaseActiveAIRule#IReleaseActiveAIRule]
local NpcReleaseActiveRule = {}

function NpcReleaseActiveRule:create(activeId, mobanId)
    local p = NpcReleaseActiveRule.new()
    p:init(activeId, mobanId)
    return p
end

function NpcReleaseActiveRule:getActiveSkillId()
    return self._activeId
end

function NpcReleaseActiveRule:init(activeId, mobanId)
    local ruleRes = fubenai[mobanId]

    self.__mobanId = mobanId

    self._activeId = activeId

    self.__characterQiConditon = parseCondition(ruleRes.qi)

    self.__characterNeiliConditon = parseCondition(ruleRes.neili)

    self.__targetQiCondition = parseCondition(ruleRes.playerqi)

    self.__targetNeiliCondition = parseCondition(ruleRes.playerneili)

    self.__skillCd = ruleRes.skillcd

    self.__cd = 0
end

local valueCheck = function(symbol, condtionValue, realValue)
    if symbol == "<" then
        if realValue < condtionValue then
            return true
        end
    elseif symbol == ">" then
        if realValue > condtionValue then
            return true
        end
    else
        error("NPC主动释放 逻辑运算符 symbol 未定义：" .. symbol)
    end

    return false
end

--@desc: 攻击者气血判断
--@author:Seven
--@time:2021-07-20 24:29:01
--@attacker:[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function NpcReleaseActiveRule:__checkCharacterQi(attacker, target)
    if self.__characterQiConditon.tag == nil then
        return true
    end

    local conditon = self.__characterQiConditon

    if conditon.tag == 1 then
        local characterValue = attacker:getAttr("qi")

        local condtionValue = conditon.value

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    elseif conditon.tag == 0 then
        local condtionValue = conditon.value

        local characterValue = math.min(attacker:getAttr("qi") / attacker:getAttr("qiLimitBattle"), 1)

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    end

    return false
end

function NpcReleaseActiveRule:__checkCharacterNeili(attacker, target)
    if self.__characterNeiliConditon.tag == nil then
        return true
    end

    local conditon = self.__characterNeiliConditon

    if conditon.tag == 1 then
        local characterValue = attacker:getAttr("neili")

        local condtionValue = conditon.value

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    elseif conditon.tag == 0 then
        local condtionValue = conditon.value

        local characterValue = math.min(attacker:getAttr("neili") / attacker:getAttr("neiliMax"), 1)

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    end

    return false
end

function NpcReleaseActiveRule:__checkTargetNeili(attacker, target)
    if self.__targetNeiliCondition.tag == nil then
        return true
    end

    local conditon = self.__targetNeiliCondition

    if conditon.tag == 1 then
        local characterValue = target:getAttr("neili")

        local condtionValue = conditon.value

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    elseif conditon.tag == 0 then
        local condtionValue = conditon.value

        local characterValue = math.min(target:getAttr("neili") / target:getAttr("neiliMax"), 1)

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    end

    return false
end

function NpcReleaseActiveRule:__checkTargetQi(attacker, target)
    if self.__targetNeiliCondition.tag == nil then
        return true
    end

    local conditon = self.__targetNeiliCondition

    if conditon.tag == 1 then
        local characterValue = target:getAttr("qi")

        local condtionValue = conditon.value

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    elseif conditon.tag == 0 then
        local condtionValue = conditon.value

        local characterValue = math.min(target:getAttr("qi") / target:getAttr("qiLimitBattle"), 1)

        return valueCheck(conditon.symbol, condtionValue, characterValue)
    end

    return false
end

function NpcReleaseActiveRule:releaseActiveSkill()
    self.__cd = self.__skillCd
end

--@desc:
--@author:Seven
--@time:2024-03-19 11:09:59
--@attacker: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@return: boolean
function NpcReleaseActiveRule:checkRealease(attacker, target)
    -- FightUtil:printLog(string.format("NpcReleaseActiveRule 攻击者（%s） 模板（%s）技能（%s）释放检查：", attacker:getAttr("name"), self.__mobanId, self._activeId))
    if self.__cd > 0 then
        -- FightUtil:printLog(string.format("|- CD中 "))
        -- FightUtil:printLog(string.format("└─ 最终结果：%s", false))
        return false
    end

    if attacker:isOutOfBattleState() or target:isOutOfBattleState() then
        return false
    end

    local checkCharacterQi = self:__checkCharacterQi(attacker, target)

    local checkCharacterNeili = self:__checkCharacterNeili(attacker, target)

    local targetQi = self:__checkTargetQi(attacker, target)

    local targetNeili = self:__checkTargetNeili(attacker, target)

    -- FightUtil:printLog(string.format("|- 角色气血检查结果：%s", checkCharacterQi))
    -- FightUtil:printLog(string.format("|- 角色内力检查结果：%s", checkCharacterNeili))
    -- FightUtil:printLog(string.format("|- 目标气血检查结果：%s", targetQi))
    -- FightUtil:printLog(string.format("|- 目标内力检查结果：%s", targetNeili))
    if checkCharacterQi and checkCharacterNeili and targetQi and targetNeili then
        -- FightUtil:printLog(string.format("└─ 最终结果：%s", true))
        return true
    end

    FightUtil:printLog(string.format("└─ 最终结果：%s", false))
    return false
end

function NpcReleaseActiveRule:onUpdate(ft)
    if self.__cd > 0 then
        self.__cd = math.max(self.__cd - ft, 0)
    end
end

return newClass("NpcReleaseActiveRule", {IReleaseActiveAIRule}, NpcReleaseActiveRule)
00000000000