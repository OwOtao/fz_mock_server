--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-09-04 18:00:39
--]]
local GoodsDuplicatePurchaseUI = class("GoodsDuplicatePurchaseUI", LayerEx)

function GoodsDuplicatePurchaseUI:create()
    local p = GoodsDuplicatePurchaseUI:new()
    p:init()
    return p
end

function GoodsDuplicatePurchaseUI:init()
    self._UI = require("Layer/StoreUI/GoodsDuplicatePurchaseUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.__backButton = self:__createBottomButton("返回")
    self.__confirmButton = self:__createBottomButton("确定")
    self.__titleDefaultPositionX = self.TxtTitle:getPositionX()
    self.__continueTipsText = nil

    self.BtnCell:setVisible(false)
    self:__initContinueTipsPanel()
    self:setVisible(false)
end

function GoodsDuplicatePurchaseUI:showUI()
    self:show()
end

function GoodsDuplicatePurchaseUI:hideUI()
    self:__hideContinueTipsPanel()
    self:hide()
end

function GoodsDuplicatePurchaseUI:setPromptText(text)
    self.TxtTitle:setString(text)
    self:__refreshPromptTextPosition()
end

function GoodsDuplicatePurchaseUI:addGoodsResultItem(nameText, descText)
    local item = self:__newConditionDescItem()

    self:__updateConditionItemName(item, nameText)
    self:__updateConditionItemText(item, descText)
    self:__addConditionItem(item)
end

function GoodsDuplicatePurchaseUI:clearGoodsResultList()
    self.ListItem:removeAllItems()
end

function GoodsDuplicatePurchaseUI:jumpGoodsResultListToTop()
    self.ListItem:jumpToTop()
end

function GoodsDuplicatePurchaseUI:setBackButtonVisible(visible)
    self.__backButton:setVisible(visible)
    self:__refreshBottomButtonPosition()
end

function GoodsDuplicatePurchaseUI:setBackButton(func)
    self.__backButton:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function GoodsDuplicatePurchaseUI:setConfirmButtonVisible(visible)
    self.__confirmButton:setVisible(visible)
    self:__refreshBottomButtonPosition()
end

function GoodsDuplicatePurchaseUI:setConfirmButton(func)
    self.__confirmButton:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function GoodsDuplicatePurchaseUI:setContinueTipsText(text)
    self.__continueTipsText = text
    self:__refreshContinueTips()
end

function GoodsDuplicatePurchaseUI:__newConditionDescItem()
    local item = self.PnlConditionDescItem:clone()
    Helper:convertUIByParent(item)
    return item
end

function GoodsDuplicatePurchaseUI:__updateConditionItemName(item, name)
    item.TxtName:setString(name)
end

function GoodsDuplicatePurchaseUI:__updateConditionItemText(item, context)
    local text = item.ListTxt.TxtContext
    text:setTextAreaSize({width = 820, height = 0})
    text:ignoreContentAdaptWithSize(true)
    text:setString(context)
    item.ListTxt:jumpToTop()
end

function GoodsDuplicatePurchaseUI:__addConditionItem(item)
    self.ListItem:pushBackCustomItem(item)
end

function GoodsDuplicatePurchaseUI:__cloneBtn()
    local btn = self.BtnCell:clone()
    Helper:convertUIByParent(btn)
    return btn
end

function GoodsDuplicatePurchaseUI:__createBottomButton(name)
    local btn = self:__cloneBtn()
    btn.TxtBtnName:setString(name)
    btn:setVisible(false)
    self._UI:addChild(btn)
    return btn
end

function GoodsDuplicatePurchaseUI:__refreshBottomButtonPosition()
    local backVisible = self.__backButton:isVisible()
    local confirmVisible = self.__confirmButton:isVisible()
    local buttonY = 160

    if backVisible and confirmVisible then
        self.__backButton:setPosition(cc.p(360, buttonY))
        self.__confirmButton:setPosition(cc.p(720, buttonY))
    elseif backVisible then
        self.__backButton:setPosition(cc.p(540, buttonY))
    elseif confirmVisible then
        self.__confirmButton:setPosition(cc.p(540, buttonY))
    end
end

function GoodsDuplicatePurchaseUI:__initContinueTipsPanel()
    local tipsBackSize = self.PnlTips.ImgBack:getContentSize()
    local tipsTextSize = self.PnlTips.ImgBack.TxtContext:getContentSize()

    self.__continueTipsBackWidth = tipsBackSize.width
    self.__continueTipsTextWidth = tipsTextSize.width
    self.__continueTipsPaddingY = math.max(0, (tipsBackSize.height - tipsTextSize.height) / 2)
    self.__continueTipsMinBackHeight = 180
    self.__continueTipsMaxBackHeight = 1100

    self.PnlBtnTips:setVisible(false)
    self.PnlTips:setVisible(false)
    self.PnlTips:setLocalZOrder(1000)
    self.PnlBtnTips:setLocalZOrder(10)
    self:__setContinueTipsButtonSelected(false)

    self.PnlBtnTips:addTouchEventListener(
        function(ref, eventType)
            if eventType == ccui.TouchEventType.began then
                self:__setContinueTipsButtonSelected(true)
            elseif eventType == ccui.TouchEventType.ended then
                self:__showContinueTipsPanel()
            elseif eventType == ccui.TouchEventType.canceled then
                self:__setContinueTipsButtonSelected(self.PnlTips:isVisible())
            end
        end
    )

    self.PnlTips:releaseFunc(
        function()
            self:__hideContinueTipsPanel()
        end
    )
end

function GoodsDuplicatePurchaseUI:__hasContinueTipsText()
    return self.__continueTipsText ~= nil and tostring(self.__continueTipsText) ~= ""
end

function GoodsDuplicatePurchaseUI:__refreshContinueTips()
    local visible = self:__hasContinueTipsText()

    self.PnlBtnTips:setVisible(visible)

    if visible then
        self:__updateContinueTipsPanelSize(tostring(self.__continueTipsText))
        self.PnlTips:setVisible(false)
        self:__setContinueTipsButtonSelected(false)
    else
        self:__hideContinueTipsPanel()
    end

    self:__refreshPromptTextPosition()
end

function GoodsDuplicatePurchaseUI:__refreshPromptTextPosition()
    local titlePositionX = self.__titleDefaultPositionX

    if self.PnlBtnTips:isVisible() then
        local buttonSize = self.PnlBtnTips:getContentSize()
        titlePositionX = self.PnlBtnTips:getPositionX() + buttonSize.width / 2 + 8
    end

    self.TxtTitle:setPositionX(titlePositionX)
end

function GoodsDuplicatePurchaseUI:__updateContinueTipsPanelSize(text)
    local tipsBack = self.PnlTips.ImgBack
    local tipsText = tipsBack.TxtContext
    local textWidth = self.__continueTipsTextWidth

    tipsText:setTextAreaSize({width = textWidth, height = 0})
    tipsText:ignoreContentAdaptWithSize(true)
    tipsText:setString(text)

    local textHeight = tipsText:getAutoRenderSize().height
    local backHeight = textHeight + self.__continueTipsPaddingY * 2
    backHeight = math.max(self.__continueTipsMinBackHeight, backHeight)
    backHeight = math.min(self.__continueTipsMaxBackHeight, backHeight)

    local finalTextHeight = math.max(1, backHeight - self.__continueTipsPaddingY * 2)

    tipsBack:setSize({width = self.__continueTipsBackWidth, height = backHeight})
    tipsText:setTextAreaSize({width = textWidth, height = finalTextHeight})
    tipsText:ignoreContentAdaptWithSize(false)
    tipsText:setPosition(cc.p(self.__continueTipsBackWidth / 2, backHeight / 2))
end

function GoodsDuplicatePurchaseUI:__showContinueTipsPanel()
    if self:__hasContinueTipsText() == false then
        return
    end

    self.PnlTips:setVisible(true)
    self:__setContinueTipsButtonSelected(true)
end

function GoodsDuplicatePurchaseUI:__hideContinueTipsPanel()
    self.PnlTips:setVisible(false)
    self:__setContinueTipsButtonSelected(false)
end

function GoodsDuplicatePurchaseUI:__setContinueTipsButtonSelected(selected)
    self.PnlBtnTips.ImgShowBtn:setVisible(selected)
    self.PnlBtnTips.ImgHideBtn:setVisible(not selected)
end

function GoodsDuplicatePurchaseUI:newConditionDescItem()
    return self:__newConditionDescItem()
end

function GoodsDuplicatePurchaseUI:updateConditionItemName(item, name)
    self:__updateConditionItemName(item, name)
end

function GoodsDuplicatePurchaseUI:updateConditionItemText(item, context)
    self:__updateConditionItemText(item, context)
end

function GoodsDuplicatePurchaseUI:addConditionItem(item)
    self:__addConditionItem(item)
end

function GoodsDuplicatePurchaseUI:clearList()
    self:clearGoodsResultList()
end

function GoodsDuplicatePurchaseUI:cloneBtn()
    return self:__cloneBtn()
end



return GoodsDuplicatePurchaseUI
000000000000