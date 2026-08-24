--[[
    author:Seven
    time:2024-01-08 15:17:00
    desc:
]]
local newClass = require("third.class.NewClass")

local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")

local NaturalAttrUtil = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrUtil")

local BasicNaturalPlan = require("app.models.role.attr.NaturalAttributePlan.BasicNaturalPlan")

local NaturalAttrjustmentPlanRecord = require("app.models.Record.NaturalAttrjustmentPlanRecord.NaturalAttrjustmentPlanRecord")

local INaturalAttrAdjustmentPlan = require("app.models.role.attr.NaturalAttributePlan.INaturalAttrAdjustmentPlan")

local SkillConst = require("app.models.skill.SkillConst")

--@SuperType [src.app.models.role.attr.NaturalAttributePlan.INaturalAttrAdjustmentPlan#INaturalAttrAdjustmentPlan]
local PlayerNaturalAttrAdjustmentPlan = {}

function PlayerNaturalAttrAdjustmentPlan:create(role)
    return PlayerNaturalAttrAdjustmentPlan:new():__init(role)
end

function PlayerNaturalAttrAdjustmentPlan:ctor()
    self.__dict = {}
end

function PlayerNaturalAttrAdjustmentPlan:__init(role)
    self.__role = role

    local adjustmenPlanData = self.__role:getAndInitNaturalAttrAdjustmentPlanData()

    self.__usage = adjustmenPlanData.usage

    local planDict = adjustmenPlanData.planDict

    local maxPoints = NaturalAttrUtil:getPlayerMaxAssignablePoints(self.__role:getAttr("inheritCount"))

    self.__dict[NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN] =
        self:__initPlan(
        NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN,
        NaturalAttrAdjustmentConst.PLAN_TYPE_NAME[NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN],
        maxPoints,
        true,
        planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN]
    )

    self.__dict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] =
        self:__initPlan(
        NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN,
        NaturalAttrAdjustmentConst.PLAN_TYPE_NAME[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN],
        maxPoints,
        planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] ~= nil,
        planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN]
    )

    return self
end

function PlayerNaturalAttrAdjustmentPlan:__initPlan(planType, name, maxPoints, isEnable, data)
    local basePlan = BasicNaturalPlan:create(planType, name, maxPoints, isEnable)

    if data ~= nil then
        for k, v in pairs(data) do
            basePlan:setNaturalPlanAttr(k, v)
        end
    end

    return basePlan
end

--@desc: 获取当前使用方案类型
--@author:Seven
--@time:2024-01-05 11:28:23
--@return:
function PlayerNaturalAttrAdjustmentPlan:getUsagePlanType()
    return self.__usage
end

--@desc: 获取当前使用方案相关数据
--@author:Seven
--@time:2024-01-05 11:30:38
--@return:
function PlayerNaturalAttrAdjustmentPlan:getUsagePlan()
    return self:getPlanByType(self.__usage)
end

