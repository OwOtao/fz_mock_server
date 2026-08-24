local SkillConst = require("app.models.skill.SkillConst")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local class = require("third.class.NewClass")

local ShenZhaoJingSkillInfoPresenter = {}

function ShenZhaoJingSkillInfoPresenter:create()
    local p = ShenZhaoJingSkillInfoPresenter:new()
    p:init()
    return p
end

function ShenZhaoJingSkillInfoPresenter:init()
    self.__costJing = 30
end

function ShenZhaoJingSkillInfoPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self.__role:getSkillLvWithRoleLvLimit(self.__skillId).."级"

    local btn1 = "详情"

    local func1 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        self:__showSkilInfo()
    end

    local btn2 = "入坐\n神照"

    local func2 = function()
        Audio:playEffect("daAnNiu")

        local isOk ,msg = self:__canRuShen()
        
        if isOk then
            self:__ruShenZuoZhao()
        else
            PopText(msg)
        end
    end

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setButton1(btn1, func1)
	self.__ui:setTextDesc1(false)
	self.__ui:setButton2(btn2, func2)
	self.__ui:setButton3(nil, nil)
	self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(false)
	self.__ui:setActiveZhaoList({})
    self.__ui:setUseTipVisible(false)
    self.__ui:unscheduleAll()
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

function ShenZhaoJingSkillInfoPresenter:__showSkilInfo()
    local name = self.__skill:getName()

    local dsc = self.__skill:getDsc()

    PopupLayerController:showLayer("TuJianSkillInFoPopLayer", function(layer)
        local TuJianUtil = require("app.models.TuJian.TuJianUtil")
    
        local titalIndex = TuJianUtil:getSkillDefalutTuJianType(self.__skillId)

        layer:setName(name)

        layer:setSkillDetailDsc(dsc)
        
        layer:setActiveZhaoList({})

        layer:playWuXueAnim(self.__skillId,titalIndex)
        
        layer:setAutoZhaoDsc(self.__skillId,titalIndex,true)
        
        layer:showLayer()
    end)
end

function ShenZhaoJingSkillInfoPresenter:__canRuShen()
	-- 1.5 * (200 + 总悟性) *潜能转化效率（potEfficiency）* (200+总悟性)/200
	-- 二、消耗潜能 = 30 * (200 + 总悟性) * 0.5，潜能不足无法“入神坐照”；
	-- 三、获得经验 = 消耗潜能 * 潜能转化效率（potEfficiency）* (200 + 总悟性)/200/100
    
	if self.__role:getNumAttr("jing") < self.__costJing then
		return false,"你精力不足，无法入神坐照"
	end

    local costPot = self:__getCostPot()
	
    if self.__role:getNumAttr("pot") < costPot then
		return false , "你潜能不足，无法入神坐照"
	end

    if self.__role:getSkillLvWithRoleLvLimit(self.__skillId) >= self.__role:getSkillLvLimit(self.__skillId) then
        return false , self.__skill:getName().."等级已达上限。"
    end

    return true
end

function ShenZhaoJingSkillInfoPresenter:__ruShenZuoZhao()
    local costPot = self:__getCostPot()

    local addExp = costPot * self.__skill:getPotEfficiency(self.__role) / 100

	local maxExp = self.__role:getSkillExpLimit(self.__skillId)
	
    if self.__skillExp + addExp > maxExp then
		addExp = maxExp - self.__skillExp
	end

	if addExp > 0 then
        self.__role:addAttr("jing", - self.__costJing)
    
		self.__role:addAttr("pot", - costPot)

        self.__role:addSkillExp(self.__skillId, addExp)

        RichPrint("main", "消耗:  精力 "..tostring(self.__costJing).."点")

		RichPrint("main", "消耗:  潜能 "..tostring(costPot).."点")

		local addExpStr = tostring(Helper:mathFloor(math.max(1,addExp))) 

		RichPrint("main", "你的 【"..self.__skill:getName().."】 经验 +"..addExpStr)
	end

	local exp = Helper:mathFloor(self.__role:getSkillExp(self.__skillId))

    local lv = Helper:mathFloor(self.__role:getSkillLvWithRoleLvLimit(self.__skillId))

    self.__ui:setSkillExpDsc(exp.."/"..lv.."级")

    self.__parentPresenter:refreshCurSelectItem()
end

function ShenZhaoJingSkillInfoPresenter:__getCostPot()
    local totalInt = self.__role:getFinalAttr("currInt")
	
    local costPot = 30 * (200 + totalInt) * 0.5

    return costPot
end


return class("ShenZhaoJingSkillInfoPresenter", {BaseSkillInfoPopPresenter}, ShenZhaoJingSkillInfoPresenter)
00000