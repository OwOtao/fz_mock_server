local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local NeiGongSkillInfoPresenter = {}

function NeiGongSkillInfoPresenter:create()
    local p = NeiGongSkillInfoPresenter:new()
    p:init()
    return p
end

function NeiGongSkillInfoPresenter:init()
end

function NeiGongSkillInfoPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self.__role:getSkillLvWithRoleLvLimit(self.__skillId).."级"

    local zhaoList = self.__role:getSkillZhaoList(self.__skillId)

    local btn1,func1 = self:__getPrepareBtn()

    local btn2,func2 = self:__getBiGuanBtn()

    local btn3 = "详情"

    local func3 = function()
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
	self.__ui:setButton2(btn2, func2)
	self.__ui:setButton3(btn3, func3)
	self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(true)
    self.__ui:setSkillThirdTypes(self:getParentModel():getTextSkillThridTypes())
	self.__ui:setActiveZhaoList(zhaoList)
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

function NeiGongSkillInfoPresenter:__getPrepareBtn()
    local btn1 = nil

    local func1 = EMPTY_FUNC

    if self:getParentModel():skillIsPrepared() == true then
        btn1 = "取装\n消备"

        func1 = function()

            Audio:playEffect("daAnNiu")
            
            self:getParentModel():cancelPrepareSkill()

            self.__parentPresenter:setSkillList()

            self.__ui:hide(true)
        end
    else
        btn1 = "装武\n备功"
        func1 = function()
            Audio:playEffect("daAnNiu")

            local isMulti,prepareTypes = self.__skill:isMultiAttackPrepareType()
            if isMulti == true then
                PopupLayerController:showLayer("SkillSelectPrepareTypePresenter",function (layer)
                    layer:setCallback(function(selectSkillType)
                        self.__role:prepareSkill(selectSkillType,self.__skillId)

                        self.__parentPresenter:setSkillList()

                        self.__ui:hide(true)
                    end)
                    layer:showLayer(self.__skill,prepareTypes)
                end)
                
            else
                self:getParentModel():prepareSkill()

                self.__parentPresenter:setSkillList()

                self.__ui:hide(true)
            end
        end
    end

    return btn1,func1
end

function NeiGongSkillInfoPresenter:__getBiGuanBtn()
    local btn2 = "闭关"

    local func2 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        self:__showBiGuanLayer()
    end

    local currSkillId = self.__role:getFlag("当前武功")
    if currSkillId ~= 0 and currSkillId == self.__skillId then
        btn2 = "正闭\n在关"
    else
        btn2 = "闭关"
    end

    return btn2,func2
end

function NeiGongSkillInfoPresenter:__showBiGuanLayer()
    local BiGuanModel = require("app.models.BiGuan.BiGuanModel")

	--@RefType [src.app.models.BiGuan.BiGuanModel#BiGuanModel]
	local biGuan = BiGuanModel:create(self.__skillId)

	if biGuan:checkCanBiGuan() == false then
		return
	end

	PopupLayerController:showLayer("BiGuanLayer",function (layer)
        layer:showLayer(biGuan)
        layer:setCallback(function()
            self.__parentPresenter:refreshCurSelectItem()
        end)
	end)
end

function NeiGongSkillInfoPresenter:__showSkilInfo()
    local name = self.__skill:getName()

    local dsc = self.__skill:getDsc()

    PopupLayerController:showLayer("TuJianSkillInFoPopLayer", function(layer)
        local TuJianUtil = require("app.models.TuJian.TuJianUtil")
    
        local titalIndex = TuJianUtil:getSkillDefalutTuJianType(self.__skillId)

        layer:setName(name)

        layer:setSkillDetailDsc(dsc)
        
        layer:setActiveZhaoList(self.__role:getSkillZhaoList(self.__skillId))

        layer:playWuXueAnim(self.__skillId,titalIndex)
        
        layer:setAutoZhaoDsc(self.__skillId,titalIndex,true)
        
        layer:showLayer()
    end)
end

return class("NeiGongSkillInfoPresenter", {BaseSkillInfoPopPresenter}, NeiGongSkillInfoPresenter)
000000000000000