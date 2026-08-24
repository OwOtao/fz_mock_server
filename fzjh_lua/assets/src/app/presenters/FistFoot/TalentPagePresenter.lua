local TalentPagePresenter = class("TalentPagePresenter", cc.Layer)

local FistFootConst = require("app.models.FistFootSystem.FistFootConst")

local FistFootResManager = require("app.models.FistFootSystem.FistFootResManager")

local BasicTalentPage = require("app.models.FistFootSystem.TalentPage.BasicTalentPage")

function TalentPagePresenter:create()
    return TalentPagePresenter.new():__init()
end

function TalentPagePresenter:__init()
    --@RefType [TalentPageUI]
    self.__ui = require("app.views.ui.FistFootUI.TalentPageUI"):create()

    self.__ui:addTo(self)

    local maxPageNum = FistFootConst:getConf("skillpageUL")

    local maxPanelCount, isRemain = math.modf(maxPageNum / 4)

    if isRemain > 0 then
        maxPanelCount = maxPanelCount + 1
    end

    for i = 1, maxPanelCount do
        local panelItem = self.__ui:getNewListView1PanelItem()

        self.__ui:pushItemToListView1(panelItem)
    end

    return self
end

function TalentPagePresenter:showLayer()
    self.__selectIndex = self.__pageIndex

    self:__setTitle()

    self:__initPageListView()

    self:__initEffectTextView()

    self:setPanelText()

    self:setButton1()

    self:setButton2()

    self.__ui:show()
end

function TalentPagePresenter:__refreshLayer()
    self:__initEffectTextView()

    self:setPanelText()
end

function TalentPagePresenter:setRole(role)
    self.__role = role
end

function TalentPagePresenter:setTalentPageList(list)
    self.__list = {}
    for i, v in ipairs(list) do
        table.insert(self.__list, BasicTalentPage:create(v))
    end
end

--@desc: 根据页数获取技巧心得页
--@author:Seven
--@time:2023-01-09 16:24:32
--@pageNum: 页码
--@return: [src.app.models.FistFootSystem.TalentPage.BasicTalentPage#BasicTalentPage]
function TalentPagePresenter:__getTalentPage(pageNum)
    return self.__list[tonumber(pageNum)]
end

function TalentPagePresenter:setPageIndex(index)
    self.__pageIndex = index
end

function TalentPagePresenter:setResetCount(resetCount)
    if resetCount > FistFootResManager:getMaxResetCount() then
        resetCount = FistFootResManager:getMaxResetCount()
    end

    local resetData = FistFootResManager:getResetData(resetCount)

    self.__currencyType = resetData.type

    self.__cost = resetData.count
end

function TalentPagePresenter:__setTitle()
    self.__ui:setTitleText("选择需要更换的技法")
end

function TalentPagePresenter:setPanelText()
    local page = self:__getTalentPage(self.__selectIndex)

    if self.__selectIndex == self.__pageIndex then
        self.__ui:setText1("技法心得" .. self.__selectIndex .. "【当前心得】")
    else
        self.__ui:setText1("技法心得" .. self.__selectIndex)
    end

    self.__ui:setText2("")
    self.__ui:setText3("共有谙技：")
    self.__ui:setText4("剩余感悟点数：")
    self.__ui:setText5(page:getTotalJqdamage())
    self.__ui:setText6(page:getFeelPoint())
    self.__ui:setText7("已领悟特性")
end

function TalentPagePresenter:__initEffectTextView()
    local page = self:__getTalentPage(self.__selectIndex)

    local effects = page:getAllEffects()

    self.__ui:removeListView2AllItems()

    for i, effect in ipairs(effects) do
        local mod = math.mod(i - 1, 3)
        local panel
        if mod == 0 then
            panel = self.__ui:getNewListView2TextPanelItem()
            self.__ui:pushItemToListView2(panel)
        else
            local currUiIndex = math.modf((i - 1) / 3)
            panel = self.__ui:getPanelItemFromListView2(currUiIndex)
        end

        local textUiIndex = mod + 1

        panel["Text_char" .. textUiIndex]:setString(effect:getName())

        panel["Text_char" .. textUiIndex]:setVisible(true)
    end

    self.__ui:listView2JumpToTop()
end

function TalentPagePresenter:__initPageListView()
    local pageCount = table.getn(self.__list)

    for i = 1, pageCount do
        local panelIndex = math.modf((i - 1) / 4)
        local panelItem = self.__ui:getPanelItemFromListView1(panelIndex)

        local pageItemIndex = math.mod((i - 1), 4) + 1

        local pageItem = panelItem["Panel_page" .. pageItemIndex]

        pageItem:setVisible(true)

        if i == self.__selectIndex then
            pageItem.Image_1:setVisible(true)
            pageItem.Image_3:setVisible(true)
            pageItem.Text_num:setVisible(false)
            pageItem:releaseFunc(EMPTY_FUNC)
        else
            pageItem.Image_1:setVisible(false)
            pageItem.Image_3:setVisible(false)
            pageItem.Text_num:setVisible(true)
            pageItem.Text_num:setString(Helper:changeNumZeroToTenForCN(i))
            pageItem:releaseFunc(
                function()
                    self.__selectIndex = i
                    self:__initPageListView()
                    self:__initEffectTextView()
                    self:setPanelText()
                end
            )
        end
    end
    self.__ui:listView1JumpToTop()
end

function TalentPagePresenter:setButton1()
    self.__ui:setButton1(
        "确定更换",
        function()
            if self.__selectIndex == self.__pageIndex then
                PopText("已是当前技巧页，无法更换")
                return
            else
                self.__role:getFistFootSystem():changeTelentPage(
                    self.__selectIndex,
                    function(isOk, errmsg)
                        if isOk then
                            self.__pageIndex = self.__selectIndex
                            self:setPanelText()
                            PopText("更换成功")
                        else
                            PopText(errmsg)
                        end
                    end
                )
            end
        end
    )
end

function TalentPagePresenter:setButton2()
    self.__ui:setButton2(
        "技巧回溯",
        function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:hide()
            local currencyName = ""
            if self.__currencyType == FistFootConst.ResetTalentCurrType.YuanBao then
                currencyName = User:getRole():getCHAttrName("yuanbao")
            end
            local isCurrPage = false
            if self.__selectIndex == self.__pageIndex then
                isCurrPage = true
            end
            local text = "重置该技法心得，需要消耗" .. self.__cost .. currencyName .. "，是否需要重置？"
            dialog:show(text)
            dialog:setButton1(
                "确定",
                function()
                    self.__role:getFistFootSystem():resetTalentPage(
                        isCurrPage,
                        self.__selectIndex,
                        function(isOk, msg, data)
                            if isOk then
                                self:setResetCount(data.resetCount)
                                table.remove(self.__list, self.__selectIndex)

                                table.insert(self.__list, BasicTalentPage:create(data))

                                self:__refreshLayer()
                                PopText("回溯成功")
                            else
                                PopText(msg)
                            end
                        end
                    )
                end
            )
            dialog:setButton2(
                "取消",
                function()
                end
            )
            dialog:setWeChatVisible(false)
        end
    )
end

Helper:classDefNodeGetInstance(TalentPagePresenter)
return TalentPagePresenter
0000000000000000