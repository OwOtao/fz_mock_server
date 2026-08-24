local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
local LogSystem = require("app.models.LogSystem.LogSystem")
local Desc = require("app.FightSystem.FightBuff.Desc")
local oldPrint = print
local function print(...)
    LogSystem:logWithTab("增益日志.增益添加器:", ...)
end

local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local FightFormula = require("app.FightSystem.FightFormula")
local Trie = require("third.tree.Trie")
local trie = Trie:create()
trie:add("dynamicLaun")

local class = require("third.class.NewClass")
local BuffAdderItem = {}


function BuffAdderItem:create(data, dynamicParamMap)
    local p = BuffAdderItem.new()
    p:__init(data, dynamicParamMap)
    return p
end

function BuffAdderItem:__init(data, dynamicParamMap)
    if type(data.addConditions) == "string" then
        if dynamicParamMap then
            data.addConditions = trie:relpaceString(data.addConditions, function(s)
                return dynamicParamMap[s]
            end)
        end

        self.__addConditions =
            table.map(
            string.split(data.addConditions, "|"),
            function(v)
                return string.split(v, "#")
            end
        )

        for _, condition in ipairs(self.__addConditions) do
            condition[1] = tonumber(condition[1])
            condition[2] = tonumber(condition[2])
            condition[3] = tonumber(condition[3])

            if type(condition[4]) == "string" then
                if string.find(condition[4], "@") then
                    condition[4] = string.split(condition[4], "@")
                    for i, v in ipairs(condition[4]) do
                        condition[4][i] = v
                    end
                else
                    condition[4] = {condition[4]}
                end
            end
        end
    else
        self.__addConditions = {}
    end

    self.data = data
end

function BuffAdderItem:getTriggerType()
    return self.data.triggerType
end

function BuffAdderItem:getAddBuffDesc()
    return self.data.addBuffDesc
end

function BuffAdderItem:setBuffNeeded(buffNeeded)
    self.__buffNeeded = buffNeeded
end

function BuffAdderItem:setCharacter(character)
    self.__character = character
end

function BuffAdderItem:getId()
    return self.data.id
end

function BuffAdderItem:getOrder()
    return self.data.order
end

function BuffAdderItem:getContidionId()
    return tostring(self.data.buffLauncher) .. "_" .. tostring(self.data.order)
end

function BuffAdderItem:getPreConditionId()
    return tostring(self.data.buffLauncher) .. "_" .. tostring(self.data.idPrerequisites)
end

function BuffAdderItem:haveCon()
    return self.data.haveCon == 1
end

function BuffAdderItem:getConditions()
    return self.__addConditions
end

function BuffAdderItem:getAddProbability()
    if self.data.addProbabilityFormulaType == 1 then
        return tonumber(self.data.addProbabilityParam)
    end
    return ZhaoHurtDegreeFactory:createHurtDegreeGroup(self.data.addProbabilityParam, self.__character):getHurtValue()
end

function BuffAdderItem:getTarget()
    return self.data.addBuffTarget
end

function BuffAdderItem:getAddBuffWhen()
    return self.data.addBuffNodes
end

function BuffAdderItem:getBuffId()
    return self.data.addBuffID
end

function BuffAdderItem:getDynamicArg1()
    return self.data.addBuffdynamicArg1
end

function BuffAdderItem:getDynamicArg2()
    return self.data.addBuffdynamicArg2
end

function BuffAdderItem:getDynamicArg3()
    return self.data.addBuffdynamicArg3
end

--[[
    @desc: 判断能否添加增益
    author:TangJian
    time:2021-12-02 21:17:52
    --@fight:
	--@attacker:
	--@target: 
    @return:
]]
function BuffAdderItem:canAdd(fight, attacker, target)
    local buffAdder = self

    print("尝试添加", "添加器Id=", self:getId(), "添加buffId=", self:getBuffId())

    if self:haveCon() == false or self:__canAddBuffCondition(fight, attacker, target, self:getConditions()) then
        if not (self:getAddProbability() >= FightUtil:random(1, 100)) then
            print("添加器Id=", self:getId(), "添加buffId=", self:getBuffId(), " 添加条件不成立")
            print("有概率添加不上buff", self:getAddProbability())
            return false
        end
        print("添加器Id=", self:getId(), "添加buffId=", self:getBuffId(), " 添加条件成立")
        return true
    else
        print("添加器Id=", self:getId(), "添加buffId=", self:getBuffId(), " 添加条件不成立")
    end
    return false
