--[[
    author:Seven
    time:2023-03-07 15:27:21
    desc: buff添加器基础资源类
]]
local newClass = require("third.class.NewClass")

local BasicBuffAdderRes = {}

function BasicBuffAdderRes:create(addType, res)
    return BasicBuffAdderRes.new():__init(addType, res)
end

function BasicBuffAdderRes:__init(addType, res)
    self.__type = addType

    self.__res = res

    local BuffConf = require("app.FightSystem.Configuration.BuffConf")

    self.__defaulfRes = BuffConf:getBuffAdderDefault(self.__type)

    return self
end

-- 编号;
function BasicBuffAdderRes:getId()
    return self.__res.id
end

function BasicBuffAdderRes:getAdderType()
    return self.__type
end

-- buff添加器;
function BasicBuffAdderRes:getBuffLauncher()
    return self.__res.buffLauncher
end

-- 添加器触发时机类型;triggerType
function BasicBuffAdderRes:getTriggerType()
    return self:__getValue("triggerType")
end

-- 判断顺序;
function BasicBuffAdderRes:getOrder()
    return tonumber(self:__getValue("order"))
end

-- 添加是否需要判断;
function BasicBuffAdderRes:getHaveCon()
    return self:__getValue("haveCon")
end

-- 前置判断order;
function BasicBuffAdderRes:getIdPrerequisites()
    return self:__getValue("idPrerequisites")
end

-- 添加概率计算类型;addProbabilityFormulaType
function BasicBuffAdderRes:getAddProbabilityFormulaType()
    return self:__getValue("addProbabilityFormulaType")
end

-- 添加概率;
function BasicBuffAdderRes:getAddProbabilityParam()
    return self:__getValue("addProbabilityParam")
end

-- 判断目标条件结果;
function BasicBuffAdderRes:getAddConditions()
    if self.__addConditions == nil then
        self.__addConditions = {}
        local conditionStrs = self:__getValue("addConditions")

        if conditionStrs ~= nil then
            local condionList = string.split(conditionStrs, "|")

            for i, str in ipairs(condionList) do
                -- 判断目标类型#判断条件ID#判断结果类型#判断条件参数@判断条件参数
                local spiltList = string.split(str, "#")

                table.insert(self.__addConditions, spiltList)
            end
        end
    end

    return self.__addConditions
end

-- Buff添加目标;
function BasicBuffAdderRes:getAddBuffTarget()
    return self:__getValue("addBuffTarget")
end

-- 添加Buff节点;
function BasicBuffAdderRes:getAddBuffNodes()
    return self:__getValue("addBuffNodes")
end

-- 战场BuffID;
function BasicBuffAdderRes:getAddBuffID()
    return self:__getValue("addBuffID")
end

-- Buff效果参数1;
function BasicBuffAdderRes:getAddBuffdynamicArg1()
    return self:__getValue("addBuffdynamicArg1")
end

-- Buff效果参数2;
function BasicBuffAdderRes:getAddBuffdynamicArg2()
    return self:__getValue("addBuffdynamicArg2")
end

-- Buff效果参数3;
function BasicBuffAdderRes:getAddBuffdynamicArg3()
    return self:__getValue("addBuffdynamicArg3")
end

-- Buff效果参数4;
function BasicBuffAdderRes:getAddBuffdynamicArg4()
    return self:__getValue("addBuffdynamicArg4")
end

-- 添加概率;
function BasicBuffAdderRes:getAddProbability()
    return self:__getValue("addProbability")
end

-- 添加器触发时输出文本;addBuffDesc
function BasicBuffAdderRes:getAddBuffDesc()
    return self:__getValue("addBuffDesc")
end

-- 加权随机添加器;weightedLauncher
function BasicBuffAdderRes:getWeightedLauncher()
    return self:__getValue("weightedLauncher")
end

-- 加权随机权值;weight
function BasicBuffAdderRes:getWeight()
    return self:__getValue("weight")
end

function BasicBuffAdderRes:__getValue(name)
    local value = self.__res[name]
    if value == nil and self.__defaulfRes[name] ~= -1 then
        value = self.__defaulfRes[name]
    end
    return value
end

return newClass("BasicBuffAdderRes", {}, BasicBuffAdderRes)
00000