--[[
    主动技能、buff 共用
    
    计算伤害强度值

    -- id : 编号
    -- hurtDegreeID : 攻击伤害强度ID
    -- order : 条件判断顺序
    -- attrType : 条件属性
    -- condition : 条件判断
    -- conditionValue : 条件值
    -- formulaType : 公式类型
    -- variablesList：公式变量组自身属性
    -- variablesListTarget：公式变量组目标属性
    -- param_a : 公式参数a
    -- param_b : 公式参数b
    -- param_c : 公式参数c
    -- param_d : 公式参数d
    -- param_e : 公式参数e
    -- param_maxL : 公式参数maxL
    -- param_rmin : 公式参数rmin
    -- param_rmax : 公式参数rmax

]]
local class = require("third.class.NewClass")

local HurtDegree = {
    __hureDegreeRes = nil,
    --@desc 自身动态变量字典，x变量：x1、x2、x3...
    __dynamicVarMap = {},
    --@desc 目标动态变量字典，y变量：y1、y2、y3...
    __targetDynamicVarMap = {},
    __currConditionValue = 0
}

HurtDegree.VAR_TYPE = {
    ROLE = "role",
    WEAPON = "weapon",
    BUFF_ATTR = "buffclassnum",
    FISTFOOT = "foot",
    BUFFID_NUM = "buffidnum",
    BATTLE = "battle",
    SKILL_LEVEL = "skilllv"
}

function HurtDegree:create()
    return self.new()
end

function HurtDegree:setHurtDegreeRes(res)
    self.__hureDegreeRes = res
end

function HurtDegree:getId()
    return self.__hureDegreeRes.id
end

function HurtDegree:getHurtDegreeID()
    return self.__hureDegreeRes.hurtDegreeID
end

function HurtDegree:getOrder()
    return self.__hureDegreeRes.order
end

function HurtDegree:getAttTypeClass()
    return self.__hureDegreeRes.attrTypeClass
end

function HurtDegree:getAttrType()
    return self.__hureDegreeRes.attrType
end

function HurtDegree:getCondition()
    return self.__hureDegreeRes.condition
end

function HurtDegree:getConditionValue()
    return self.__hureDegreeRes.conditionValue
end

function HurtDegree:getFormulaType()
    return self.__hureDegreeRes.formulaType
end

function HurtDegree:getParam_a()
    return self.__hureDegreeRes.param_a
end

function HurtDegree:getParam_b()
    return self.__hureDegreeRes.param_b
end

function HurtDegree:getParam_c()
    return self.__hureDegreeRes.param_c
end

function HurtDegree:getParam_d()
    return self.__hureDegreeRes.param_d
end

function HurtDegree:getParam_e()
    return self.__hureDegreeRes.param_e
end

function HurtDegree:getParam_maxL()
    return self.__hureDegreeRes.param_maxL
end

function HurtDegree:getParam_rmin()
    return self.__hureDegreeRes.param_rmin
end

function HurtDegree:getParam_rmax()
    return self.__hureDegreeRes.param_rmax
end

function HurtDegree:getVariables()
    local list = {}
    if self.__hureDegreeRes.variablesList then
        local var_group = string.split(self.__hureDegreeRes.variablesList, "|")

        for i = 1, #var_group do
            local var_obj = string.split(var_group[i], "#")
            table.insert(
                list,
                {
                    value_type = var_obj[1],
                    value_name = var_obj[2]
                }
            )
        end
    end

    return list
end

function HurtDegree:getVariablesTarget()
    local list = {}
    if self.__hureDegreeRes.variablesListTarget then
        local var_group = string.split(self.__hureDegreeRes.variablesListTarget, "|")

        for i = 1, #var_group do
            local var_obj = string.split(var_group[i], "#")
            table.insert(
                list,
                {
                    value_type = var_obj[1],
                    value_name = var_obj[2]
                }
            )
        end
    end

    return list
end

