local SkillConst = require("app.models.skill.SkillConst")
local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local class = require("third.class.NewClass")

local JiBenNeiGongSkillInfoPresenter = {}

function JiBenNeiGongSkillInfoPresenter:create()
    local p = JiBenNeiGongSkillInfoPresenter:new()
    p:init()
    return p
end

function JiBenNeiGongSkillInfoPresenter:init()
end

function JiBenNeiGongSkillInfoPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self.__role:getSkillLvWithRoleLvLimit(self.__skillId).."级"

    local btn1 = nil

    local func1 = EMPTY_FUNC

    local btn2,func2 = self:__getBiGuanBtn()

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setButton1(btn1, func1)
	self.__ui:setTextDesc1(false)
	self.__ui:setButton2(btn2, func2)
	self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(true)
    self.__ui:setSkillThirdTypes(self:getParentModel():getTextSkillThridTypes())
    self.__ui:setUseTipVisible(false)
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

function JiBenNeiGongSkillInfoPresenter:__getBiGuanBtn()
    local btn2 = nil

    local func2 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        self:__showBiGuanLayer()
    end

    if self.__role:getSkillLvWithRoleLvLimit(self.__skillId) < self.__role:getSkillLvLimit(self.__skillId) then
        local currSkillId = self.__role:getFlag("当前武功")
        if currSkillId ~= 0 and currSkillId == self.__skillId then
            btn2 = "正闭\n在关"
        else
            btn2 = "闭关"
        end
    end

    return btn2,func2
end

function JiBenNeiGongSkillInfoPresenter:__showBiGuanLayer()
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


return class("JiBenNeiGongSkillInfoPresenter", {BaseSkillInfoPopPresenter}, JiBenNeiGongSkillInfoPresenter)
000000000