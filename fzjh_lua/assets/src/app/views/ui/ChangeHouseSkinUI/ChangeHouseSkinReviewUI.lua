local ChangeHouseSkinReviewUI = class("ChangeHouseSkinReviewUI", LayerEx)

local SWITCH_ANIM_TIME = 0.3

local SHOW_PANEL_POS = cc.p(540, 425.00)

local RIGHT_HIDE_PANEL_POS = cc.p(1680, 425.00)

local LEFT_HIDE_PANEL_POS = cc.p(-361.82, 425.00)

local SHOW_PANEL_NUM = 4

function ChangeHouseSkinReviewUI:create()
    local p = ChangeHouseSkinReviewUI:new()
    p:init()
    return p
end

function ChangeHouseSkinReviewUI:init()
    self.__UI = require("Layer/ChangeHouseSkinUI/ChangeHouseSkinReviewUI.lua").create()["root"]

    self.__UI:addTo(self)

    Helper:convertUIByParent(self)

    self.__panelList = {}

    self.__currIndex = 1

    self.Panel_left:releaseFunc(
        function()
            if self.__switching then
                return
            end

            local panelNum = #self.__panelList
            if panelNum == 0 then
                return
            end

            return self:__switchPrevPanel()
        end
    )

    self.__switching = false

    self.Panel_right:releaseFunc(
        function()
            if self.__switching then
                return
            end
            local panelNum = #self.__panelList

            if panelNum == 0 then
                return
            end

            return self:__switchNextPanel()
        end
    )
end

function ChangeHouseSkinReviewUI:__switchNextPanel()
    local nextIndex = self.__currIndex + 1
    if nextIndex > #self.__panelList then
        nextIndex = 1
    end

    if self.__currIndex == nextIndex then
        return
    end

    local nextPanel = self.__panelList[nextIndex]
    local currPanel = self.__panelList[self.__currIndex]
    nextPanel:setPosition(RIGHT_HIDE_PANEL_POS)

    local right2centerAction = cc.MoveTo:create(SWITCH_ANIM_TIME, SHOW_PANEL_POS)
    local rightFadeInAction = cc.FadeIn:create(SWITCH_ANIM_TIME - 0.1)
    local rightPanelSpawn = cc.Spawn:create(right2centerAction, rightFadeInAction)
    nextPanel:runAction(
        cc.Sequence:create(
            rightPanelSpawn,
            cc.CallFunc:create(
                function()
                    self.__isSwitching = false
                    self.__currIndex = nextIndex
                end
            )
        )
    )

    local center2LeftAction = cc.MoveTo:create(SWITCH_ANIM_TIME, LEFT_HIDE_PANEL_POS)
    local centerFadeOutAction = cc.FadeOut:create(SWITCH_ANIM_TIME - 0.1)
    local centerPanelSpawn = cc.Spawn:create(center2LeftAction, centerFadeOutAction)
    currPanel:runAction(centerPanelSpawn)

    self.__isSwitching = true
end

function ChangeHouseSkinReviewUI:__switchPrevPanel()
    local preViewIndex = self.__currIndex - 1

    if preViewIndex < 1 then
        preViewIndex = #self.__panelList
    end

    if self.__currIndex == preViewIndex then
        return
    end

    local currPanel = self.__panelList[self.__currIndex]

    local prevPanel = self.__panelList[preViewIndex]

    prevPanel:setPosition(LEFT_HIDE_PANEL_POS)
    local left2centerAction = cc.MoveTo:create(SWITCH_ANIM_TIME, SHOW_PANEL_POS)
    local leftFadeInAction = cc.FadeIn:create(SWITCH_ANIM_TIME - 0.1)
    local leftPanelSpawn = cc.Spawn:create(left2centerAction, leftFadeInAction)
    prevPanel:runAction(
        cc.Sequence:create(
            leftPanelSpawn,
            cc.CallFunc:create(
                function()
                    self.__isSwitching = false
                    self.__currIndex = preViewIndex
                end
            )
        )
    )

    local center2RightAction = cc.MoveTo:create(SWITCH_ANIM_TIME, RIGHT_HIDE_PANEL_POS)
    local centerFadeOutAction = cc.FadeOut:create(SWITCH_ANIM_TIME - 0.1)
    local centerPanelSpawn = cc.Spawn:create(center2RightAction, centerFadeOutAction)
    currPanel:runAction(centerPanelSpawn)

    self.__isSwitching = true
end

function ChangeHouseSkinReviewUI:getPanelByIndex(index)
    if index <= 0 then
        assert(false, "ChangeHouseSkinReviewUI:getPanelByIndex 不可小于1")
    end
    return self.__panelList[index]
end

function ChangeHouseSkinReviewUI:addPanel(panel, index)
    local isEmpty = #self.__panelList == 0

    if index == nil then
        table.insert(self.__panelList, panel)
    else
        self.__panelList[index] = panel
    end

    if isEmpty then
        panel:setPosition(SHOW_PANEL_POS)
        panel:setOpacity(255)
        panel:setVisible(true)
    else
        panel:setPosition(RIGHT_HIDE_PANEL_POS)
        panel:setOpacity(0)
        panel:setVisible(true)
    end

    self.Panel_Container:addChild(panel)
end

function ChangeHouseSkinReviewUI:createNewPanel()
    return self.Panel_1:clone()
end

function ChangeHouseSkinReviewUI:showUI()
    self:show()
end

function ChangeHouseSkinReviewUI:hideUI()
    self:hide()
end

function ChangeHouseSkinReviewUI:setButtonBack(func)
    self.Button_back:setTouchEnabled(true)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function ChangeHouseSkinReviewUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function ChangeHouseSkinReviewUI:setText_1Str(str)
    self.Text_1:setString(str)
end

function ChangeHouseSkinReviewUI:setText_2Str(str)
    self.Text_2:setString(str)
end

function ChangeHouseSkinReviewUI:setText_3Str(str)
    self.Text_3:setString(str)
end

function ChangeHouseSkinReviewUI:setText_4Str(str)
    self.Text_4:setString(str)
end

function ChangeHouseSkinReviewUI:setText_5Str(str)
    self.Text_5:setString(str)
end

function ChangeHouseSkinReviewUI:setText_2Visible(visible)
    self.Text_2:setVisible(Helper:getDef(visible, false))
end

function ChangeHouseSkinReviewUI:setText_3Visible(visible)
    self.Text_3:setVisible(Helper:getDef(visible, false))
end

function ChangeHouseSkinReviewUI:setText_4Visible(visible)
    self.Text_4:setVisible(Helper:getDef(visible, false))
end

function ChangeHouseSkinReviewUI:setText_5Visible(visible)
    self.Text_5:setVisible(Helper:getDef(visible, false))
end

function ChangeHouseSkinReviewUI:setButton_1Func(func)
    self.Button_1:releaseFunc(
        function()
            func()
        end
    )
end

function ChangeHouseSkinReviewUI:setButton_1Texture(texture)
    self.Button_1:loadTextureNormal(texture)
end

function ChangeHouseSkinReviewUI:setButton_1Name(name)
    self.Button_1.Text_buttonName:setString(name)
end

return ChangeHouseSkinReviewUI
000000000000000