--@region 运行时动态变量
function HurtDegree:setDynamicVariables(value_list)
    if MapIsEmpty(value_list) then
        return
    end

    -- 清空之前的动态变量
    self.__dynamicVarMap = {}

    for i, value in ipairs(value_list) do
        self.__dynamicVarMap["x" .. i] = value
    end
end

function HurtDegree:getDynamicVariablesByKey(key)
    if self.__dynamicVarMap[key] == nil then
        error("HurtDegree:getDynamicVariablesByKey key:" .. tostring(key) .. " not found ，id:" .. tostring(self:getId()))
    end

    return self.__dynamicVarMap[key]
end

function HurtDegree:setTargetDynamicVariables(value_list)
    if MapIsEmpty(value_list) then
        return
    end
    -- 清空之前的目标动态变量
    self.__targetDynamicVarMap = {}
    for i, value in ipairs(value_list) do
        self.__targetDynamicVarMap["y" .. i] = value
    end
end

function HurtDegree:getTargetDynamicVariablesByKey(key)
    if self.__targetDynamicVarMap[key] == nil then
        error("HurtDegree:getTargetDynamicVariablesByKey key:" .. tostring(key) .. " not found ，id:" .. tostring(self:getId()))
    end

    return self.__targetDynamicVarMap[key]
end

function HurtDegree:setCurrConditionValue(value)
    self.__currConditionValue = value
end
--@endregion

function HurtDegree:__checkCondition()
    -- 大于、大于等于、小于、小于等于、等于
    local isBool =
        switch(
        self:getCondition(),
        {
            ["大于"] = function()
                if self.__currConditionValue > self:getConditionValue() then
                    return true
                end
                return false
            end,
            ["大于等于"] = function()
                if self.__currConditionValue >= self:getConditionValue() then
                    return true
                end
                return false
            end,
            ["小于"] = function()
                if self.__currConditionValue < self:getConditionValue() then
                    return true
                end
                return false
            end,
            ["小于等于"] = function()
                if self.__currConditionValue <= self:getConditionValue() then
                    return true
                end
                return false
            end,
            ["等于"] = function()
                if self.__currConditionValue == self:getConditionValue() then
                    return true
                end
                return false
            end,
            default = true
        }
    )

    return isBool
end

function HurtDegree:matchCondititon()
    return self:__checkCondition()
end