end

function BuffAdderItem:__canAddBuffCondition(fight, attacker, target, addbuffConditionArray)
    local buffSystem = fight:getBuffSystem()

    local function normalCondition(condtionFunc, targets, conditionResultType, conditionParams)
        local ok = nil
        if conditionResultType == 0 then
            ok = true
            for i, target in ipairs(targets) do
                local paramOk = true
                for _, conditionParam in ipairs(conditionParams) do
                    if condtionFunc(target, conditionParam) then
                    else
                        paramOk = false
                        break
                    end
                end
                if paramOk == false then
                    ok = false
                    break
                end
            end
        elseif conditionResultType == 1 then
            ok = true
            for i, target in ipairs(targets) do
                local paramOk = false
                for _, conditionParam in ipairs(conditionParams) do
                    if condtionFunc(target, conditionParam) then
                        paramOk = true
                        break
                    end
                end
                if paramOk == false then
                    ok = false
                    break
                end
            end
        elseif conditionResultType == 2 then
            ok = false
            for i, target in ipairs(targets) do
                local paramOk = true
                for _, conditionParam in ipairs(conditionParams) do
                    if condtionFunc(target, conditionParam) then
                    else
                        paramOk = false
                        break
                    end
                end
                if paramOk == true then
                    ok = true
                    break
                end
            end
        elseif conditionResultType == 3 then
            ok = false
            for i, target in ipairs(targets) do
                local paramOk = false
                for _, conditionParam in ipairs(conditionParams) do
                    if condtionFunc(target, conditionParam) then
                        paramOk = true
                        break
                    end
                end
                if paramOk == true then
                    ok = true
                    break
                end
            end
        else
            error("conditionResultType error" .. tostring(conditionResultType))
        end

        return ok
    end

    local function conditionIsTrue(targets, conditionType, conditionResultType, conditionParams)
        local ok = nil
        if conditionType == 1 then
            -- 判断结果类型：
            --  0=每个目标持有判断条件配置的每一个BuffID、
            --  1=每个目标持有判断条件配置的任意一个BuffID、
            --  2=任意目标持有判断条件配置的每一个BuffID、
            --  3=任意目标持有判断条件配置的任意一个BuffID
            conditionParams = table.tonumber(conditionParams)
            ok =
                normalCondition(
                function(target, conditionParam)
                    return buffSystem:roleHasBuff(target:getId(), conditionParam)
                end,
                targets,
                conditionResultType,
                conditionParams
            )
        elseif conditionType == 2 then
            -- 判断条件ID：2；判断条件：持有特定BuffClass；
            --    判断结果类型：0=每个目标持有判断条件配置的每一个BuffClass、1=每个目标持有判断条件配置的任意一个BuffClass、
            --                  2=任意目标持有判断条件配置的每一个BuffClass、3=任意目标持有判断条件配置的任意一个BuffClass
            conditionParams = table.tonumber(conditionParams)
            ok =
                normalCondition(
                function(target, conditionParam)
                    return buffSystem:roleHasBuffClass(target:getId(), conditionParam)
                end,
                targets,
                conditionResultType,
                conditionParams
            )
        elseif conditionType == 3 then
            -- 判断目标条件结果配置格式：判断目标类型#判断条件ID#判断结果类型#判断条件参数@判断条件参数

            -- 判断目标类型：0=自身、1=我方队友、2=我方全体、10=敌目标、11=敌方队友、12=敌方全体
            -- 判断条件ID： 3（判断角色是否持有指定数量的 BuffID）
            -- 判断结果类型：

            -- 0=每个目标指定Buff数量判断通过
            -- 1=每个目标指定Buff数量判断不通过
            -- 2=任意目标指定Buff数量判断通过
            -- 3=任意目标指定Buff数量判断不通过


            -- 判断条件参数（多个用@间隔）：BuffID@判断方式@判断值；

            -- BuffID：需要判断持有数量的BuffID
            -- 判断方式：1=小于等于/2=大于等于/3=等于/4=小于/5=大于
            -- 判断值：判断数值，填整数
            conditionParams = table.tonumber(conditionParams)
            
            -- 判断方法
            local function panduan(target)
                if conditionParams[2] == 1 then
                    return buffSystem:getBuffCount(target:getId(), conditionParams[1]) <= conditionParams[3]
                elseif conditionParams[2] == 2 then
                    return buffSystem:getBuffCount(target:getId(), conditionParams[1]) >= conditionParams[3]
                elseif conditionParams[2] == 3 then
                    return buffSystem:getBuffCount(target:getId(), conditionParams[1]) == conditionParams[3]
                elseif conditionParams[2] == 4 then
                    return buffSystem:getBuffCount(target:getId(), conditionParams[1]) < conditionParams[3]
                elseif conditionParams[2] == 5 then
                    return buffSystem:getBuffCount(target:getId(), conditionParams[1]) > conditionParams[3]
                else
                    error("参数出错conditionType, conditionResultType, conditionParams:" .. table.tostring({conditionType, conditionResultType, conditionParams}))
                end
            end

            if conditionResultType == 0 then
                ok = table.all(table.map(targets, panduan))
            elseif conditionResultType == 1 then
                ok = not table.any(table.map(targets, panduan))
            elseif conditionResultType == 2 then
                ok = table.any(table.map(targets, panduan))
            elseif conditionResultType == 3 then
                ok = not table.all(table.map(targets, panduan))
            else
                error("参数出错conditionType, conditionResultType, conditionParams:" .. table.tostring({conditionType, conditionResultType, conditionParams}))
            end
        elseif conditionType == 10 then
            conditionParams = table.tonumber(conditionParams)
            ok =
                normalCondition(
                function(target, conditionParam)
                    return target:getWeapon():getFirstType() == conditionParam
                end,
                targets,
                conditionResultType,
                conditionParams
            )
        elseif conditionType == 11 then
            conditionParams = table.tonumber(conditionParams)

            local hasWeapon = conditionParams[1] == 1
            if conditionResultType == 0 then
                if hasWeapon then
                    ok = true
                    for i, target in ipairs(targets) do
                        if target:weaponIsEmptyHand() then
                            ok = false
                            break
                        end
                    end
                else
                    ok = true
                    for i, target in ipairs(targets) do
                        if target:weaponIsEmptyHand() then
                        else
                            ok = false
                            break
                        end
                    end
                end
            elseif conditionResultType == 1 then
                ok = false
                for i, target in ipairs(targets) do
                    if hasWeapon == false and target:weaponIsEmptyHand() then
                        ok = true
                        break
                    elseif hasWeapon and target:weaponIsEmptyHand() == false then
                        ok = true
                        break
                    end
                end
            else
                error("conditionResultType error" .. tostring(conditionResultType))
            end
        elseif conditionType == 12 then
            -- 判断条件ID：12；判断条件：不持有指定武器类型；
            --    判断结果类型：0=每个目标不持有判断条件配置的每一个武器一级分类ID、1=每个目标不持有判断条件配置的任意一个武器一级分类ID、
            --                  2=任意目标不持有判断条件配置的每一个武器一级分类ID、3=任意目标不持有判断条件配置的任意一个武器一级分类ID
            --    判断条件参数（多个用@间隔）：武器一级分类ID@武器一级分类ID；

            conditionParams = table.tonumber(conditionParams)

            ok =
                not normalCondition(
                function(target, conditionParam)
                    return target:getWeapon():getFirstType() == conditionParam
                end,
                targets,
                conditionResultType,
                conditionParams
            )
        elseif conditionType == 20 then
            -- 判断条件ID：20；判断条件：角色[条件属性值]与[需求属性值*判断值]对比；
            --    判断结果类型：0=每个目标属性判断通过、1=每个目标属性判断不通过、
            --                  2=任意目标属性判断通过、3=任意目标属性判断通过
            --    判断条件参数（多个用@间隔）：条件来源属性ID@判断方式@需求来源属性ID@判断值；
            --          条件来源属性ID与需求来源属性ID：角色属性ID（表[角色属性管理]）
            --          判断方式：1=小于等于/2=大于等于/3=等于/4=小于/5=大于；
            --          判断值：填0~1之间小数。
            -- 0#20#2#qi@1@qiMax@0.3
            local conditionAttrName = assert(conditionParams[1], "conditionAttrName is nil")
            local conditionType = assert(tonumber(conditionParams[2]), "conditionType is nil")
            local needAttrName = assert(conditionParams[3], "needAttrName is nil")
            local conditionValue = assert(tonumber(conditionParams[4]), "conditionValue is nil")

            local function conditionIsTrue(target, conditionType, conditionAttrName, needAttrName, conditionValue)
                if conditionType == 1 then
                    return target:getAttr(conditionAttrName) <= target:getAttr(needAttrName) * conditionValue
                elseif conditionType == 2 then
                    return target:getAttr(conditionAttrName) >= target:getAttr(needAttrName) * conditionValue
                elseif conditionType == 3 then
                    return target:getAttr(conditionAttrName) == target:getAttr(needAttrName) * conditionValue
                elseif conditionType == 4 then
                    return target:getAttr(conditionAttrName) < target:getAttr(needAttrName) * conditionValue
                elseif conditionType == 5 then
                    return target:getAttr(conditionAttrName) > target:getAttr(needAttrName) * conditionValue
                else
                    error("conditionType error" .. tostring(conditionType))
                end
            end

            if conditionResultType == 0 then
                ok = true
                for i, target in ipairs(targets) do
                    if not conditionIsTrue(target, conditionType, conditionAttrName, needAttrName, conditionValue) then
                        ok = false
                        break
                    end
                end
            elseif conditionResultType == 1 then
                ok = true
                for i, target in ipairs(targets) do
                    if conditionIsTrue(target, conditionType, conditionAttrName, needAttrName, conditionValue) then
                        ok = false
                        break
                    end
                end
            elseif conditionResultType == 2 then
                ok = false
                for i, target in ipairs(targets) do
                    if conditionIsTrue(target, conditionType, conditionAttrName, needAttrName, conditionValue) then
                        ok = true
                        break
                    end
                end
            elseif conditionResultType == 3 then
                ok = false
                for i, target in ipairs(targets) do
                    if not conditionIsTrue(target, conditionType, conditionAttrName, needAttrName, conditionValue) then
                        ok = true
                        break
                    end
                end
            else
                error("conditionResultType error" .. tostring(conditionResultType))
            end
        end

        return ok
    end

    for _, addbuffCondition in ipairs(addbuffConditionArray) do
        local targetType, conditionType, conditionResultType, conditionParams = addbuffCondition[1], addbuffCondition[2], addbuffCondition[3], addbuffCondition[4]

        local targets = {}

        if targetType == 0 then -- 我自己
            table.insert(targets, attacker)
        elseif targetType == 1 then -- 我队友P
            local team = fight:getFightTeamById(attacker:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                if attacker ~= character then
                    table.insert(targets, character)
                end
            end
        elseif targetType == 2 then -- 我全体
            local team = fight:getFightTeamById(attacker:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                table.insert(targets, character)
            end
        elseif targetType == 10 then -- 目标
            table.insert(targets, target)
        elseif targetType == 11 then -- 目标队友
            local team = fight:getFightTeamById(target:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                if target ~= character then
                    table.insert(targets, character)
                end
            end
        elseif targetType == 12 then -- 敌全体
            local team = fight:getFightTeamById(target:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                table.insert(targets, character)
            end
        else
            error("invalid targetType:" .. tostring(targetType))
        end

        local ok = conditionIsTrue(targets, conditionType, conditionResultType, conditionParams)

        print("添加器Id=", self:getId(), "条件组判断", ok, "conditionType=", conditionType, "conditionResultType=", conditionResultType, "conditionParams=", conditionParams)

        if ok == false then
            return false
        end
    end
    return true
end

function BuffAdderItem:setNeedAdd(b)
    self.__needAdd = b
end

function BuffAdderItem:needAdd()
    return self.__needAdd == true
end

function BuffAdderItem:getAutoAvgAtk()
    return self.__autoAvgAtk
end

--[[
    @desc: 根据添加buff
    author:TangJian
    time:2021-12-02 21:16:40
    --@fight: 战斗系统
	--@attacker: 攻击者
	--@target: 攻击目标
	--@when: 时机
    @return:
]]
function BuffAdderItem:addBuffWhen(fight, attacker, target, when, zhaoCombHitPosName)
    if self:getAddBuffWhen() == when then
        local addBuffDesc = self:getAddBuffDesc()
        if addBuffDesc then
            attacker:printDesces(
                {
                    Desc:create(
                        addBuffDesc,
                        {
                            {"$N", attacker:getAttr("name")},
                            {"$Nw", attacker:getWeapon():getName()},
                            {"$n", target:getAttr("name")},
                            {"$nw", target:getWeapon():getName()},
                            {"$l", zhaoCombHitPosName}
                        }
                    )
                }
            )
        end
        return self:addBuff(fight, attacker, target)
    elseif self:getAddBuffWhen() == -1 then
        if addBuffDesc then
            attacker:printDesces(
                {
                    Desc:create(
                        addBuffDesc,
                        {
                            {"$N", attacker:getAttr("name")},
                            {"$Nw", attacker:getWeapon():getName()},
                            {"$n", target:getAttr("name")},
                            {"$nw", target:getWeapon():getName()},
                            {"$l", zhaoCombHitPosName}
                        }
                    )
                }
            )
        end
        return self:addBuff(fight, attacker, target)
    end
    return false, {}
end

--[[
    @desc: 添加buff
    author:TangJian
    time:2021-12-02 21:16:07
    --@fight: 战斗系统
	--@attacker: 攻击者
	--@target: 攻击目标
    @return:
]]
function BuffAdderItem:addBuff(fight, attacker, target)
    local buffSystem = fight:getBuffSystem()

    local retBuffExecutors = {}

    local buffId, dynamicArg1, dynamicArg2, dynamicArg3 = self:getBuffId(), self:getDynamicArg1(), self:getDynamicArg2(), self:getDynamicArg3()

    if self:needAdd() then
        print("添加器Id=", self:getId(), buffId, "添加成功")
        local targetType = self:getTarget()
        local autoAvgAtk = FightFormula:calQiAvgDamage(attacker, target)
        if targetType == 0 then -- 我自己
             table.insert(retBuffExecutors, attacker:addBuff(attacker, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, self:getAddProbability()))
        elseif targetType == 1 then -- 我队友P
            local team = fight:getFightTeamById(attacker:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                if attacker ~= character then
                    table.insert(retBuffExecutors, character:addBuff(attacker, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, self:getAddProbability()))
                end
            end
        elseif targetType == 2 then -- 我全体
            local team = fight:getFightTeamById(attacker:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                table.insert(retBuffExecutors, character:addBuff(attacker, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, self:getAddProbability()))
            end
        elseif targetType == 10 then -- 目标
            table.insert(retBuffExecutors, target:addBuff(attacker, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, self:getAddProbability()))
        elseif targetType == 11 then -- 目标队友
            local team = fight:getFightTeamById(target:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                if target ~= character then
                    table.insert(retBuffExecutors, character:addBuff(attacker, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, self:getAddProbability()))
                end
            end
        elseif targetType == 12 then -- 敌全体
            local team = fight:getFightTeamById(target:getTeamId())
            for _, character in ipairs(team:getCharacters()) do
                table.insert(retBuffExecutors, character:addBuff(attacker, buffId, autoAvgAtk, dynamicArg1, dynamicArg2, dynamicArg3, self:getAddProbability()))
            end
        else
            error("targetType异常:" .. tostring(targetType))
        end
    else
        print(buffId, "添加失败", self)
    end
    return retBuffExecutors
end

return class("BuffAdderItem", {}, BuffAdderItem)
0000000