local SkillConst = require("app.models.skill.SkillConst")

local BaseSkillInfoPopPresenter = require("app.presenters.Skill.BaseSkillInfoPopPresenter")

local class = require("third.class.NewClass")

local XiSuiJingPresenters = {}

function XiSuiJingPresenters:create()
    local p = XiSuiJingPresenters:new()
    p:init()
    return p
end


function XiSuiJingPresenters:init()
end

function XiSuiJingPresenters:setDataModel(iInput)
    --@RefType [src.app.models.skill.XiSuiJingUtil#XiSuiJingUtil]
    self.__input = iInput
end

function XiSuiJingPresenters:showLayer()
    local name = self.__input:getSkillName()
    local desc = self.__input:getSkillStageDsc()
    local dsc = self.__input:getSkillDsc()
    local exp = Helper:mathFloor(self.__input:getSkillExp())
    local lv = Helper:mathFloor(self.__input:getLv(exp))

    local btn1 = "换髓\n要术"
    local func1 = function()
        self:__showSkilInfo()
    end

    local btn2 = "溯源\n参悟"
    local func2 = function()
        if self:__checkCanXiSui(1) then
            self:__xiSui(1)
        end
    end

    local btn3 = "溯源\n要领"
    local func3 = function()
        if self:__checkCanXiSui(1) then
            self:__xiSui(10)
        end
    end

    if lv == self.__input:getMaxLv() then
        btn2 = nil
        btn3 = nil
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

function XiSuiJingPresenters:__checkCanXiSui()

    local isTrue,state = self.__input:checkCanXiSui()

    if state then
        PopText(SkillConst:getZhiShiSkillParamContent(state))
    end

    return isTrue
end

function XiSuiJingPresenters:__xiSui(times)
    local canXiSuiTimes = self.__input:getCanXiSuiTimes()
    if canXiSuiTimes < times then
        times = canXiSuiTimes
    end

    local currExp = self.__input:getSkillExp()
    local addExp,needJing,needPot = self.__input:xiSui(times)
    local skillName = self.__input:getSkillName()
    local upLevel = self.__input:getLv(currExp + addExp) - self.__input:getLv(currExp)

    addExp = Helper:mathFloor(addExp)
    needJing = Helper:mathFloor(needJing)
    needPot = Helper:mathFloor(needPot)

    local text = ""
    if times == 1 then
        text = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_UPGRADE_SUCCESSONE)
        text = string.gsub(text,"%$(%w+)",{costJ = needJing,costP = needPot,skillN = skillName,addexp = addExp})
    else
        text = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_UPGRADE_SUCCESSMORE)
        text = string.gsub(text,"%$(%w+)",{upgradeNum = times, costJ = needJing,costP = needPot,skillN = skillName,addexp = addExp})
    end
    
    RichPrint("main",text)

    if upLevel >= 1 then
        local str = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.INFO_UPGRADE_SUCCESSLEVEL)
        str = string.gsub(str,"%$(%w+)",{addLv = upLevel, skillN = skillName})
        RichPrint("main",str)
    end

    local exp = Helper:mathFloor(self.__input:getSkillExp())
    local lv = Helper:mathFloor(self.__input:getLv(exp))

    self.__ui:setSkillExpDsc(exp.."/"..lv.."级")

    if lv == self.__input:getMaxLv() then
        self.__ui:setButton2(nil, nil)
        self.__ui:setButton3(nil, nil)
    end

    self.__parentPresenter:refreshCurSelectItem()
end

function XiSuiJingPresenters:__showSkilInfo()
    local name = self.__input:getSkillName()
    local desc = self.__input:getSkillStageDsc()
    local dsc = self.__input:getSkillDsc()
    local exp = Helper:mathFloor(self.__input:getSkillExp())
    local lv = Helper:mathFloor(self.__input:getLv(exp))

    local skillStageInfo = self.__input:getSkillStageInfo()

    PopupLayerController:showLayer("XiSuiJingInfoUI", function(layer)
        layer:showUI()
        layer:setSkillExpDesc(exp.."/"..lv.."级")
        layer:setSkillName(name)
        layer:setSkillSkillDesc(dsc)
        layer:setBackFunc(function()
            PopupLayerController:hideLayer("XiSuiJingInfoUI", function(layer)
                layer:hideUI()
            end)
        end)

        local itemInfo1 = {}
        itemInfo1.text1 = skillStageInfo.name.."："
        itemInfo1.text2 = "洗髓先天臂力额外+"..skillStageInfo.transform_strAdd.."点"
        itemInfo1.text3 = "洗髓先天根骨额外+"..skillStageInfo.transform_conAdd.."点"
        itemInfo1.text4 = "洗髓先天身法额外+"..skillStageInfo.transform_dexAdd.."点"
        itemInfo1.text5 = "洗髓先天悟性额外+"..skillStageInfo.transform_intAdd.."点"
        itemInfo1.text6 = skillStageInfo.transformText
        

        if self.__input:checkIsMaxSkillStage(skillStageInfo.id) then
            layer:setPanelItem2Visible(false)
            itemInfo1.text1 = skillStageInfo.name.."（满重）："
        else
            local itemInfo2 = {}
            local skillNextStageInfo = self.__input:getSkillStageInfoById(skillStageInfo.id + 1)
            itemInfo2.text1 = skillNextStageInfo.name.."（武学"..skillNextStageInfo.level.."级解锁）"
            itemInfo2.text2 = "洗髓先天臂力额外+"..skillNextStageInfo.transform_strAdd.."点"
            itemInfo2.text3 = "洗髓先天根骨额外+"..skillNextStageInfo.transform_conAdd.."点"
            itemInfo2.text4 = "洗髓先天身法额外+"..skillNextStageInfo.transform_dexAdd.."点"
            itemInfo2.text5 = "洗髓先天悟性额外+"..skillNextStageInfo.transform_intAdd.."点"
            itemInfo2.text6 = skillNextStageInfo.transformText

            layer:setPanelItem2Visible(true)
            layer:initPanelItem2(itemInfo2)
        end

        layer:initPanelItem1(itemInfo1)
    end)
end

return class("XiSuiJingPresenters", {BaseSkillInfoPopPresenter}, XiSuiJingPresenters)
00