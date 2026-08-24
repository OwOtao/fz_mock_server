local Meridian = require("app.models.Meridian.Meridian")

local MeridianResources = require("app.models.Meridian.MeridianResources")

local MeridianConstant = MeridianResources:getConstant()

local PEI_YUAN_CONTANS = MeridianConstant.PEI_YUAN_COST_TYPE

local PEI_YUAN_BREATHVAL_COST = MeridianConstant.PEI_YUAN_BREATHVAL_COST

local PeiYuanFactory = require("app.models.Meridian.PeiYuan.PeiYuanFactory")

local MeridianImprintingPresenter = class("MeridianImprintingPresenter", LayerEx)

function MeridianImprintingPresenter:create()
    local p = MeridianImprintingPresenter:new()
    p:init()
    return p
end

function MeridianImprintingPresenter:init()
    self.__ui = require("app.views.ui.Meridian.MeridianImprintingUI"):create()

    self.__ui:addTo(self)
end

function MeridianImprintingPresenter:showPresenter()
    self.__role = User:getRole()

    self.__meridianRoleSystem = self.__role:getMeridianSystem()

    self.__currPageIndex = self.__meridianRoleSystem:getCurrUsingMeridianImprintingPageNumber()

    self.__currImprintingIndex = nil

    self.__ui:setImprintingPanelVisible(false)

    self.__ui:setPanelBgVisible(false)

    self:__setPanelBgFunc()

    self:__setTextMeridianLv()

    self:__setTextZhenQiNum()

    self:__setButtonUse()

    self:__showPageTitleList()

    self:__setTitleImageShow()

    self:__showImprintingList()
    
    self:__meridianImprintingTipDsc()

    self.__ui:showUI()
end

function MeridianImprintingPresenter:__meridianImprintingTipDsc()
	local titleLayer = MainControllLayer:getLayer("TitleLayer")
    if titleLayer then
        titleLayer:setTipFunc(
            function(func)
                local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
				local dialog = DialogELayer:getInstance()
				dialog:show("每打通一条经脉便可获得一个经脉天赋，培元可以将一条经脉天赋随机更换成新的经脉天赋。\n已打通的经脉传承不保留，传承时保留对应传承次数的经脉天赋数量。\n互搏神通天赋学习条件为人物至少传承一次且打通八条经脉。")
				dialog:setPanelBack(function()
					if func then
						func()
					end
					
				end)
            end
        )
    end
end

function MeridianImprintingPresenter:__setTextMeridianLv()
    self.__ui:setTextMeridianLv(Meridian:getMeridianLv(self.__role:getAttr("meridianExp")))
end

function MeridianImprintingPresenter:__setTextZhenQiNum()
    self.__ui:setTextZhenQiNum(math.floor(self.__role:getAttr("breathVal")))
end

function MeridianImprintingPresenter:__setButtonUse()
    if self.__currPageIndex == self.__meridianRoleSystem:getCurrUsingMeridianImprintingPageNumber() then
        self.__ui:setUseButtonVisible(false)
    else
        self.__ui:setUseButtonVisible(true)
        self.__ui:setUseButtonFunc(function()
            local switchSuc,msg = self.__meridianRoleSystem:switchMeridianImprintingPage(self.__currPageIndex)

            if switchSuc then
                self.__role:updateRoleBuff()
                
                self:__setButtonUse()
            else
                self:__popText(msg)
            end
        end)
    end
end

function MeridianImprintingPresenter:__setPanelBgFunc()
    self.__ui:setPanelBgFunc(function()
        self.__currImprintingIndex = nil

        self.__ui:hideImprintingPanel(function()
            self.__ui:setPanelBgVisible(false)
        end)

        self:__setImprintingImageShow()
    end)
end