function HurtDegree:getHurtValue()
    local FightFormula = require("app.FightSystem.FightFormula")
    local value =
        switch(
        self:getFormulaType(),
        {
            [1001] = function()
                return FightFormula:calActiveHurtDrgreeValue1001(
                    self:getDynamicVariablesByKey("x1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1002] = function()
                return FightFormula:calActiveHurtDrgreeValue1002(
                    self:getDynamicVariablesByKey("x1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1003] = function()
                return FightFormula:calActiveHurtDrgreeValue1003(
                    self:getDynamicVariablesByKey("x1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1004] = function()
                return FightFormula:calActiveHurtDrgreeValue1004(
                    self:getDynamicVariablesByKey("x1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1005] = function()
                return FightFormula:calActiveHurtDrgreeValue1005(
                    self:getDynamicVariablesByKey("x1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1201] = function()
                return FightFormula:calActiveHurtDrgreeValue1201(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1202] = function()
                return FightFormula:calActiveHurtDrgreeValue1202(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1203] = function()
                return FightFormula:calActiveHurtDrgreeValue1203(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1204] = function()
                return FightFormula:calActiveHurtDrgreeValue1204(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1205] = function()
                return FightFormula:calActiveHurtDrgreeValue1205(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1206] = function()
                return FightFormula:calActiveHurtDrgreeValue1206(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1207] = function()
                return FightFormula:calActiveHurtDrgreeValue1207(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1208] = function()
                return FightFormula:calActiveHurtDrgreeValue1208(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1209] = function()
                return FightFormula:calActiveHurtDrgreeValue1209(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1210] = function()
                return FightFormula:calActiveHurtDrgreeValue1210(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1211] = function()
                return FightFormula:calActiveHurtDrgreeValue1211(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1212] = function()
                return FightFormula:calActiveHurtDrgreeValue1212(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1213] = function()
                return FightFormula:calActiveHurtDrgreeValue1213(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1214] = function()
                return FightFormula:calActiveHurtDrgreeValue1214(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1215] = function()
                return FightFormula:calActiveHurtDrgreeValue1215(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1216] = function()
                return FightFormula:calActiveHurtDrgreeValue1216(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1217] = function()
                return FightFormula:calActiveHurtDrgreeValue1217(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1301] = function()
                return FightFormula:calActiveHurtDrgreeValue1301(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1302] = function()
                return FightFormula:calActiveHurtDrgreeValue1302(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1303] = function()
                return FightFormula:calActiveHurtDrgreeValue1303(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1401] = function()
                return FightFormula:calActiveHurtDrgreeValue1401(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1402] = function()
                return FightFormula:calActiveHurtDrgreeValue1402(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1403] = function()
                return FightFormula:calActiveHurtDrgreeValue1403(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1404] = function()
                return FightFormula:calActiveHurtDrgreeValue1404(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1405] = function()
                return FightFormula:calActiveHurtDrgreeValue1405(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1406] = function()
                return FightFormula:calActiveHurtDrgreeValue1406(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1407] = function()
                return FightFormula:calActiveHurtDrgreeValue1407(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1408] = function()
                return FightFormula:calActiveHurtDrgreeValue1408(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1409] = function()
                return FightFormula:calActiveHurtDrgreeValue1409(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1410] = function()
                return FightFormula:calActiveHurtDrgreeValue1410(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1601] = function()
                return FightFormula:calActiveHurtDrgreeValue1601(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getDynamicVariablesByKey("x4"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1602] = function()
                return FightFormula:calActiveHurtDrgreeValue1602(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getDynamicVariablesByKey("x4"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1603] = function()
                return FightFormula:calActiveHurtDrgreeValue1603(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getDynamicVariablesByKey("x4"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1604] = function()
                return FightFormula:calActiveHurtDrgreeValue1604(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getDynamicVariablesByKey("x4"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [1605] = function()
                return FightFormula:calActiveHurtDrgreeValue1605(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getDynamicVariablesByKey("x3"),
                    self:getDynamicVariablesByKey("x4"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [2004] = function()
                return FightFormula:calActiveHurtDrgreeValue2004(
                    self:getTargetDynamicVariablesByKey("y1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [2401] = function()
                return FightFormula:calActiveHurtDrgreeValue2401(
                    self:getTargetDynamicVariablesByKey("y1"),
                    self:getTargetDynamicVariablesByKey("y2"),
                    self:getTargetDynamicVariablesByKey("y3"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [3001] = function()
                return FightFormula:calActiveHurtDrgreeValue3001(
                    self:getDynamicVariablesByKey("x1"),
                    self:getTargetDynamicVariablesByKey("y1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [3002] = function()
                return FightFormula:calActiveHurtDrgreeValue3002(
                    self:getDynamicVariablesByKey("x1"),
                    self:getTargetDynamicVariablesByKey("y1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [3003] = function()
                return FightFormula:calActiveHurtDrgreeValue3003(
                    self:getDynamicVariablesByKey("x1"),
                    self:getTargetDynamicVariablesByKey("y1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [3201] = function()
                return FightFormula:calActiveHurtDrgreeValue3201(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getTargetDynamicVariablesByKey("y1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end,
            [3202] = function()
                return FightFormula:calActiveHurtDrgreeValue3202(
                    self:getDynamicVariablesByKey("x1"),
                    self:getDynamicVariablesByKey("x2"),
                    self:getTargetDynamicVariablesByKey("y1"),
                    self:getParam_a(),
                    self:getParam_b(),
                    self:getParam_c(),
                    self:getParam_d(),
                    self:getParam_e(),
                    self:getParam_maxL(),
                    self:getParam_rmin(),
                    self:getParam_rmax()
                )
            end
        }
    )

    return value
end

return class("HurtDegree", {}, HurtDegree)
000000000000