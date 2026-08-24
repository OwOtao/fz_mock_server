local SkillConst = require("app.models.skill.SkillConst")

local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local ChangShengJueSkillPresenters = {}

function ChangShengJueSkillPresenters:create()
    local p = ChangShengJueSkillPresenters:new()
    p:init()
    return p
end

function ChangShengJueSkillPresenters:init()
    self.__costJing = 30
end

function ChangShengJueSkillPresenters:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self:__getSkillLv().."级"

    local btn1 = "详情"

    local func1 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide()

        self:__showSkilInfo()
    end

    local btn2 = nil

    local func2 = EMPTY_FUNC

    if self:__getSkillLv() >= 600 then
        btn2 = "炼化\n精气"

        func2 = function()
            Audio:playEffect("daAnNiu")

            local isOk ,msg = self:__canLianHuaJingQi()
            if isOk then
                self:__lianHuaJingQi()
            else
                PopText(msg)
            end
        end
    end

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setButton1(btn1, func1)
	self.__ui:setTextDesc1(false)
	self.__ui:setButton2(btn2, func2)
	self.__ui:setButton3(nil, EMPTY_FUNC)
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

function ChangShengJueSkillPresenters:__showSkilInfo()
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

function ChangShengJueSkillPresenters:__canLianHuaJingQi()
	if self.__role:getNumAttr("jing") < self.__costJing then
		return false , "你精力不足，无法炼气"
	end

    if self:__getSkillLv() >= self.__role:getSkillLvLimit(self.__skillId) then
        return false , self.__skill:getName().."等级已达上限。"
    end

	return true
end

function ChangShengJueSkillPresenters:__lianHuaJingQi()
	local addExp = 50 * self.__skill:getPotEfficiency(self.__role)

	local maxExp = self.__role:getSkillExpLimit(self.__skillId)

	if self.__skillExp + addExp > maxExp then
		addExp = maxExp - self.__skillExp
	end

    if addExp > 0 then
        self.__role:addAttr("jing", - self.__costJing)
    
        RichPrint("main", "消耗:  精力 "..tostring(self.__costJing).."点")
        
        self.__role:addSkillExp(self.__skillId, addExp)

        local addExpStr = tostring(Helper:mathFloor(math.max(1,addExp))) 

        RichPrint("main", "你的 【"..self.__skill:getName().."】 经验 +"..addExpStr)
    end

	local exp = Helper:mathFloor(self.__role:getSkillExp(self.__skillId))

    local lv = Helper:mathFloor(self.__role:getSkillLvWithRoleLvLimit(self.__skillId))

    self.__ui:setSkillExpDsc(exp.."/"..lv.."级")

    self.__parentPresenter:refreshCurSelectItem()
end

function ChangShengJueSkillPresenters:__getSkillLv()
    return self.__role:getSkillLvWithRoleLvLimit(self.__skillId)
end

return class("ChangShengJueSkillPresenters", {BaseSkillInfoPopPresenter}, ChangShengJueSkillPresenters)
00000