function MeridianImprintingPresenter:__showPageTitleList()
    self.__ui:removeTitleListViewAllItems()

    local pages = self.__meridianRoleSystem:getMeridianImprintingPages()

    for i,page in ipairs(pages) do
        local pagePanel = self.__ui:createTitlePanel()

        local titleName = page:getImprintingPageName()
        
        pagePanel.Text_title:setString(titleName)

        pagePanel:releaseFunc(function()
            if page:isUnlock() then
                self.__currPageIndex = page:getPageIndex()
                
                self:__setTitleImageShow()
                
                self:__showImprintingList()
                
                self:__setButtonUse()
            else
                self:__popText("该经脉印记尚未开启，无法打开")
                
                return 
            end
        end)

        self.__ui:insertTitleToListView(pagePanel)
    end
end

function MeridianImprintingPresenter:__setTitleImageShow()
    local pagesNum = #self.__ui:getTitleItems()
    for i = 1, pagesNum do
        local pagePanel = self.__ui:getTitleItem(i-1)

        if i == self.__currPageIndex then
            pagePanel.Image_back:setVisible(true)
        else
            pagePanel.Image_back:setVisible(false)
        end
    end
end

function MeridianImprintingPresenter:__showImprintingList()
    local imprintingList = {}

    -- 左右互搏开启
	if Meridian:checkCanOpenLeftRightFight() == true and not self.__meridianRoleSystem:hasMeridianImprintingByPage(self.__currPageIndex,"zuoyouhuboyin") then
		table.insert(imprintingList, MeridianResources:getMeridianImprintingRes("zuoyouhuboyin"))
	end

    local pageImprintingList = self.__meridianRoleSystem:getPageMeridianImprintings(self.__currPageIndex)

    for i,imprinting in ipairs(pageImprintingList) do
        table.insert(imprintingList, imprinting)
    end

    if MapIsEmpty(imprintingList) then
		self.__ui:setImprintingListVisible(false)
		return
	end

    self.__ui:setImprintingListVisible(true)

    for i,imprinting in ipairs(imprintingList) do
        local imprintingPanel = self.__ui:getImprintingItem(i-1)

        if imprintingPanel then
        else
            imprintingPanel = self.__ui:createImprintingPanel()

            self.__ui:insertImprintingToListView(imprintingPanel)
        end

        imprintingPanel.Panel_name.Text_name:setString(imprinting:getName())

        imprintingPanel.Panel_name.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

        imprintingPanel.Text_type:setString(imprinting:getType())

        if imprinting:getType() == "战斗类" then
            imprintingPanel.Text_type:setColor({r = 219, g = 57, b = 57, a = 255})
        else
            imprintingPanel.Text_type:setColor({r = 102, g = 153, b = 153, a = 255})
        end

	    imprintingPanel.Text_type:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

        imprintingPanel.Image_dark:setVisible(false)

        imprintingPanel:releaseFunc(function()
            self.__currImprintingIndex = i

            self:__setImprintingImageShow()
            
            self:__showImprintingPanel(imprinting)
        end)
	end

    for i = #imprintingList + 1,#self.__ui:getImprintingItems() do
		self.__ui:removeImprintingLastItem()
	end
end

function MeridianImprintingPresenter:__setImprintingImageShow()
    local imprintingsNum = #self.__ui:getImprintingItems()

    for i = 1, imprintingsNum do
        local imprintingPanel = self.__ui:getImprintingItem(i-1)

        if i == self.__currImprintingIndex then
            imprintingPanel.Image_dark:setVisible(true)
        else
            imprintingPanel.Image_dark:setVisible(false)
        end
    end
end

