local isImplement = require("third.assertIsInstance.assertIsInstance")

local MainTasksUI = class("MainTasksUI", cc.Layer)

function MainTasksUI:create()
    local p = MainTasksUI.new()
    p:init()
    return p
end

function MainTasksUI:init()
    self._UI = require("Layer/TaskUI/MainTasksUI.lua").create()["root"]
    self._UI:addTo(self)
    --  记录上一次抬头的坐标值
    self.__oldOffset = 0
    Helper:convertUIByParent(self)
    self:setVisible(false)
    self:__initDetailRichText()
end

function MainTasksUI:onEnable()
    self.PageView_Tasks:setTouchEnabled(true)
    self.__timerTag =
        self:schedule(
        function(ft)
            self:updateTitlesPos()
        end,
        0
    )
end

function MainTasksUI:onDisable()
    if self.__switchPageCallbackFunc then
        self.__switchPageCallbackFunc = nil
    end
    self.PageView_Tasks:setTouchEnabled(false)
    self:unscheduleAll()
end

function MainTasksUI:clearView()
    self.__switchPageCallbackFunc = nil

    self.Pnl_Titles:removeAllChildren()

    self.PageView_Tasks:removeAllPages()
end

function MainTasksUI:switchPageView(pageNum)
    return self:__changePage(pageNum)
end

function MainTasksUI:setSwitchPageCallbackFunc(callback)
    self.__switchPageCallbackFunc = callback
end

function MainTasksUI:createPage(pageNum, pageName)
    local titleTextUI = self:__createTitleText(pageName)
    titleTextUI:setName("TextUI_" .. pageNum)
    titleTextUI:releaseFunc(
        function()
            if self.__switchPageCallbackFunc then
                local pageNum = pageNum
                self.__switchPageCallbackFunc(pageNum)
            end

            self:__changePage(pageNum)
        end
    )

    self.Pnl_Titles:addChild(titleTextUI)
    local layout = self:__createPageLayout()

    self.PageView_Tasks:addPage(layout)
end

function MainTasksUI:addItemToPage(pageNum, btnUI)
    local pageUI = self.PageView_Tasks:getPageByIndex(pageNum - 1)
    local listViewUI = pageUI:getChildByName("Page_Item_List")
    listViewUI:pushBackCustomItem(btnUI)
end

function MainTasksUI:pageViewJumpToTop(pageNum)
    local pageUI = self.PageView_Tasks:getPageByIndex(pageNum - 1)
    local listViewUI = pageUI:getChildByName("Page_Item_List")
    listViewUI:jumpToTop()
end

function MainTasksUI:changeItemOrder(pageNum, itemUI, targetIndex)
    local pageUI = self.PageView_Tasks:getPageByIndex(pageNum - 1)
    local listViewUI = pageUI:getChildByName("Page_Item_List")

    local curIndex = listViewUI:getIndex(itemUI)

    if curIndex + 1 == targetIndex then
        return
    end

    itemUI:retain()

    listViewUI:removeItem(curIndex)

    listViewUI:insertCustomItem(itemUI, targetIndex - 1)

    itemUI:release()
end

function MainTasksUI:getPageUI(pageNum)
    return self.PageView_Tasks:getPageByIndex(pageNum - 1)
end

function MainTasksUI:setCurrentPage(pageNum)
    --@desc 没有滚动动画
    self.PageView_Tasks:setCurrentPageIndex(pageNum - 1)
end

function MainTasksUI:getCurrentPageIndex()
    return self.PageView_Tasks:getCurrentPageIndex() + 1
end

function MainTasksUI:setPageViewVisible(bool)
    self.PageView_Tasks:setVisible(bool)
end

function MainTasksUI:__createTitleText(titleName)
    local textUI = self.Txt_Title:clone()
    Helper:convertUIByParent(textUI)
    textUI:setColor(cc.c3b(255, 255, 255))
    textUI:setAnchorPoint(0.5000, 0.5000)
    -- textUI:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    textUI:setTouchEnabled(true)
    textUI.Image_RedDot:setVisible(false)
    textUI:setString(titleName)
    return textUI
end

function MainTasksUI:__createPageLayout()
    local layout = ccui.Layout:create()
    local listViewUI = self.ListView_Tasks:clone()
    listViewUI:setScrollBarEnabled(false)
    listViewUI:setDirection(1)
    listViewUI:setGravity(2)
    listViewUI:setPosition(0.0000, 580.0000)
    layout:addChild(listViewUI)
    listViewUI:setSwallowTouches(false)
    listViewUI:setName("Page_Item_List")
    return layout
end

function MainTasksUI:updateTitlesPos()
    local panel_title_count = self.Pnl_Titles:getChildrenCount()

    if panel_title_count <= 0 then
        return
    end

    local offsetX = self.PageView_Tasks:getInnerContainerPosX()

    local total_width = panel_title_count * 1080

    local gap_width = 200

    for i = 1, panel_title_count do
        local textUI = self.Pnl_Titles:getChildByName("TextUI_" .. i)
        textUI:setPositionY(self.Pnl_Titles:getContentSize().height / 2)
        textUI:setPositionX((offsetX / 1080) * gap_width + (i - 1) * gap_width + display.width / 2)

        --@缩放效果
        local textUI_posX = textUI:getPositionX()
        if textUI_posX > display.width / 2 - gap_width and textUI_posX < display.width / 2 + gap_width then
            local scale = 1 + 0.3 * (1 - math.abs(display.width / 2 - textUI_posX) / gap_width)

            if scale > 1.2 then
                textUI:setZ(5)
                textUI:setFontSize(60)
                textUI:setOpacity(255)

                if self.__oldOffset ~= offsetX then
                    self.__oldOffset = offsetX
                end
            else
                textUI:setZ(1)
                textUI:setFontSize(60)
                textUI:setOpacity(125)
            end
        else
            textUI:setZ(1)
            textUI:setFontSize(60)
            textUI:setOpacity(125)
        end
    end
