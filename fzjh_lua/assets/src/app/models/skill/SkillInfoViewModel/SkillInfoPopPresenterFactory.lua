--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-08-06 11:15:57
--]]
local SkillInfoPopNormalUI = require("app.views.ui.SkillUI.SkillInfoPopNormalUI")

local SkillInfoPopSpecialUI = require("app.views.ui.SkillUI.SkillInfoPopSpecialUI")

local SkillConst = require("app.models.skill.SkillConst")

local SkillInfoPopPresenterFactory = {}

function SkillInfoPopPresenterFactory:createMySkillInfoPopPresenter(parentPresenter)
	self:__init(parentPresenter)

	local presenter

	if self.__skillId == SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM) then
		presenter = self:__createXiSuiJingSkillPresenter()
	elseif self.__skillId == SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_MERIDIAN) then
		presenter = self:__createMeridianSkillPresenter()
	elseif self.__skillId == SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch") then
		presenter = self:__createNaturalAttrAdjustmentSkillPresenter()
	elseif self.__skillId == "changshengjueyin" or self.__skillId == "changshengjueyang" then
		presenter = self:__createChangShengJueSkillPresenter()
	elseif self.__skillId == "yirongshu" then
		presenter = self:__createYiRongShuSkillPresenter()
	elseif self.__skillId == "zouxueshisijing" then
		presenter = self:__createZxssjSkillPresenter()
	elseif self.__skillId == "shenzhaojing003" then
		presenter = self:__createShenZhaoJingSkillPresenter()
	elseif self.__skillId == "zhengaoxuanjing" then
		presenter = self:__createZgxjSkillPresenter()
	elseif self.__skillId == "dankuixuangong" then
		presenter = self:__createDkxgSkillPresenter()
	elseif self.__skillId == "jibenneigong" then
		presenter = self:__createJiBenNeiGongSkillPresenter()
	elseif self.__skill:getType() == SKILL_TYPE_BASE and self.__skillId ~= "jibenneigong" then
		presenter = self:__createBaseTypeSkillPresenter()
	elseif self.__skill:isNeiGong() and self.__skillId ~= "jibenneigong" then
		presenter = self:__createNeiGongSkillPresenter()
	elseif self.__viewModel:getCurrTabSkillType() == "zhishi" then
		presenter = self:__createNormalZhiShiSkillPresenter()
	elseif self.__viewModel:getCurrTabSkillType() ~= "zhishi" then
		presenter = self:__createNormalSkillPresenter()
	else
		error("SkillInfoPopPresenterFactory:__showSkillPresenters error"..self.__skillId)
	end

	return presenter
end

function SkillInfoPopPresenterFactory:createTeacherSkillInfoPopPresenter(parentPresenter)
	self:__init(parentPresenter)

	local presenter

    if self.__skill:getType() == SKILL_TYPE_BASE then
		presenter = self:__createTeacherBaseSkillPresenter()
	else
		presenter = self:__createTeacherNormalSkillPresenter()
	end

	return presenter
end

function SkillInfoPopPresenterFactory:createMapSkillInfoPopPresenter(parentPresenter)
	self:__init(parentPresenter)

	local presenter

    if self.__skill:getType() == SKILL_TYPE_BASE then
		presenter = self:__createMapBaseTypeSkillInfoPresenter()
	elseif self.__viewModel:getCurrTabSkillType() ~= "zhishi" then
		presenter = self:__createMapNormalSkillInfoPresenter()
	elseif self.__viewModel:getCurrTabSkillType() == "zhishi" then
		presenter = self:__createMapSpecialSkillInfoPresenter()
	end

	return presenter
end

function SkillInfoPopPresenterFactory:createDreamMapSkillInfoPopPresenter(parentPresenter)
	self:__init(parentPresenter)

	local presenter

    if self.__skill:getType() == SKILL_TYPE_BASE then
		presenter = self:__createMapBaseTypeSkillInfoPresenter()
	else
		presenter = self:__createMapNormalSkillInfoPresenter()
	end

	return presenter
end

function SkillInfoPopPresenterFactory:createFondDreamMapSkillInfoPopPresenter(parentPresenter)
	self:__init(parentPresenter)

	local presenter

    if self.__skill:getType() == SKILL_TYPE_BASE then
		presenter = self:__createMapBaseTypeSkillInfoPresenter()
	else
		presenter = self:__createFondDreamMapNormalSkillInfoPresenter()
	end

	return presenter
end

function SkillInfoPopPresenterFactory:__init(parentPresenter)
	self.__parentPresenter = parentPresenter
	
    self.__viewModel = self.__parentPresenter:getViewModel()

    self.__role = self.__viewModel:getRole()

    self.__skillId = self.__viewModel:getSkillId()

	self.__skill = self.__viewModel:getSkill(self.__skillId)
end

function SkillInfoPopPresenterFactory:__createXiSuiJingSkillPresenter()
	local XiSuiJingPresenters = require("app.presenters.Skill.XiSuiJing.XiSuiJingPresenters")
	local XiSuiJingUtil = require("app.models.skill.XiSuiJingUtil")
	local xiSuiJingPresenters = XiSuiJingPresenters:create()
	local xiSuiJingUtil = XiSuiJingUtil:create()
	xiSuiJingUtil:setRole(self.__role)

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	xiSuiJingPresenters:setUI(popUI)
	xiSuiJingPresenters:setDataModel(xiSuiJingUtil)

	return xiSuiJingPresenters
end

