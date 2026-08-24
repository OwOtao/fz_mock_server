--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-02 15:55:24
--]]
local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local SkillConst = require("app.models.skill.SkillConst")

--@SuperType [src.app.presenters.Skill.BaseSkillInfoPopPresenter#BaseSkillInfoPopPresenter]
local MapSpecialSkillInfoPopPresenter = {}

function MapSpecialSkillInfoPopPresenter:create()
    local p = MapSpecialSkillInfoPopPresenter:new()
    p:init()
    return p
end

function MapSpecialSkillInfoPopPresenter:init()
end

function MapSpecialSkillInfoPopPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = self:getParentModel():getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local exp = Helper:mathFloor(self.__skillExp)

    local expDsc = exp.."/"..self.__skill:getLv(exp).."级"

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(expDsc)
	self.__ui:setTextDesc1(false)
	self.__ui:setTextDesc2(false)
    self.__ui:setThirdTypeVisible(false)
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

return class("MapSpecialSkillInfoPopPresenter", {BaseSkillInfoPopPresenter}, MapSpecialSkillInfoPopPresenter)
000