function MeridianImprintingPresenter:__showImprintingPanel(imprinting)
    self.__ui:setTextImprintingName(imprinting:getName())

    self.__ui:setTextImprintingType(imprinting:getType())

    self.__ui:setTextImprintingDesc(imprinting:getText())

    self.__ui:setTextImprintingLv("")

    if imprinting:getType() == "战斗类" then
        self.__ui:setTextImprintingTypeColor({r = 219, g = 57, b = 57, a = 255})
    else
        self.__ui:setTextImprintingTypeColor({r = 102, g = 153, b = 153, a = 255})
    end

    local imprintingId = imprinting:getImprintingId()

    if imprintingId == "zuoyouhuboyin" then
        self.__ui:setTextImprintingSpeed("")

        if not self.__meridianRoleSystem:hasMeridianImprintingByPage(self.__currPageIndex,"zuoyouhuboyin") then
            self.__ui:setImprintingButtonName("开\n启")

            self.__ui:setImprintingButtonFunc(function()
                local getFlag = self.__role:getFlag("左右互搏入门贴获取")
                if getFlag == 1 then
                    self.__ui:print("HIC玄之又玄，众妙之门。在修炼经脉的过程中，你福至心灵，无师自通，领悟了一些互搏神通的门道，但仍不得其法。作为一种特殊的行功方式，互搏神通可谓博大精深，而武林奇人无名老者正精于此道，酒已给你了，就请前往落英谷向其请教一二吧！")
                else
                    local isOpen,msg = Meridian:openZuoYouHuBoYin()
                    if isOpen then
                        self.__ui:hideImprintingPanel(function()
                            self.__ui:setPanelBgVisible(false)
                        end)

                        if self.__role:getFlag("左右互搏入门贴获取") == 0 then
                            self.__ui:print("HIC玄之又玄，众妙之门。在修炼经脉的过程中，你福至心灵，无师自通，领悟了一些互搏神通的门道，但仍不得其法。作为一种特殊的行功方式，互搏神通可谓博大精深，而武林奇人无名老者正精于此道，现在就前往落英谷向其请教一二吧！")
                        else
                            self.__ui:print("HIC玄之又玄，众妙之门。在修炼经脉的过程中，你福至心灵，无师自通，领悟了一些互搏神通的门道，但仍不得其法。作为一种特殊的行功方式，互搏神通可谓博大精深，而武林奇人无名老者正精于此道，拿上这酒前往落英谷向其请教一二吧！")
                        end
                    end

                    if msg then
                        self:__popText(msg)
                    end
                end
            end)
        else
            local lv = self.__role:getZuoYouHuBoYinLv()

            self.__ui:setTextImprintingLv(lv .. "级")

            self.__ui:setImprintingButtonName("升\n级")

            self.__ui:setImprintingButtonFunc(function()
                self.__ui:hideImprintingPanel(function()
                    self.__ui:setPanelBgVisible(false)
                end)

                if lv >= 10 then
					self:__popText("互搏神通已经满级")
                else
                    self.__ui:print("HIC你已领悟，这次就不给酒你了，现在就前往落英谷向无名老者请教一二吧！")
                end
            end)
        end
    else
        self.__ui:setTextImprintingSpeed("消耗"..PEI_YUAN_BREATHVAL_COST.."真气")

        self.__ui:setImprintingButtonName("培\n元")

        self.__ui:setImprintingButtonFunc(function()
            if imprinting:getPeiyuan() == 0 then
                self:__popText("当前经脉天赋 无法培元")
                return
            end

            self:__showPeiYuanLayer(imprinting)
        end)
    end

    self.__ui:setPanelBgVisible(true)

    self.__ui:showImprintingPanel()
end

function MeridianImprintingPresenter:__showPeiYuanLayer(imprinting)

    PopupLayerController:showLayer("DiscountLayer",function(layer)
        layer:setButton("Button_1", "真气培元", function()
            layer:hide()
            self:__showPeiYuanConfirmLayer(PEI_YUAN_CONTANS.BREATHVAL,imprinting)
        end)
        layer:setButton("Button_2", "三才丹", function()
            layer:hide()
            self:__showPeiYuanConfirmLayer(PEI_YUAN_CONTANS.SAN_CAI_DAN,imprinting)
        end)
        layer:setButton("Button_3", "定志丸", function()
            layer:hide()
            self:__showPeiYuanConfirmLayer(PEI_YUAN_CONTANS.DING_ZHI_WAN,imprinting)
        end)
        layer:setButton("Button_4", "取消", function()
            layer:hide()
        end)
        layer:showLayer("培元经脉天赋后，该天赋会消失，同时重新获得一个新的经脉天赋")
        layer:setBack(false)
    end)
