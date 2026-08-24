local SkillConst = require("app.models.skill.SkillConst")

local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local NaturalAttrAdjustmentSkillInfoPresenter = {}

function NaturalAttrAdjustmentSkillInfoPresenter:create()
    local p = NaturalAttrAdjustmentSkillInfoPresenter:new()
    p:init()
    return p
end

function NaturalAttrAdjustmentSkillInfoPresenter:init()
    self:__initSkill()
end

function NaturalAttrAdjustmentSkillInfoPresenter:__initSkill()
    --@RefType [src.app.models.skill.skills.NaturalAttrAdjustmentSkill#NaturalAttrAdjustmentSkill]
    self.__skill = Skill:getSkill(SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch"))
end

function NaturalAttrAdjustmentSkillInfoPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__roleSkill = self.__role:getSkill(self.__skill:getId())

    local name = self.__skill:getName()
    local desc = self.__skill:getStageDsc(self.__role)
    local dsc = self.__skill:getDsc()
    local exp = Helper:mathFloor(self.__roleSkill.exp)
    local lv = Helper:mathFloor(self.__skill:getLv(exp))
    self.__ui:setName(name)
    self.__ui:setSkillStageDsc(desc)
    self.__ui:setSkillDetailDsc(dsc)
    self.__ui:setSkillExpDsc(exp .. "/" .. lv .. "级")

    local btn1 = "详情"
    local func1 = function()
        Audio:playEffect("daAnNiu")
        self:__showSkilInfo()
    end
    self.__ui:setButton1(btn1, func1)
    self.__ui:setTextDesc1(false)
    self.__ui:setTextDesc2(false)
    self.__ui:setButton2()

    self.__ui:setButton3(
        "参悟",
        function()
            self:__lianGong()
            Audio:playEffect("daAnNiu")
        end
    )

    self.__ui:setThirdTypeVisible(false)
    self.__ui:setActiveZhaoList({})
    self.__ui:setUseTipVisible(false)
    self.__ui:unscheduleAll()
    self.__ui:setImageBackFunc(
        function()
            if self.__backFunc then
                self.__backFunc()
            end
            self.__ui:hide(true)
        end
    )

    self.__ui:show(true)
end

function NaturalAttrAdjustmentSkillInfoPresenter:__checkCanLianGong(costJing, costPot)
    if self.__role:getAttr("jing") < costJing then
        return false, SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TIPS_UPGRADE_JINGLACK)
    end

    if self.__role:getAttr("pot") < costPot then
        return false, SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.TIPS_UPGRADE_POTLACK)
    end

    local lv = self.__skill:getLv(self.__roleSkill.exp)
    if lv >= self.__skill:getMaxLv() then
        return false, self.__skill:getName() .. "等级已达上限。"
    end

    return true
end

function NaturalAttrAdjustmentSkillInfoPresenter:__lianGong()
    local SkillUtil = require("app.models.skill.SkillUtil")

    local currInt = self.__role:getAttr("currInt")

    local costJing = SkillUtil:getBaseKnowledgeSkillLianGongCostJing(self.__skill.id)

    local costPot = SkillUtil:getBaseKnowledgeSkillLianGongCostPot(self.__skill.id, currInt)

    local result, failmsg = self:__checkCanLianGong(costJing, costPot)

    if result == false then
        PopText(failmsg)
        return
    end

    local addExp = SkillUtil:getBaseKnowledgeSkillLianGongAddExp(self.__skill.id, currInt, costPot)

    local currExp = self.__roleSkill.exp
    local maxExp = self.__skill:getExp(self.__skill:getMaxLv())
    if addExp + currExp > maxExp then
        addExp = maxExp - currExp
    end
    self.__roleSkill.exp = self.__roleSkill.exp + addExp

    self.__role:addAttr("jing", -costJing)
    self.__role:addAttr("pot", -costPot)

    addExp = Helper:mathFloor(addExp)
    costJing = Helper:mathFloor(costJing)
    costPot = Helper:mathFloor(costPot)
    RichPrint("main", "消耗:  精力 " .. costJing .. "点")

    RichPrint("main", "消耗:  潜能 " .. costPot .. "点")

    RichPrint("main", "你的 【" .. tostring(self.__skill.name) .. "】 经验 +" .. tostring(addExp))

    local upLevel = self.__skill:getLv(currExp + addExp) - self.__skill:getLv(currExp)

    if upLevel >= 1 then
        local str = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_UPGRADE_SUCCESSLEVEL)
        str = string.gsub(str, "%$(%w+)", {addLv = upLevel, skillN = self.__skill.name})
        RichPrint("main", str)
    end

    local exp = Helper:mathFloor(self.__roleSkill.exp)
    local lv = Helper:mathFloor(self.__skill:getLv(exp))

    self.__ui:setSkillExpDsc(exp .. "/" .. lv .. "级")

    self.__parentPresenter:refreshCurSelectItem()
end

function NaturalAttrAdjustmentSkillInfoPresenter:__showSkilInfo()
    PopupLayerController:showLayer(
        "KnowledgeSkillDetailShowPresenter",
        function(layer)
            layer:showLayer(self.__role, self.__skill)
        end
    )
end

return class("NaturalAttrAdjustmentSkillInfoPresenter", {BaseSkillInfoPopPresenter}, NaturalAttrAdjustmentSkillInfoPresenter)
0000