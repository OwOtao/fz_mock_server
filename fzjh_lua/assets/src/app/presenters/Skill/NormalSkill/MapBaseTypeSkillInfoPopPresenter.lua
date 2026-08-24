--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-02 15:00:49
--]]
local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local SkillConst = require("app.models.skill.SkillConst")

local MapBaseTypeSkillInfoPopPresenter = {}

function MapBaseTypeSkillInfoPopPresenter:create()
    local p = MapBaseTypeSkillInfoPopPresenter:new()
    p:init()
    return p
end

function MapBaseTypeSkillInfoPopPresenter:init()
end

function MapBaseTypeSkillInfoPopPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skill = self:getParentModel():getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local expDsc = self:getParentModel():getSkillExpDsc(self.__skillId)

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setTextDesc1(false)
	self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(true)
    self.__ui:setSkillThirdTypes(self:getParentModel():getTextSkillThridTypes())
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

return class("MapBaseTypeSkillInfoPopPresenter", {BaseSkillInfoPopPresenter}, MapBaseTypeSkillInfoPopPresenter)
00