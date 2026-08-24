local SkillConst = require("app.models.skill.SkillConst")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local class = require("third.class.NewClass")

local YiRongShuSkillInfoPresenter = {}

function YiRongShuSkillInfoPresenter:create()
    local p = YiRongShuSkillInfoPresenter:new()
    p:init()
    return p
end

function YiRongShuSkillInfoPresenter:init()
end

function YiRongShuSkillInfoPresenter:showLayer()
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

    local btn2 = "易容\n改貌"

    local func2 = function()
        Audio:playEffect("daAnNiu")

        self.__ui:hide()

        self:__yiRong()
    end

    local btn3 = "阴阳\n嬗变"

    local func3 = function()
        Audio:playEffect("daAnNiu")

        local isRuslt,msg = self.__role:isGenderTransition()
        
        if isRuslt == false then
            PopText(msg)
            return
        end

        self.__ui:hide(true)

        self:__showGenderTransition()
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

function YiRongShuSkillInfoPresenter:__showSkilInfo()
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

function YiRongShuSkillInfoPresenter:__yiRong()
	if self.__role:checkRoleIsPolymorph() == false and self.__role:checkPolymorphIsCd() == false then  --未易容
        local YiRongShuLayer = require("app.views.layer.YiRongShuLayer.YiRongShuLayer")

        local dialog = YiRongShuLayer:getInstance()
        
        dialog:showLayer()
    elseif self.__role:checkPolymorphIsCd() == true then		--冷却中
        local cdTime = self.__role:getAttr("polymorph").cdTime
        
        local a,b,c = Helper:sec2timeDsc(cdTime - GetTime())
        
        local cdTimetext = a.."小时"..b.."分钟"..c.."秒"
        
        PopText("易容术还有"..cdTimetext.."可再次使用")
    else
        local YiRongShuNoLayer = require("app.views.layer.YiRongShuLayer.YiRongShuNoLayer")

        local dialog = YiRongShuNoLayer:getInstance()
        
        dialog:showLayer()
    end
end

function YiRongShuSkillInfoPresenter:__showGenderTransition()
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(self.__role:getGenderTransitionText())
    dialog:setButton1(
        "确定",
        function()
            self.__role:genderTransition()

            PopText("你成功使用了阴阳嬗变")
        end
    )
    dialog:setButton2("取消")
    dialog:setWeChatVisible(false)
end

return class("YiRongShuSkillInfoPresenter", {BaseSkillInfoPopPresenter}, YiRongShuSkillInfoPresenter)
0