function SkillInfoPopPresenterFactory:__createMeridianSkillPresenter()
	--@RefType [src.app.presenters.Skill.MeridianSkill.MeridianSkillInfoPresenters#MeridianSkillInfoPresenters]]
	local meridianSkillInfoPresenters = require("app.presenters.Skill.MeridianSkill.MeridianSkillInfoPresenters"):create()
	--@RefType [src.app.models.skill.MeridianSkillUtil#MeridianSkillUtil]
	local meridianSkillUtil = require("app.models.skill.MeridianSkillUtil"):create(self.__role)

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	meridianSkillInfoPresenters:setUI(popUI)
	meridianSkillInfoPresenters:setDataModel(meridianSkillUtil)

	return meridianSkillInfoPresenters
end

function SkillInfoPopPresenterFactory:__createNaturalAttrAdjustmentSkillPresenter()
    local presenter = require("app.presenters.Skill.NaturalAttrAdjustmentSkill.NaturalAttrAdjustmentSkillInfoPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createChangShengJueSkillPresenter()
    --@RefType [src.app.presenters.Skill.ChangShengJueSkill.ChangShengJueSkillPresenters#ChangShengJueSkillPresenters]
    local presenter = require("app.presenters.Skill.ChangShengJueSkill.ChangShengJueSkillPresenters"):create()
	
	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createYiRongShuSkillPresenter()
    --@RefType [src.app.presenters.Skill.YiRongShuSkill.YiRongShuSkillInfoPresenter#YiRongShuSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.YiRongShuSkill.YiRongShuSkillInfoPresenter"):create()
	
	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createZxssjSkillPresenter()
    --@RefType [src.app.presenters.Skill.ZouXueShiSiJing.ZouXueShiSiJingSkillInfoPresenter#ZouXueShiSiJingSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.ZouXueShiSiJing.ZouXueShiSiJingSkillInfoPresenter"):create()
	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
	return presenter
end

function SkillInfoPopPresenterFactory:__createShenZhaoJingSkillPresenter()
    --@RefType [src.app.presenters.Skill.ShenZhaoJing.ShenZhaoJingSkillInfoPresenter#ShenZhaoJingSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.ShenZhaoJing.ShenZhaoJingSkillInfoPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createZgxjSkillPresenter()
    --@RefType [src.app.presenters.Skill.ZhenGaoXuanJing.ZhenGaoXuanJingSkillInfoPresenter#ZhenGaoXuanJingSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.ZhenGaoXuanJing.ZhenGaoXuanJingSkillInfoPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createDkxgSkillPresenter()
    --@RefType [src.app.presenters.Skill.DanKuiXuanGong.DanKuiXuanGongSkillInfoPresenter#DanKuiXuanGongSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.DanKuiXuanGong.DanKuiXuanGongSkillInfoPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createJiBenNeiGongSkillPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.JiBenNeiGongSkillInfoPresenter#JiBenNeiGongSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.JiBenNeiGongSkillInfoPresenter"):create()
	
	local popUI = SkillInfoPopNormalUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createBaseTypeSkillPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.BaseTypeSkillPresenters#BaseTypeSkillPresenters]
    local presenter = require("app.presenters.Skill.NormalSkill.BaseTypeSkillPresenters"):create()

	local popUI = SkillInfoPopNormalUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createNeiGongSkillPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.NeiGongSkillInfoPresenter#NeiGongSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.NeiGongSkillInfoPresenter"):create()
	
	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createNormalZhiShiSkillPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.NormalZhiShiSkillInfoPresenter#NormalZhiShiSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.NormalZhiShiSkillInfoPresenter"):create()
	
	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createNormalSkillPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.NormalSkillInfoPresenter#NormalSkillInfoPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.NormalSkillInfoPresenter"):create()
	
	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createTeacherBaseSkillPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.TeacherSkillPresenter#TeacherSkillPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.TeacherSkillPresenter"):create()

	local popUI = SkillInfoPopNormalUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createTeacherNormalSkillPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.TeacherSkillPresenter#TeacherSkillPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.TeacherSkillPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
	presenter:setSkillZhaoList(self.__role:getSkillZhaoList(self.__skillId))
    return presenter
end

function SkillInfoPopPresenterFactory:__createMapBaseTypeSkillInfoPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.MapBaseTypeSkillInfoPopPresenter#MapBaseTypeSkillInfoPopPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.MapBaseTypeSkillInfoPopPresenter"):create()
	
	local popUI = SkillInfoPopNormalUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createMapNormalSkillInfoPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.MapNormalSkillInfoPopPresenter#MapNormalSkillInfoPopPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.MapNormalSkillInfoPopPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createMapSpecialSkillInfoPresenter()
    --@RefType [src.app.presenters.Skill.NormalSkill.MapSpecialSkillInfoPopPresenter#MapSpecialSkillInfoPopPresenter]
    local presenter = require("app.presenters.Skill.NormalSkill.MapSpecialSkillInfoPopPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
    popUI:hide()
	presenter:setUI(popUI)
    return presenter
end

function SkillInfoPopPresenterFactory:__createFondDreamMapNormalSkillInfoPresenter()
	--@RefType [src.app.presenters.Skill.NormalSkill.FondDreamMapNormalSkillInfoPopPresenter#FondDreamMapNormalSkillInfoPopPresenter]
	local presenter = require("app.presenters.Skill.NormalSkill.FondDreamMapNormalSkillInfoPopPresenter"):create()

	local popUI = SkillInfoPopSpecialUI:create()
	popUI:hide()
	presenter:setUI(popUI)
	return presenter
end

return SkillInfoPopPresenterFactory
00