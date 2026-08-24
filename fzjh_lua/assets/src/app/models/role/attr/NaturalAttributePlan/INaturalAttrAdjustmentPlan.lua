--[[
    author:Seven
    time:2024-01-05 11:23:43
    desc: 先天属性加点调整接口
]]
local interface = require("third.class.interface")

local INaturalAttrAdjustmentPlan = {}

--@desc: 获取当前使用方案类型
--@author:Seven
--@time:2024-01-05 11:28:23
--@return:
function INaturalAttrAdjustmentPlan:getUsagePlanType()
end

--@desc: 获取当前使用方案相关数据
--@author:Seven
--@time:2024-01-05 11:30:38
--@return [src.app.models.role.attr.NaturalAttributePlan.INaturalPlan#INaturalPlan]
function INaturalAttrAdjustmentPlan:getUsagePlan()
end

--@desc: 根据方案类型获取方案数据
--@author:Seven
--@time:2024-01-05 16:16:05
--@planType:
--@return:
function INaturalAttrAdjustmentPlan:getPlanByType(planType)
end

--@desc: 使用调整方案
--@author:Seven
--@time:2024-01-05 11:29:20
--@planType: 方案类型
--@planAttrDict: 方案属性字典
--@return:
function INaturalAttrAdjustmentPlan:useAttrAdjustmentPlanType(planType)
end

--@desc: 获取切换方案道具消耗列表
--@author:Seven
--@time:2024-01-05 14:13:05
--@return:
function INaturalAttrAdjustmentPlan:getSwitchPlanCostItemList()
end

--@desc: 获取加点属性分配方案列表
--@author:Seven
--@time:2024-01-08 14:16:19
--@return array [src.app.models.role.attr.NaturalAttributePlan.INaturalPlan#INaturalPlan]
function INaturalAttrAdjustmentPlan:getAdjustmentPlanArray()
end

--@desc:
--@author:Seven
--@time:2024-01-10 16:29:09
--@index: 索引
--@return true | false
function INaturalAttrAdjustmentPlan:checkCanCostItem(index)
end

--@desc: 切换方案接口
--@selectCostItemIndex: 消耗物品索引
--@planType: 方案类型
--@return true | false , msg
function INaturalAttrAdjustmentPlan:switchAttrAdjustmentPlan(selectCostItemIndex, planType)
end

return interface("INaturalAttrAdjustmentPlan", INaturalAttrAdjustmentPlan)
000000