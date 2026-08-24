--[[
    author:Seven
    time:2024-01-05 16:50:35
    desc: 先天属性分配方案类
]]
local newClass = require("third.class.NewClass")

local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")

local INaturalPlan = {}

local BasicNaturalPlan = {}

function BasicNaturalPlan:create(...)
    return BasicNaturalPlan.new():__init(...)
end

function BasicNaturalPlan:ctor()
    self.__dict = {}
    self.__tempAssignDict = {}
    for k, v in pairs(NaturalAttrAdjustmentConst.ATTR_TYPE) do
        self.__dict[v] = 0
        self.__tempAssignDict[v] = 0
    end
end

function BasicNaturalPlan:__init(planType, name, maxPoints, isEnable)
    self:setNaturalPlanType(planType)
    self:setMaxAssignablePoints(maxPoints)
    self:setNaturalPlanName(name)
    self:setEnable(isEnable)
    return self
end

--@desc: 设置方案类型
--@author:Seven
--@time:2024-01-05 16:54:35
--@planType: string
--@return:
function BasicNaturalPlan:setNaturalPlanType(planType)
    if table.keyof(NaturalAttrAdjustmentConst.PLAN_TYPE, planType) == nil then
        error("BasicNaturalPlan:setNaturalPlanType 方案类型错误" .. tostring(planType))
    end

    self.__planType = planType
end

--@desc: 获取当前使用方案类型
--@author:Seven
--@time:2024-01-05 16:54:22
--@return: string
function BasicNaturalPlan:getNaturalPlanType()
    return self.__planType
end

function BasicNaturalPlan:setEnable(bool)
    self.__isEnable = bool
end

--@desc: 是否启用
--@author:Seven
--@time:2024-01-08 20:52:18
--@return: true | false
function BasicNaturalPlan:isEnable()
    return self.__isEnable
end

--@desc: 设置当前方案名称
--@author:Seven
--@time:2024-01-05 18:11:21
--@name: string
function BasicNaturalPlan:setNaturalPlanName(name)
    self.__name = name
end

--@desc: 获取当前方案名称
--@author:Seven
--@time:2024-01-05 18:11:37
--@return: string
function BasicNaturalPlan:getNaturalPlanName()
    return self.__name
end

--@desc: 设置先天属性值
--@author:Seven
--@time:2024-01-05 16:55:14
--@attrName: string
--@value: number
--@return: nil
function BasicNaturalPlan:setNaturalPlanAttr(attrName, value)
    if self.__dict[attrName] == nil then
        error("BasicNaturalPlan:setNaturalPlanAttr 属性名错误" .. tostring(attrName))
    end
    self.__dict[attrName] = value
end

--@desc: 获取先天属性值
--@author:Seven
--@time:2024-01-05 16:55:32
--@attrName:
--@return:
function BasicNaturalPlan:getNaturalPlanAttr(attrName)
    return self.__dict[attrName]
end

--@desc: 获取当前方案属性字典，key为属性名，value为属性值，如{str = 10, dex = 10, int = 10, con = 10}
--@author:Seven
--@time:2024-01-05 16:56:06
function BasicNaturalPlan:getNaturalPlanAttrDict()
    return self.__dict
end

local keyValueChange = function(key, value)
    return {attrName = key, attrValue = value}
end

function BasicNaturalPlan:getNaturalPlanAttrList()
    local attrList = {}
    table.insert(attrList, keyValueChange(NaturalAttrAdjustmentConst.ATTR_TYPE.STR, self:getNaturalPlanAttr(NaturalAttrAdjustmentConst.ATTR_TYPE.STR)))
    table.insert(attrList, keyValueChange(NaturalAttrAdjustmentConst.ATTR_TYPE.DEX, self:getNaturalPlanAttr(NaturalAttrAdjustmentConst.ATTR_TYPE.DEX)))
    table.insert(attrList, keyValueChange(NaturalAttrAdjustmentConst.ATTR_TYPE.CON, self:getNaturalPlanAttr(NaturalAttrAdjustmentConst.ATTR_TYPE.CON)))
    table.insert(attrList, keyValueChange(NaturalAttrAdjustmentConst.ATTR_TYPE.INT, self:getNaturalPlanAttr(NaturalAttrAdjustmentConst.ATTR_TYPE.INT)))
    return attrList
end

function BasicNaturalPlan:setMaxAssignablePoints(points)
    self.__maxPoints = points
end

function BasicNaturalPlan:__getTotalCount()
    local value = 0
    for k, v in pairs(self.__dict) do
        value = value + v
    end

    for k, v in pairs(self.__tempAssignDict) do
        value = value + v
    end

    return value
end

--@desc: 设置临时分配点数
--@author:Seven
--@time:2024-01-10 15:26:47
--@value: number
function BasicNaturalPlan:setNaturalAttrTempAssignablePoint(attrName, value)
    self.__tempAssignDict[attrName] = value
end

--@desc: 获取临时分配点数
--@author:Seven
--@time:2024-01-10 15:27:07
--@return: number
function BasicNaturalPlan:getNaturalAttrTempAssignablePoint(attrName)
    return self.__tempAssignDict[attrName]
end

--@desc: 获取当前方案可分配点数
--@author:Seven
--@time:2024-01-05 16:56:29
--@return: number
function BasicNaturalPlan:getAssignablePoints()
    local totalCount = self:__getTotalCount()

    if totalCount > self.__maxPoints then
        error("BasicNaturalPlan:getAssignablePoints 可分配点数错误" .. tostring(totalCount) .. ", 最大点数为：" .. tostring(self.__maxPoints))
    end

    return self.__maxPoints - self:__getTotalCount()
end

return newClass("BasicNaturalPlan", {INaturalPlan}, BasicNaturalPlan)
00000