--@desc: 根据方案类型获取方案数据
--@author:Seven
--@time:2024-01-05 16:16:05
--@planType:
--@return [src.app.models.role.attr.NaturalAttributePlan.INaturalPlan#INaturalPlan]
function PlayerNaturalAttrAdjustmentPlan:getPlanByType(planType)
    if table.keyof(NaturalAttrAdjustmentConst.PLAN_TYPE, planType) == nil then
        error("PlayerNaturalAttrAdjustmentPlan:getPlanByType 方案类型错误" .. tostring(planType))
    end

    return self.__dict[planType]
end

--@desc: 切换方案
--@author:Seven
--@time:2024-01-10 17:32:11
--@selectCostItemIndex: 消耗物品索引
--@planType: 方案类型
--@return
function PlayerNaturalAttrAdjustmentPlan:switchAttrAdjustmentPlan(selectCostItemIndex, planType)
    if self:checkCanCostItem(selectCostItemIndex) == false then
        local selectInfo = self:getSwitchPlanCostItemList()[selectCostItemIndex]
        return false, string.format("%s不足，切换先天属性失败", self.__role:getOneItemByKey(selectInfo.id).name)
    end

    local costItem = self:getSwitchPlanCostItemList()[selectCostItemIndex]

    local result = self:__costItem(costItem.id, costItem.count)

    if result == false then
        return false, "物品消耗失败"
    end

    local oldPlan = Helper:tableCover({}, self.__role:getAndInitNaturalAttrAdjustmentPlanData())

    self:__useAttrAdjustmentPlanType(planType)

    local newPlan = Helper:tableCover({}, self.__role:getAndInitNaturalAttrAdjustmentPlanData())

    self:__record(
        NaturalAttrjustmentPlanRecord.R_TYPE.SWITCH,
        oldPlan.planDict,
        newPlan.planDict,
        {
            itemId = costItem.id,
            count = costItem.count
        }
    )

    return true
end

function PlayerNaturalAttrAdjustmentPlan:__costItem(itemId, count)
    if count == 0 then
        return true
    elseif count < 0 then
        error("消耗数量不可小于0")
    end

    local ServerItemConst = require("app.models.item.ServerItemConst")
    if table.keyof(ServerItemConst.SERVER_ITEM_ID, itemId) ~= nil then
        local result = false

        HttpManagerEx:checkItemIsCanUse(
            itemId,
            count,
            function(status, errcode, errmsg, data)
                if status == 200 then
                    if errcode == 0 then
                        self.__role:addItemCount(itemId, -count)
                        result = true
                    else
                        PopText("物品未通过正品检测，请购买正品")
                        return
                    end
                else
                    PopText(errmsg)
                end
            end,
            IS_SHOW_WAITING
        )

        return result
    else
        self.__role:addItemCount(itemId, -count)

        return true
    end
end

--@desc: 使用调整方案
--@author:Seven
--@time:2024-01-05 11:29:20
--@planType: 方案类型
--@planAttrDict: 方案属性字典
--@return:
function PlayerNaturalAttrAdjustmentPlan:useAttrAdjustmentPlanType(planType)
    local oldPlan = Helper:tableCover({}, self.__role:getAndInitNaturalAttrAdjustmentPlanData())

    self:__useAttrAdjustmentPlanType(planType)

    local newPlan = Helper:tableCover({}, self.__role:getAndInitNaturalAttrAdjustmentPlanData())

    self:__record(NaturalAttrjustmentPlanRecord.R_TYPE.ADJUSTMENT, oldPlan.planDict, newPlan.planDict, nil)
end

function PlayerNaturalAttrAdjustmentPlan:__useAttrAdjustmentPlanType(planType)
    if table.keyof(NaturalAttrAdjustmentConst.PLAN_TYPE, planType) == nil then
        error("PlayerNaturalAttrAdjustmentPlan:useAttrAdjustmentPlanType 方案类型错误" .. tostring(planType))
    end

    local plan = self:getPlanByType(planType)

    local planAttrDict = plan:getNaturalPlanAttrDict()

    for k, v in pairs(planAttrDict) do
        local tempValue = plan:getNaturalAttrTempAssignablePoint(k)
        plan:setNaturalPlanAttr(k, v + tempValue)
        plan:setNaturalAttrTempAssignablePoint(k, 0)
    end

    local newPlanAttrDict = plan:getNaturalPlanAttrDict()

    local updateAttrDict = {}

    local beforeNeiLiMax = self.__role:getFinalAttr("neiliMax")

    local beforeNeiLiLimit = self.__role:getFinalAttr("neiLiLimit")

    local beforeNeiLi = self.__role:getAttr("neili")

    --[[
        每次修改先天属性会矫正打坐内力上限与当前内力上限，计算时属性值非当前实际值（已修改的属性为实际值，未修改的为原值）导致内力上限异常
        若打坐内力上限变小了，且当前内力上限大于打坐内力上限时，则需要把当前内力上限值压到打坐内力上限
        若打坐内力上限变大了，则当前内力上限则不变
    ]]

    for k, v in pairs(newPlanAttrDict) do
        updateAttrDict[k] = v
        self.__role:setNaturalAttr(k, v)
    end

    local afterNeiLiLimit = self.__role:getFinalAttr("neiLiLimit")

    --打坐内力上限变小了后，且当前内力上限大于打坐内力上限时，需要压当前内力上限，其他情况则当前内力上限不变
    if afterNeiLiLimit < beforeNeiLiLimit and beforeNeiLiMax > afterNeiLiLimit then
        self.__role:setAttr("neiliMax", afterNeiLiLimit)
    else
        self.__role:setAttr("neiliMax", beforeNeiLiMax)
    end
    --同理当前内力也需要处理
    if afterNeiLiLimit < beforeNeiLiLimit and beforeNeiLi > afterNeiLiLimit * 2 then
        self.__role:setAttr("neili", afterNeiLiLimit * 2)
    else
        self.__role:setAttr("neili", beforeNeiLi)
    end

    self.__usage = planType

    self.__role:updatePlayerUsageNaturalAttrAdjustmentPlan(self.__usage)

    self.__role:updatePlayerNaturalAttrAdjustmentPlanData(plan)
end

--@desc: 获取切换方案道具消耗列表
--@author:Seven
--@time:2024-01-05 14:13:05
--@return:
function PlayerNaturalAttrAdjustmentPlan:getSwitchPlanCostItemList()
    local skill = Skill:getSkill(SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch"))
    local roleSkill = self.__role:getSkill(skill.id)

    local lv = skill:getLv(roleSkill.exp)

    --@RefType [src.app.models.skill.SkillStage.BasicSkillStage#BasicSkillStage]
    local stage = skill:getSkillStageBySkillLv(lv)

    local consumeType = "consume"

    if self.__role:getSkillExp(SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)) > 0 then
        consumeType = "consumekwTransform"
    end

    local itemArray = stage:getStageParam(consumeType)

    if #itemArray == 0 then
        return {}
    end

    local list = {}

    for i, v in ipairs(itemArray) do
        table.insert(
            list,
            {
                id = v[1],
                count = v[2]
            }
        )
    end

    return list
end

function PlayerNaturalAttrAdjustmentPlan:checkCanCostItem(index)
    local itemInfo = self:getSwitchPlanCostItemList()[index]

    if itemInfo == nil then
        return false
    end

    local count = self.__role:getItemCount(itemInfo.id)

    return count >= itemInfo.count
end

--@desc: 获取加点属性分配方案列表
--@author:Seven
--@time:2024-01-08 14:16:19
--@return array [src.app.models.role.attr.NaturalAttributePlan.INaturalPlan#INaturalPlan]
function PlayerNaturalAttrAdjustmentPlan:getAdjustmentPlanArray()
    local planArray = {}

    table.insert(planArray, self:getPlanByType(NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN))

    table.insert(planArray, self:getPlanByType(NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN))

    return planArray
end

function PlayerNaturalAttrAdjustmentPlan:__record(r_type, beford, after, cost)
    NaturalAttrjustmentPlanRecord:create(r_type, beford, after, cost):submitRecord()
end

return newClass("PlayerNaturalAttrAdjustmentPlan", {INaturalAttrAdjustmentPlan}, PlayerNaturalAttrAdjustmentPlan)
000000000