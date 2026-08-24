--[[
    author:Seven
    time:2024-01-05 16:50:35
    desc: 先天属性分配方案类
]]
local interface = require("third.class.interface")

local INaturalPlan = {}

--@desc: 设置方案类型
--@author:Seven
--@time:2024-01-05 16:54:35
--@planType: string
--@return:
function INaturalPlan:setNaturalPlanType(planType)
end

function INaturalPlan:setEnable(bool)
end

--@desc: 是否启用
--@author:Seven
--@time:2024-01-08 20:52:18
--@return: true | false
function INaturalPlan:isEnable()
end

--@desc: 获取当前使用方案类型
--@author:Seven
--@time:2024-01-05 16:54:22
--@return: string
function INaturalPlan:getNaturalPlanType()
end

--@desc: 设置当前方案名称
--@author:Seven
--@time:2024-01-05 18:11:21
--@name: string
function INaturalPlan:setNaturalPlanName(name)
end

--@desc: 获取当前方案名称
--@author:Seven
--@time:2024-01-05 18:11:37
--@return: string
function INaturalPlan:getNaturalPlanName()
end

--@desc: 设置先天属性值
--@author:Seven
--@time:2024-01-05 16:55:14
--@attrName: string
--@value: number
--@return: nil
function INaturalPlan:setNaturalPlanAttr(attrName, value)
end

--@desc: 获取先天属性值
--@author:Seven
--@time:2024-01-05 16:55:32
--@attrName:
--@return:
function INaturalPlan:getNaturalPlanAttr(attrName)
end

--@desc: 设置临时分配点数
--@author:Seven
--@time:2024-01-10 15:26:47
--@value: number
function INaturalPlan:setNaturalAttrTempAssignablePoint(atrrName, value)
end

--@desc: 获取临时分配点数
--@author:Seven
--@time:2024-01-10 15:27:07
--@return: number
function INaturalPlan:getNaturalAttrTempAssignablePoint(attrName)
end

--@desc: 获取当前方案属性字典，key为属性名，value为属性值，如{str = 10, dex = 10, int = 10, con = 10}
--@author:Seven
--@time:2024-01-05 16:56:06
function INaturalPlan:getNaturalPlanAttrDict()
end

function INaturalPlan:getNaturalPlanAttrList()
end

--@desc: 设置最大可分配点数
--@author:Seven
--@time:2024-01-08 21:05:51
--@points: number
function INaturalPlan:setMaxAssignablePoints(points)
end

--@desc: 获取当前方案可分配点数
--@author:Seven
--@time:2024-01-05 16:56:29
--@return: number
function INaturalPlan:getAssignablePoints()
end

return interface("INaturalPlan", INaturalPlan)
00000000000