local class = require("third.class.NewClass")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

local MapNormalSkillInfoPopPresenter = {}

function MapNormalSkillInfoPopPresenter:create()
    local p = MapNormalSkillInfoPopPresenter:new()
    p:init()
    return p
end

function MapNormalSkillInfoPopPresenter:init()
end

function MapNormalSkillInfoPopPresenter:showLayer()
    self.__role = self:getParentModel():getRole()

    self.__skillId = self:getParentModel():getSkillId()

    self.__skillExp = self.__role:getSkillExp(self.__skillId)

    self.__skill = self:getParentModel():getSkill(self.__skillId)

    local name = self.__skill:getName()

    local desc = self.__skill:getStageDsc(self.__role)

    local dsc = self.__skill:getDsc()

    local expDsc = self:getParentModel():getSkillExpDsc(self.__skillId)

    local zhaoList = self.__role:getSkillZhaoList(self.__skillId)

    local btn1,func1 = self:__getPrepareBtn()

    local btn2 = "详情"

    local func2 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide(true)

        if self.__skill:getType() == SKILL_TYPE_SELFCREATE and self.__skill.outputType == SelfCreatedSkillConstants.SkillOutputType.LILIANMAP_CREATE then
            self:__showLiLianMapSkilInfo()
        else
            self:__showNormalMapSkilInfo()
        end
    end

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
	self.__ui:setActiveZhaoList(zhaoList,self.__role)
	self.__ui:setImageBackFunc(function()
        if self.__backFunc then
            self.__backFunc()
        end
		self.__ui:hide(true)
	end)

    self.__ui:show(true)
end

function MapNormalSkillInfoPopPresenter:__getPrepareBtn()
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


function MapNormalSkillInfoPopPresenter:__showNormalMapSkilInfo()
    local name = self.__skill:getName()

    local dsc = self.__skill:getDsc()

    PopupLayerController:showLayer("TuJianSkillInFoPopLayer", function(layer)
        layer:setRole(self.__role)

        layer:setName(name)

        layer:setSkillDetailDsc(dsc)
        
        layer:setActiveZhaoList(self.__role:getSkillZhaoList(self.__skillId))

        local TuJianUtil = require("app.models.TuJian.TuJianUtil")

		local titalIndex = TuJianUtil:getSkillDefalutTuJianType(self.__skillId)

        layer:playWuXueAnim(self.__skillId,titalIndex)
        
        layer:setAutoZhaoDsc(self.__skillId,titalIndex,self.__role:getSkillStatus(self.__skillId) == SKILL_STATE_GRASP)
        
        layer:showLayer()
    end)
end

function MapNormalSkillInfoPopPresenter:__showLiLianMapSkilInfo()
    local LiLianMapZhaosLibraryPresenter = require("app.presenters.selfCreatedSkill.zhaosLibrary.LiLianMapZhaosLibraryPresenter")
    PopupLayerController:showLayer(
        "ZhaosLibraryUI",
        function(layer)
            layer:showLayer(self.__role:getSelfCreatedSkillSystem(),function()
            end,LiLianMapZhaosLibraryPresenter,self.__skillId)
        end
    )
end

return class("MapNormalSkillInfoPopPresenter", {BaseSkillInfoPopPresenter}, MapNormalSkillInfoPopPresenter)
0000000000000000