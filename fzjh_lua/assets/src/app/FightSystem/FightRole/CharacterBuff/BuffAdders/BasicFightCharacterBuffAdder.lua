--[[
    author:Seven
    time:2023-03-07 19:53:44
    desc: 战斗buff添加器类
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AFightCharacterBuffAdder = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdder")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AFightCharacterBuffAdder#AFightCharacterBuffAdder]
local BasicFightCharacterBuffAdder = {}

function BasicFightCharacterBuffAdder:create(basicBuffAdder)
    return BasicFightCharacterBuffAdder.new():__init(basicBuffAdder)
end

function BasicFightCharacterBuffAdder:__init(basicBuffAdder)
    --@RefType [src.app.FightSystem.FightBuff.BasicBuffAdder.BasicBuffAdderRes#BasicBuffAdderRes]
    self.__basicBuffAdder = basicBuffAdder

    self.__addBuffdynamicArgMap = {}

    return self
end

--@desc: 当前添加器的触发类型
--@author:Seven
--@time:2023-03-08 10:56:34
function BasicFightCharacterBuffAdder:getTriggerType()
    return self.__basicBuffAdder:getTriggerType()
end

function BasicFightCharacterBuffAdder:getOrder()
    return self.__basicBuffAdder:getOrder()
end

--@desc: 前置判断order
--@author:Seven
--@time:2023-03-08 11:22:40
--@return 0=无前置判断 -1=策划配置未填写  >0 = 前置判断id
function BasicFightCharacterBuffAdder:getIdPrerequisites()
    local preIndex = tonumber(self.__basicBuffAdder:getIdPrerequisites())

    if preIndex == -1 then
        error("BasicFightCharacterBuffAdder:getIdPrerequisites() 前置判断order:idPrerequisites为-1，需具体填写 id: " .. self.__basicBuffAdder:getId())
    end

    return preIndex
end

--@desc: buff添加器触发
--@author:Seven
--@time:2023-03-08 11:23:27
--@return: true | false
function BasicFightCharacterBuffAdder:triggerCheck()
    if self.__basicBuffAdder:getHaveCon() == 0 then
        FightUtil:printFormatLog("%s 添加器（%s）触发判断 - 无条件", self.__character:getAttr("name"), self.__basicBuffAdder:getId())
        return true
    end

    FightUtil:printFormatLog("%s 添加器（%s）触发判断 - 触发条件判断开始", self.__character:getAttr("name"), self.__basicBuffAdder:getId())

    local condtionResult = self:__checkCondition()
    if condtionResult == false then
        return false
    end

    --@desc 概率判断
    local probability = self:__getAddProbability()
    local randomValue = FightUtil:random(1, 100)
    FightUtil:printFormatLog("%s 添加器（%s）概率判断 - 概率：%s，随机值：%s", self.__character:getAttr("name"), self.__basicBuffAdder:getId(), probability, randomValue)
    if probability < randomValue then
        return false
    end

    return true
end

function BasicFightCharacterBuffAdder:__checkCondition()
    local conditonArgs = self.__basicBuffAdder:getAddConditions()

    if MapIsEmpty(conditonArgs) then
        FightUtil:printFormatLog("%s 添加器（%s）条件判断 - 条件数量为0", self.__character:getAttr("name"), self.__basicBuffAdder:getId())
        return true
    end

    local c_name = self.__character:getAttr("name")
    for _, condition in ipairs(conditonArgs) do
        local conditonTarget, conditionType, conditionResultType, conditionParams = unpack(condition)

        local conditionClassFile = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AdderCondition" .. tostring(conditionType))

        --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#AAdderCondition]
        local condition = conditionClassFile:create(conditonTarget, conditionResultType, conditionParams)

        condition:setFight(self.__fight)

        condition:setCharacter(self.__character)

        condition:setBuffAdder(self)

        if not condition:matchCondititon() then
            FightUtil:printFormatLog(
                "%s - 添加器（%s）条件判断 - 失败: conditionType：%s，conditonTarget：%s，conditionResultType：%s，conditionParams：%s",
                c_name,
                self.__basicBuffAdder:getId(),
                conditionType,
                conditonTarget,
                conditionResultType,
                conditionParams
            )
            return false
        end
        FightUtil:printFormatLog(
            "%s - 添加器（%s）条件判断 - 成功: conditionType：%s，conditonTarget：%s，conditionResultType：%s，conditionParams：%s",
            c_name,
            self.__basicBuffAdder:getId(),
            conditionType,
            conditonTarget,
            conditionResultType,
            conditionParams
        )
    end

    return true
end

function BasicFightCharacterBuffAdder:getAddBuffNodes()
    return tonumber(self.__basicBuffAdder:getAddBuffNodes())
end

--@desc: 获取概率
--@author:Seven
--@time:2023-03-08 11:27:51
--@return: 概率值
function BasicFightCharacterBuffAdder:__getAddProbability()
    local formulaType = self.__basicBuffAdder:getAddProbabilityFormulaType()

    if formulaType == 1 then
        return tonumber(self.__basicBuffAdder:getAddProbabilityParam())
    end

    if formulaType == 2 then
        local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")

        local zhaoHurtDegree = ZhaoHurtDegreeFactory:createHurtDegreeGroup(self.__basicBuffAdder:getAddProbabilityParam(), self.__character)

        return zhaoHurtDegree:getHurtValue()
    end

    error("BasicFightCharacterBuffAdder:__getAddProbability 添加概率计算类型 类型错误：" .. tostring(formulaType))
end

function BasicFightCharacterBuffAdder:getAddBuffId()
    return self.__basicBuffAdder:getAddBuffID()
end

--@desc: 获取buff添加目标类型
--@author:Seven
--@time:2026-01-12
--@return:0=自身、1=我队友、2=我全体、10=敌目标、11=敌队友、12=敌全体
function BasicFightCharacterBuffAdder:getAddBuffTargetType()
    return self.__basicBuffAdder:getAddBuffTarget()
end

function BasicFightCharacterBuffAdder:getAddBuffdynamicArg1()
    return self.__basicBuffAdder:getAddBuffdynamicArg1()
end

function BasicFightCharacterBuffAdder:getAddBuffdynamicArg2()
    return self.__basicBuffAdder:getAddBuffdynamicArg2()
end

function BasicFightCharacterBuffAdder:getAddBuffdynamicArg3()
    return self.__basicBuffAdder:getAddBuffdynamicArg3()
end

function BasicFightCharacterBuffAdder:getAddBuffdynamicArg4()
    return self.__basicBuffAdder:getAddBuffdynamicArg4()
end

--@desc: 放入添加器自身的动态参数
--@author:Seven
--@time:2023-03-27 16:54:30
--@dynamicArgName: 动态参数名
--@value: 值
function BasicFightCharacterBuffAdder:putAdderDynamicArg(dynamicArgName, value)
    self.__addBuffdynamicArgMap[dynamicArgName] = value
end

--@desc: 获取添加器自身动态参数
--@author:Seven
--@time:2023-03-27 17:47:22
--@dynamicArgName: 动态参数名
--@return
function BasicFightCharacterBuffAdder:getAdderOtherDynamicArg(dynamicArgName)
    if self.__addBuffdynamicArgMap[dynamicArgName] == nil then
        error("errmsg: BasicFightCharacterBuffAdder:getAdderOtherDynamicArg() 获取添加器自身动态参数错误，没有找到参数：" .. tostring(dynamicArgName))
    end

    return self.__addBuffdynamicArgMap[dynamicArgName]
end

--@desc: 获取触发时输出的文本
--@author:Seven
--@time:2023-03-10 11:48:30
function BasicFightCharacterBuffAdder:getTriggerBuffDesc()
    return self.__basicBuffAdder:getAddBuffDesc()
end

--@desc: 获取加权随机添加器配置
--@author:Seven
--@time:2026-01-12
function BasicFightCharacterBuffAdder:getWeightedLauncher()
    return self.__basicBuffAdder:getWeightedLauncher()
end


return newClass("BasicFightCharacterBuffAdder", {AFightCharacterBuffAdder}, BasicFightCharacterBuffAdder)
000000000