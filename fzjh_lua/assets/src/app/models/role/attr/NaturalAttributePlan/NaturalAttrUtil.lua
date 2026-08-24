--[[
    author:Seven
    time:2024-01-05 14:56:09
    desc: 先天属性相关工具类
]]

local SkillConst = require("app.models.skill.SkillConst")

local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")

local NaturalAttrUtil = {}

function NaturalAttrUtil:getPlayerMaxAssignablePoints(inheritCount)
    local point = 0
    -- 三转后每次转生加固定50点
    if inheritCount == 0 then
        point = 80
    elseif inheritCount == 1 then
        point = 110
    elseif inheritCount == 2 then
        point = 150
    elseif inheritCount >= 3 then
        point = 150 + (50 * (inheritCount - 2))
    end
    return point
end

function NaturalAttrUtil:getPlayerInitNaturePlan(role)
    local usage = NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN

    local planDict = {
        [NaturalAttrAdjustmentConst.PLAN_TYPE.BASE_PLAN] = {
            str = role:getAttr("str"),
            dex = role:getAttr("dex"),
            int = role:getAttr("int"),
            con = role:getAttr("con")
        }
    }

    local roleSkill = role:getSkill(SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch"))

    if roleSkill and roleSkill.exp > 0 then
        planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] = self:initKonwledgePlanData(role)
    end

    local plan = {
        usage = usage,
        planDict = planDict
    }

    return plan
end

function NaturalAttrUtil:initKonwledgePlanData(role)
    local useStr = role:getAttr("str")
    local useDex = role:getAttr("dex")
    local useInt = role:getAttr("int")
    local useCon = role:getAttr("con")

    local templateValue = 30

    local plan = {
        str = nil,
        dex = nil,
        int = nil,
        con = nil
    }

    plan.str = math.min(useStr, templateValue)

    plan.dex = math.min(useDex, templateValue)

    plan.int = math.min(useInt, templateValue)

    plan.con = math.min(useCon, templateValue)

    return plan
end

function NaturalAttrUtil:showPlayerNaturalAdjustmentPlanLayer(planType, adjustmenPlan, role)
    local PlayerNaturalAttrAdjustmentPlan = require("app.models.role.attr.NaturalAttributePlan.PlayerNaturalAttrAdjustmentPlan")
    PopupLayerController:showLayer(
        "NaturalAttrAdjustmentPlanPresenter",
        function(layer)
            layer:showLayer(adjustmenPlan, planType, User:getRole())
        end
    )
end

function NaturalAttrUtil:showPlayerCurrentNaturalAdjustmentPlanLayer()
    local role = User:getRole()

    local plan = self:getPlayerCurrentNaturalAdjustmentPlan()

    self:showPlayerNaturalAdjustmentPlanLayer(plan:getUsagePlanType(), plan, role)
end

--@desc: 获取当前玩家先天属性调整方案
--@author:Seven
--@time:2024-01-10 20:36:24
--@return [src.app.models.role.attr.NaturalAttributePlan.INaturalAttrAdjustmentPlan#INaturalAttrAdjustmentPlan]
function NaturalAttrUtil:getPlayerCurrentNaturalAdjustmentPlan()
    local PlayerNaturalAttrAdjustmentPlan = require("app.models.role.attr.NaturalAttributePlan.PlayerNaturalAttrAdjustmentPlan")

    return PlayerNaturalAttrAdjustmentPlan:create(User:getRole())
end

return NaturalAttrUtil
000000000000