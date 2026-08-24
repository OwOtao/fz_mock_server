local JiangHuYiRenLuExchangeUI = class("JiangHuYiRenLuExchangeUI", LayerEx)

local SWITCH_ANIM_TIME = 0.5

local SHOW_PANEL_POS = cc.p(400, 415)

local RIGHT_HIDE_PANEL_POS = cc.p(1200, 415)

local LEFT_HIDE_PANEL_POS = cc.p(-400, 415)

function JiangHuYiRenLuExchangeUI:create()
    local p = JiangHuYiRenLuExchangeUI:new()
    p:init()
    return p
end

function JiangHuYiRenLuExchangeUI:init()
    self._UI = require("Layer/ActionUI/JiangHuYiRenLuUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)

    self.Button_back:releaseFunc(
        function()
            self:hideUI()
        end
    )

    self.__currPanelIndex = 1

    --@desc 表示动画播放状态
    self.__switchAniming = false
end

function JiangHuYiRenLuExchangeUI:setPresenters(presenter)
    --@RefType[JiangHuYiRenLuActionPresenters]
    self.__presenter = presenter
end

function JiangHuYiRenLuExchangeUI:showUI()
    self.Panel_left:releaseFunc(
        function()
            if self.__switchAniming == true then
                return
            end
            self.__presenter:prevExchangeReward()
            self:__switchNextByLeft()
        end
    )

    self.Panel_right:releaseFunc(
        function()
            if self.__switchAniming == true then
                return
            end
            self.__presenter:nextExchangeReward()
            self:__switchNextByRight()
        end
    )

    self:show()
end

function JiangHuYiRenLuExchangeUI:setExchangeBtn(name, func)
    self.Button_reward.Text_buttonName:setString(Helper:getDef(name, ""))
    self.Button_reward:releaseFunc(
        function()
            func()
        end
    )
end

function JiangHuYiRenLuExchangeUI:initNowPanelInfo(reward)
    local currPanel = self:__getCurrShowPanel()
    return self:__showExchangeInfo(currPanel, reward)
end

function JiangHuYiRenLuExchangeUI:initNextPanelInfo(reward)
    local nextPanel = self:__getNextShowPanel()
    return self:__showExchangeInfo(nextPanel, reward)
end

function JiangHuYiRenLuExchangeUI:__showExchangeInfo(panelUI, reward)
    Helper:convertUIByParent(panelUI)

    panelUI.Image_face:loadTexture(reward.icon)

    panelUI.Text_name:setTextColor({r = 255, g = 255, b = 255})

    panelUI.Text_name:setString(reward.name)

    panelUI.Text_title:setTextColor({r = 255, g = 255, b = 255})

    panelUI.Text_title:setString(reward.title)

    panelUI.Image_face:releaseFunc(
        function()
            if reward.func then
                reward.func()
            end
        end
    )

    local function setRichText(owner, richTextName, uiText, text, textColor, textAlpha, fontName, fontSize)
        uiText:setString("")

        if owner[richTextName] ~= nil then
            owner[richTextName]:removeFromParent()
        end

        local x, y = uiText:getPosition()
        local size = uiText:getContentSize()

        owner[richTextName] = ExtRichTextScroll:create()
        owner[richTextName]:move(cc.p(x, y))
        owner[richTextName]:setSize(size)
        owner[richTextName]:setAnchorPoint(cc.p(0.5, 0.5))
        owner[richTextName]:setDirection(kCCScrollViewDirectionVertical)
        owner[richTextName]:getRichText():setVerticalSpace(20)

        uiText:getParent():addChild(owner[richTextName])

        owner[richTextName]:pushBackText(text, textColor, textAlpha, Resource:getFontPath(fontName), fontSize)
    end

    setRichText(panelUI, "RichText_intro", panelUI.Text_intro, reward.introText, cc.c3b(255, 255, 255), 255, "default", 30)
end

function JiangHuYiRenLuExchangeUI:hideUI()
    self:hide()
end

function JiangHuYiRenLuExchangeUI:__getCurrShowPanel()
    return self.Panel_kuang["Panel_" .. self.__currPanelIndex]
end

function JiangHuYiRenLuExchangeUI:__getNextShowPanel()
    return self.Panel_kuang["Panel_" .. self:__getNextPanelIndex()]
end

function JiangHuYiRenLuExchangeUI:__getNextPanelIndex()
    if self.__currPanelIndex == 1 then
        return 2
    elseif self.__currPanelIndex == 2 then
        return 1
    end
end

function JiangHuYiRenLuExchangeUI:__switchNextByLeft()
    local nextPanel = self:__getNextShowPanel()
    nextPanel:setPosition(LEFT_HIDE_PANEL_POS)

    local nowPanel = self:__getCurrShowPanel()

    local movePos = RIGHT_HIDE_PANEL_POS
    local action =
        cc.Sequence:create(
        cc.Spawn:create(
            cc.CallFunc:create(
                function()
                    nowPanel:runActionWithName("move", YXEaseAction:create(cc.Spawn:create(cc.MoveTo:create(SWITCH_ANIM_TIME, movePos), cc.FadeOut:create(SWITCH_ANIM_TIME)), Expo_EaseOut))
                end
            ),
            cc.CallFunc:create(
                function()
                    nextPanel:runActionWithName("move", YXEaseAction:create(cc.Spawn:create(cc.MoveTo:create(SWITCH_ANIM_TIME, SHOW_PANEL_POS), cc.FadeIn:create(SWITCH_ANIM_TIME)), Expo_EaseIn))
                end
            )
        ),
        cc.CallFunc:create(
            function()
                self.__currPanelIndex = self:__getNextPanelIndex()
            end
        )
    )

    self.__switchAniming = true
    self:runActionWithName("move", action)

    self:delayFunc(
        SWITCH_ANIM_TIME,
        function()
            self.__switchAniming = false
        end
    )
end

function JiangHuYiRenLuExchangeUI:__switchNextByRight()
    local nextPanel = self:__getNextShowPanel()
    nextPanel:setPosition(RIGHT_HIDE_PANEL_POS)

    local nowPanel = self:__getCurrShowPanel()

    local movePos = LEFT_HIDE_PANEL_POS
    local action =
        cc.Sequence:create(
        cc.Spawn:create(
            cc.CallFunc:create(
                function()
                    nowPanel:runActionWithName("move", YXEaseAction:create(cc.Spawn:create(cc.MoveTo:create(SWITCH_ANIM_TIME, movePos), cc.FadeOut:create(SWITCH_ANIM_TIME)), Expo_EaseOut))
                end
            ),
            cc.CallFunc:create(
                function()
                    nextPanel:runActionWithName("move", YXEaseAction:create(cc.Spawn:create(cc.MoveTo:create(SWITCH_ANIM_TIME, SHOW_PANEL_POS), cc.FadeIn:create(SWITCH_ANIM_TIME)), Expo_EaseIn))
                end
            )
        ),
        cc.CallFunc:create(
            function()
                self.__currPanelIndex = self:__getNextPanelIndex()
            end
        )
    )
    self.__switchAniming = true
    self:runActionWithName("move", action)
    self:delayFunc(
        SWITCH_ANIM_TIME,
        function()
            self.__switchAniming = false
        end
    )
end

function JiangHuYiRenLuExchangeUI:setActionTitle(name)
    self.Text_title:setString(Helper:getDef(name, ""))
end

function JiangHuYiRenLuExchangeUI:setActionDesc(text)
    self.Text_desc:setString(Helper:getDef(text, ""))
end

function JiangHuYiRenLuExchangeUI:setNeedNum(num)
    self.Panel_text1.Text_need:setString(num)
end

function JiangHuYiRenLuExchangeUI:setNeedNumTextVisible(bool)
    self.Panel_text1:setVisible(bool)
end

function JiangHuYiRenLuExchangeUI:setCurrentNum(num)
    self.Panel_text2.Text_num:setString(num)
end

function JiangHuYiRenLuExchangeUI:setImageUrl(imageUrl)
    self.Image_back:loadTexture(imageUrl)
end
function JiangHuYiRenLuExchangeUI:setImageVisible(bool)
    self.Image_back:setVisible(bool)
end

function JiangHuYiRenLuExchangeUI:setCurrentDescAndNum(desc,num)
    self.Panel_text2.Text_1:setString(desc)
    self:setCurrentNum(num)
end

function JiangHuYiRenLuExchangeUI:setNeedDescAndNum(desc,num)
    self.Panel_text1.Text_1:setString(desc)
    self:setNeedNum(num)
end

function JiangHuYiRenLuExchangeUI:setExchangeCount(num)
    self.Panel_text3.Text_count:setString(num)
end

function JiangHuYiRenLuExchangeUI:setViewTipTextVisible(visible)
    self.Text_viewTip:setVisible(visible)
end


return JiangHuYiRenLuExchangeUI
0000000000000000