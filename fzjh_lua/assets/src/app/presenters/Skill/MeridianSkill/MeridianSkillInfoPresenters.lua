local SkillConst = require("app.models.skill.SkillConst")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local class = require("third.class.NewClass")

local MeridianSkillInfoPresenters = {}

function MeridianSkillInfoPresenters:create()
    local p = MeridianSkillInfoPresenters:new()
    p:init()
    return p
end

function MeridianSkillInfoPresenters:init()
end

function MeridianSkillInfoPresenters:setDataModel(iInput)
    self.__input = iInput
end

function MeridianSkillInfoPresenters:showLayer()
    local name = self.__input:getSkillName()
    local desc = self.__input:getSkillStageDsc()
    local dsc = self.__input:getSkillDsc()
    local exp = Helper:mathFloor(self.__input:getSkillExp())
    local lv = Helper:mathFloor(self.__input:getLv(exp))

    local btn1 = "详情"
    local func1 = function()
        Audio:playEffect("daAnNiu")

        self:__showSkilInfo()
    end

    local btn2 = "化元"
    local func2 = function()
        Audio:playEffect("daAnNiu")

		PopupLayerController:showLayer(
			"MeridianSkillPeiYuanLayer",
			function(layer)
                layer:setModel(self.__input)
				layer:showLayer()
			end
		)
    end

    local btn3 = "参悟"
    local func3 = function()
        Audio:playEffect("daAnNiu")
        if self:__checkCanLianGong() then
            self:__lianGong()
        end
    end

	self.__ui:setName(name)
	self.__ui:setSkillStageDsc(desc)
	self.__ui:setSkillDetailDsc(dsc)
	self.__ui:setSkillExpDsc(exp.."/"..lv.."级")
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

function MeridianSkillInfoPresenters:__checkCanLianGong()
    local isTrue,text = self.__input:checkCanLianGong()

    if text then
        PopText(text)
    end

    return isTrue
end

function MeridianSkillInfoPresenters:__lianGong()
    local currExp = self.__input:getSkillExp()
    local addExp,needJing,needPot = self.__input:lianGong()
    local skillName = self.__input:getSkillName()
    local upLevel = self.__input:getLv(currExp + addExp) - self.__input:getLv(currExp)

    addExp = Helper:mathFloor(addExp)
    needJing = Helper:mathFloor(needJing)
    needPot = Helper:mathFloor(needPot)

    RichPrint("main", "消耗:  精力 "..needJing.."点")

    RichPrint("main", "消耗:  潜能 "..needPot.."点")

    RichPrint("main", "你的 【"..skillName.."】 经验 +"..tostring(addExp))

    if upLevel >= 1 then
        local str = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_UPGRADE_SUCCESSLEVEL)
        str = string.gsub(str,"%$(%w+)",{addLv = upLevel, skillN = skillName})
        RichPrint("main",str)
    end

    local exp = Helper:mathFloor(self.__input:getSkillExp())
    local lv = Helper:mathFloor(self.__input:getLv(exp))

    self.__ui:setSkillExpDsc(exp.."/"..lv.."级")

    self.__parentPresenter:refreshCurSelectItem()
end

function MeridianSkillInfoPresenters:__showSkilInfo()
    local name = self.__input:getSkillName()
    local desc = self.__input:getSkillStageDsc()
    local dsc = self.__input:getSkillDsc()
    local exp = Helper:mathFloor(self.__input:getSkillExp())
    local lv = Helper:mathFloor(self.__input:getLv(exp))

    PopupLayerController:showLayer("MeridianSkillInfoUI", function(layer)
        layer:showUI()
        layer:setSkillExpDesc(exp.."/"..lv.."级")
        layer:setSkillName(name)
        layer:setSkillSkillDesc(dsc)
        layer:setBackFunc(function()
            PopupLayerController:hideLayer("MeridianSkillInfoUI", function(layer)
                layer:hideUI()
            end)
        end)

        local skillStageInfo = self.__input:getSkillStageInfo()

        local itemInfo1 = {}
        itemInfo1.title = "武学等级"..skillStageInfo.level.."级"
        itemInfo1.desc = skillStageInfo.text

        if self.__input:checkIsMaxSkillStage(skillStageInfo.id) then
            layer:setPanelItem2Visible(false)
        else
            local itemInfo2 = {}
            local skillNextStageInfo = self.__input:getSkillStageInfoById(skillStageInfo.id + 1)
            itemInfo2.title = "武学等级"..skillNextStageInfo.level.."级解锁"
            itemInfo2.desc = skillNextStageInfo.text

            layer:setPanelItem2Visible(true)
            layer:initPanelItem2(itemInfo2)
        end

        layer:initPanelItem1(itemInfo1)
    end)
end

return class("MeridianSkillInfoPresenters", {BaseSkillInfoPopPresenter}, MeridianSkillInfoPresenters)
00000000000000