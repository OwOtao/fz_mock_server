local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local TeacherSkillPresenter = {}

function TeacherSkillPresenter:create()
    local p = TeacherSkillPresenter:new()
    p:init()
    return p
end

function TeacherSkillPresenter:init()
end

function TeacherSkillPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__player = User:getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = Skill:getSkill(self.__skillId)

    self.__skillLv = self.__skill:getLv(self.__skillExp)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    self:__initBut1()

    self:__initBut2()

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
    self:__setSkillExpDsc()
    self.__ui:setThirdTypeVisible(false)
    self.__ui:setUseTipVisible(true)
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

function TeacherSkillPresenter:setSkillZhaoList(zhaoList)
    self.__ui:setActiveZhaoList(zhaoList)
end

function TeacherSkillPresenter:__setSkillExpDsc()    
    local roleSkillLv = self.__player:getSkillLvWithRoleLvLimit(self.__skillId)

    local expDsc = roleSkillLv.."/"..self.__skillLv.."级"

    self.__ui:setSkillExpDsc(expDsc)
end

function TeacherSkillPresenter:__initBut1()
    local btn1 = nil

    local func1 = EMPTY_FUNC

    local costDesc1 = nil

    local playerSkillExp = self.__player:getSkillExp(self.__skillId)

    local playerSkillLv = self.__skill:getLv(playerSkillExp)

    if self.__skillLv - playerSkillLv < 10 or self.__player:getLv() - playerSkillLv < 10 then
	else
		btn1 = "请十\n教次"

		func1 = function()
			Audio:playEffect("daAnNiu")

			Skill:consult(self.__player, self.__skillId, 10)

            self:__initBut1()

            self:__initBut2()

            self:__setSkillExpDsc()
		end

		costDesc1 = "消耗"..math.ceil(((self.__skill:getExp(playerSkillLv + 10) - playerSkillExp) / self.__skill:getPotEfficiency(self.__player) * 100)).."点潜能"
	end

    self.__ui:setButton1(btn1, func1)

	self.__ui:setTextDesc1(costDesc1)
end

function TeacherSkillPresenter:__initBut2()
    local playerSkillExp = self.__player:getSkillExp(self.__skillId)

    local playerSkillLv = self.__skill:getLv(playerSkillExp)

    local btn2 = "请一\n教次"

	local func2 = function()
		Audio:playEffect("daAnNiu")

		Skill:consult(self.__player, self.__skillId, 1)

        self:__initBut1()

        self:__initBut2()
        
        self:__setSkillExpDsc()
	end
	
    local costDesc2 = "消耗"..math.ceil(((self.__skill:getExp(playerSkillLv + 1) - playerSkillExp) / self.__skill:getPotEfficiency(self.__player) * 100)).."点潜能"

    self.__ui:setButton2(btn2, func2)

	self.__ui:setTextDesc2(costDesc2)
end

return class("TeacherSkillPresenter", {BaseSkillInfoPopPresenter}, TeacherSkillPresenter)
00000000