end

function MeridianImprintingPresenter:__showPeiYuanConfirmLayer(peiYuanType,imprinting)
    local showText = ""
    if peiYuanType == PEI_YUAN_CONTANS.BREATHVAL then
        showText = "运转真气进行经脉培元，确定要对此经脉天赋进行培元吗？(将消耗"..PEI_YUAN_BREATHVAL_COST.."真气)"
    elseif peiYuanType == PEI_YUAN_CONTANS.SAN_CAI_DAN then
        showText = "服用三才丹，可直接进行经脉培元，确定要对此经脉天赋进行培元吗？(将消耗一颗三才丹)"
    elseif peiYuanType == PEI_YUAN_CONTANS.DING_ZHI_WAN then
        showText = "服用定志丸，可直接进行经脉培元，确定要对此经脉天赋进行培元吗？(将消耗一颗定志丸)"
    end

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:hide()
    dialog:show(showText)
    dialog:setButton1("确定", function()
        self:__peiYuan(peiYuanType,imprinting)
    end)

    dialog:setButton2("取消")
    dialog:setWeChatVisible(false)
end

function MeridianImprintingPresenter:__peiYuan(peiYuanType,imprinting)
    local replacedImprId = imprinting:getImprintingId()

    local peiYuanImpl = PeiYuanFactory:getPeiYuanFactory(self.__role, self.__currPageIndex, replacedImprId, peiYuanType)

    local failFunc = function(failmsg) 
        self:__popText(failmsg)
    end

    local succFunc = function()
        peiYuanImpl:peiyuan(
            function(meriImpId)
                self:__peiYuanSuc(meriImpId)
            end,
            failFunc)
    end

    peiYuanImpl:meetCost(succFunc, failFunc)
end

function MeridianImprintingPresenter:__peiYuanSuc(meriImpId)
    local newImprinting = MeridianResources:getMeridianImprintingRes(meriImpId)

    local strDesc = 
        {
            {"GRN仙人抚我顶，", "GRN结发受长生。"},
            {"GRN载营魄抱一，能无离乎？", "GRN专气致柔，能如婴儿乎？"},
        }
    local num = math.random(1,#strDesc)

    PopupLayerController:showLayer(
            "GlobalShadeLayer",
            function(layer)
                layer:showLayer()
                layer:setPopText("正在培元中")
            end
        )

    self.__ui:setImprintingButtonFunc(EMPTY_FUNC)

    self:delayFunc(0.5, function()
        self.__ui:print("HIC你突然心有所感、福至心灵，真气在周身各大经脉中流转，若此时有人在旁，只会觉得你的神情突然凝重起来，却不知你体内正掀起惊涛骇浪，一种巨大的变化已然发生！")
    end)
    self:delayFunc(1, function()
        self.__ui:print(strDesc[num][1])
    end)
    self:delayFunc(1.5, function()
        self.__ui:print(strDesc[num][2])
    end)
    self:delayFunc(2, function()
        self:__showImprintingList()

        self:__showImprintingPanel(newImprinting)

        self:__setTextMeridianLv()

        self:__setTextZhenQiNum()

        self.__ui:print("YEL获得经脉天赋WHT" .. newImprinting:getName() .. "HIC！")

        PopupLayerController:hideLayer(
            "GlobalShadeLayer",
            function(layer)
                layer:hideLayer()
            end
        )
    end)

    -- 培元统计
    local Record = require("app.models.Record.Record")
    Record:addRecordCount("jingmai", "event", "peiyuan")
end

function MeridianImprintingPresenter:__popText(text)
    PopText(text)
end

Helper:classDefNodeGetInstance(MeridianImprintingPresenter)
return MeridianImprintingPresenter




000000000000