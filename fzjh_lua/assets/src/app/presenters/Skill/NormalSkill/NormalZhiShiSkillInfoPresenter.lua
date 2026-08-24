local SkillConst = require("app.models.skill.SkillConst")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local class = require("third.class.NewClass")

local NormalZhiShiSkillInfoPresenter = {}

function NormalZhiShiSkillInfoPresenter:create()
    local p = NormalZhiShiSkillInfoPresenter:new()
    p:init()
    return p
end

function NormalZhiShiSkillInfoPresenter:init()
end

function NormalZhiShiSkillInfoPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self.__skill:getLv(exp).."级"

    local btn1 = "详情"

    local func1 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        self:__showSkilInfo()
    end

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setButton1(btn1, func1)
	self.__ui:setTextDesc1(false)
	self.__ui:setButton2(nil, nil)
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

function NormalZhiShiSkillInfoPresenter:__showSkilInfo()
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

return class("NormalZhiShiSkillInfoPresenter", {BaseSkillInfoPopPresenter}, NormalZhiShiSkillInfoPresenter)
00000000