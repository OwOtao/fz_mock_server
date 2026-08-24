local MeridianRebuildPresenter = class("MeridianRebuildPresenter", LayerEx)

function MeridianRebuildPresenter:create()
    local p = MeridianRebuildPresenter:new()
    p:init()
    return p
end

--@desc: 
--@author:LvBin
--@time:2025-01-21 11:16:11
--@IMeridianImprintingInherit: [src.app.models.Meridian.Inherit.ImprintingInherit#ImprintingInherit]
--@return
function MeridianRebuildPresenter:setInput(IMeridianImprintingInherit)
    self.__input = IMeridianImprintingInherit
end

function MeridianRebuildPresenter:setUI(ui)
    self.__ui = ui

    self.__ui:addTo(self)
end

function MeridianRebuildPresenter:showPresenter()
    self.__role = self.__input:getRole()

    self.__currPageIndex = self.__input:getCurrUsingMeridianImprintingPageNumber()

    self.__currImprintingIndex = nil

    self.__ui:setImprintingPanelVisible(false)

    self.__ui:setPanelBgVisible(false)

    self:__setPanelBgFunc()

    self:__setInheritButton()

    self:__setTextTitle()

    self:__setBackButtonFunc()

    self:__showPageTitleList()

    self:__setTitleImageShow()

    self:__showImprintingList()

    self:__showSelectImprintingList()

    self.__ui:showUI()
end

function MeridianRebuildPresenter:hidePresenter()
    PopupLayerController:hideLayer("MeridianRebuildPresenter", function(layer)
        self.__ui:hideUI()
    end, 0)
end

function MeridianRebuildPresenter:__setTextTitle()
    self.__ui:setTextTitle(self.__input:getTextTitle())
end

function MeridianRebuildPresenter:__setInheritButton()
    self.__ui:setInheritButtonName(self.__input:getConfirmButtonName())
    
    self.__ui:setInheritButtonFunc(function()
        local canRebuild,msg = self.__input:canRebuild()
        if canRebuild then
            self:__rebuild()
        else
            PopText(msg)   
        end
    end)
end

function MeridianRebuildPresenter:__setPanelBgFunc()
    self.__ui:setPanelBgFunc(function()
        self.__currImprintingIndex = nil

        self.__ui:hideImprintingPanel(function()
            self.__ui:setPanelBgVisible(false)
        end)

        self:__setImprintingImageShow()
    end)
end

function MeridianRebuildPresenter:__setBackButtonFunc()
    self.__ui:setBackButtonFunc(function()
		self:hidePresenter()
	end)
end

function MeridianRebuildPresenter:__showPageTitleList()
    self.__ui:removeTitleListViewAllItems()

    local pages = self.__input:getMeridianImprintingPages()

    for i,page in ipairs(pages) do
        if page:isUnlock() then
            local pagePanel = self.__ui:createTitlePanel()

            local titleName = page:getImprintingPageName()
            
            pagePanel.Text_title:setString(titleName)

            pagePanel:releaseFunc(function()
                self.__currPageIndex = page:getPageIndex()

                self:__setTitleImageShow()

                self:__showSelectImprintingList()

                self:__showImprintingList()
            end)

            self.__ui:insertTitleToListView(pagePanel)
        end
    end
end

function MeridianRebuildPresenter:__setTitleImageShow()
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

function MeridianRebuildPresenter:__showImprintingList()
    local imprintingList = {}

    local pageImprintingList = self.__input:getPageMeridianImprintings(self.__currPageIndex)

    for i,imprinting in ipairs(pageImprintingList) do
        local imprintingId = imprinting:getImprintingId()
        if imprintingId ~= "zuoyouhuboyin" and not self.__input:isSelectMeridianImprinting(self.__currPageIndex,imprintingId) then
            table.insert(imprintingList, imprinting)
        end
    end

    if MapIsEmpty(imprintingList) then
		self.__ui:setImprintingListVisible(false)
		return
	end

    self.__ui:setImprintingListVisible(true)

    for i,imprinting in ipairs(imprintingList) do
        local imprintingId = imprinting:getImprintingId()

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

function MeridianRebuildPresenter:__showSelectImprintingList()
    self.__ui:removeYinJiListViewAllItems()

    local text1 = self.__ui:createSelectText1()

    text1:setString(self.__input:getConfirmText1())

    local text2 = self.__ui:createSelectText2()

    text2:setString(self.__input:getConfirmText2())

    text1:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

	text2:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

    self.__ui:insertYinJiToListView(text1)

    self.__ui:insertYinJiToListView(text2)
    
    local inheritImprintingData = self.__input:getRebuildImprintingData()

    local currPageSelectlist = inheritImprintingData[self.__currPageIndex]

    if not MapIsEmpty(currPageSelectlist) then
        for i,imprintingId in ipairs(currPageSelectlist) do
            local selectImprintingPanel = self.__ui:createSelectImprintingPanel()

            local selectImprinting = self.__input:getMeridianImprintingRes(imprintingId)

            selectImprintingPanel.Panel_name.Text_name:setString(selectImprinting:getName())
            
            selectImprintingPanel.Panel_name.Text_name:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

            selectImprintingPanel.Text_canel:enableOutline({r = 17, g = 18, b = 18, a = 255}, 5)

            selectImprintingPanel:releaseFunc(function()
                self.__input:delectRebuildMeridianImprinting(self.__currPageIndex,imprintingId)

                self:__showSelectImprintingList()
                
                self:__showImprintingList()
            end)

            self.__ui:insertYinJiToListView(selectImprintingPanel)
        end
    end
end

function MeridianRebuildPresenter:__setImprintingImageShow()
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

function MeridianRebuildPresenter:__showImprintingPanel(imprinting)
    self.__ui:setTextImprintingName(imprinting:getName())

    self.__ui:setTextImprintingType(imprinting:getType())

    self.__ui:setTextImprintingDesc(imprinting:getText())

    if imprinting:getType() == "战斗类" then
        self.__ui:setTextImprintingTypeColor({r = 219, g = 57, b = 57, a = 255})
    else
        self.__ui:setTextImprintingTypeColor({r = 102, g = 153, b = 153, a = 255})
    end

    local imprintingId = imprinting:getImprintingId()

    self.__ui:setImprintingButtonName(self.__input:getImprintingInfoButtonName())

    self.__ui:setImprintingButtonFunc(function()
        local canSelect,msg = self.__input:canSelectMeridianImprinting(self.__currPageIndex)
        if canSelect then
            self.__input:selectRebuildMeridianImprinting(self.__currPageIndex,imprintingId)

            self:__showImprintingList()

            self:__showSelectImprintingList()
    
            self.__ui:hideImprintingPanel(function()
                self.__ui:setPanelBgVisible(false)
            end)
        else
            PopText(msg)            
        end
    end)

    self.__ui:setPanelBgVisible(true)

    self.__ui:showImprintingPanel()
end

function MeridianRebuildPresenter:__rebuild()
    self.__input:rebuild(function(isSuc,msg,sucData)
        if isSuc then
            PopupLayerController:showLayer(
                "TextAnimLayer",
                function(layer)
                    layer:setAfterAnimCallback(
                        function()
                            self:hidePresenter()
                            
                            local MeridianBreakLayer = MainControllLayer:getLayer("MeridianBreakLayer")
                            MeridianBreakLayer:createAcupointList(1)
                            MeridianBreakLayer:showAttrData()
                        end
                    )
                    layer:setHideCallbackFunc(
                        function()
                            if tonumber(sucData.remove) ~= 0 then
                                PopText("消耗元宝 X"..sucData.remove)
                            end
                            PopText(msg)
                        end
                    )
                    layer:showLayer("武陵桃源繁花梦，|#AAAA苍梧关山复几重，|#AAAA漫道经渠不可测，|#AAAA还教尺泽起蛟龙。")
                end
            )
        else
            PopText(msg)
        end
    end)
end

Helper:classDefNodeGetInstance(MeridianRebuildPresenter)
return MeridianRebuildPresenter00000000