end

--@desc: 切换页面
--@author:Seven
--@time:2020-12-23 10:16:49
--@pageNum: 页码
function MainTasksUI:__changePage(pageNum)
    self:delayFunc(
        0.1,
        function()
            self.PageView_Tasks:playScrollPageAnim(pageNum - 1)
        end
    )
end

function MainTasksUI:__initDetailRichText()
    if self.__richPrint then
        self.__richPrint:removeFromParent()
        self.__richPrint = nil
    end
    self.__richPrint = ExtRichTextScroll:create()
    self.Pnl_HangUpDetail:addChild(self.__richPrint)
    local size = self.Pnl_HangUpDetail.Pnl_DealTxtArea:getContentSize()
    local x, y = self.Pnl_HangUpDetail.Pnl_DealTxtArea:getPosition()
    self.__richPrint:setAnchorPoint(0.5000, 0.5000)
    self.__richPrint:setPosition(cc.p(x, y))
    self.__richPrint:setSize(size)
    self.__richPrint:setScrollBarEnabled(false)
    self.__richPrint:getRichText():setVerticalSpace(10)
    self.__richPrint.fightStatusStringArray = {}
    -- 设置最大显示高度
    self.__richPrint:setTextMaxHeight(2000)

    self.__richPrint:setTouchEnabled(false)
end

function MainTasksUI:clearDetailText()
    self:__initDetailRichText()
end

function MainTasksUI:showDetailPanel()
    self.Pnl_HangUpDetail:setVisible(true)
end

local textColor = cc.c3b(0, 0, 0)
-- 战斗输出默认文字颜色
local textFont = Resource:getFontPath("default")
function MainTasksUI:addDetailText(str)
    str = tostring(str)
    self.__richPrint:pushBackText(str, textColor, 255, textFont, 30)
    self.__richPrint:pushBackNewLine(0)
end

function MainTasksUI:setDetailPanelBtnFunc(name, func)
    self.Pnl_HangUpDetail.Btn_Stop.Text_buttonName:setString(name)
    self.Pnl_HangUpDetail.Btn_Stop:releaseFunc(func)
end

function MainTasksUI:setDetailPanelClickFunc(func)
    self.Pnl_HangUpDetail.Pnl_Background:releaseFunc(func)
end

function MainTasksUI:hideDetailPanel()
    self.Pnl_HangUpDetail:setVisible(false)
end

--@region 第一个信息栏
function MainTasksUI:setDetailInfoPanelTitle1(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward1.Txt_RewardTitle:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible1_1(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward1.Txt_Reward1:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr1_1(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward1.Txt_Reward1:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible1_2(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward1.Txt_Reward2:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr1_2(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward1.Txt_Reward2:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible1_3(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward1.Txt_Reward3:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr1_3(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward1.Txt_Reward3:setString(str)
end

--@endregion

--@region 第二个信息栏
function MainTasksUI:setDetailInfoPanelTitle2(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward2.Txt_RewardTitle:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible2_1(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward2.Txt_Reward1:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr2_1(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward2.Txt_Reward1:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible2_2(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward2.Txt_Reward2:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr2_2(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward2.Txt_Reward2:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible2_3(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward2.Txt_Reward3:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr2_3(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward2.Txt_Reward3:setString(str)
end

--@endregion

--@region 第三个信息栏
function MainTasksUI:setDetailInfoPanelTitle3(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward3.Txt_RewardTitle:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible3_1(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward3.Txt_Reward1:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr3_1(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward3.Txt_Reward1:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible3_2(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward3.Txt_Reward2:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr3_2(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward3.Txt_Reward2:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible3_3(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward3.Txt_Reward3:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr3_3(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward3.Txt_Reward3:setString(str)
end
--@endregion

--@region 第四个信息栏
function MainTasksUI:setDetailInfoPanelTitle4(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_RewardTitle:setString(str)
end

function MainTasksUI:setDetailInfoPanelTitle4_1(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_RewardTitle1:setString(str)
end

function MainTasksUI:setDetailInfoPanelTitleVisible4_1(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_RewardTitle1:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextVisible4_1(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_Reward1:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr4_1(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_Reward1:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible4_2(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_Reward2:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr4_2(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_Reward2:setString(str)
end

function MainTasksUI:setDetailInfoPanelTextVisible4_3(bool)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_Reward3:setVisible(bool)
end

function MainTasksUI:setDetailInfoPanelTextStr4_3(str)
    self.Pnl_HangUpDetail.Pnl_TxtReward4.Txt_Reward3:setString(str)
end

--@endregion

return MainTasksUI
00000