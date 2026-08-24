local YuanBaoConsumeActionUI = class("YuanBaoConsumeActionUI", LayerEx)

local itemPos = {
    [1] = {
        x = 188.16,
        y = 421.28
    },
    [2] = {
        x = 606.49,
        y = 421.28
    },
    [3] = {
        x = 188.16,
        y = 196.48
    },
    [4] = {
        x = 606.49,
        y = 196.48
    }
}

local SWITCH_ANIM_TIME = 0.5

local SHOW_PANEL_POS = cc.p(400, 322)

local RIGHT_HIDE_PANEL_POS = cc.p(1200, 322)

local LEFT_HIDE_PANEL_POS = cc.p(-400, 322)

function YuanBaoConsumeActionUI:create()
    local p = YuanBaoConsumeActionUI:new()
    p:init()
    return p
end

function YuanBaoConsumeActionUI:init()
    self._UI = require("Layer/ActionUI/ConsumeWingUI.lua").create()['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)

    self.__currPanelIndex = 1

    --@desc 表示动画播放状态
    self.__switchAniming = false
end

function YuanBaoConsumeActionUI:setPresenters(presenter)
    self.__presenter = presenter
end

function YuanBaoConsumeActionUI:showUI()
    self:show()
end

function YuanBaoConsumeActionUI:hideUI()
    self:hide()
end

function YuanBaoConsumeActionUI:setButtonBack(func)
    self.Button_close:releaseFunc(
        function()
            func()
        end
    )
end

function YuanBaoConsumeActionUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function YuanBaoConsumeActionUI:setDesc(desc)
    self.Text_5:setString(Helper:getDef(desc, ""))
end

function YuanBaoConsumeActionUI:setLoadingBarPercent(percent)
    percent = Helper:getDef(percent, 100)
    self.LoadingBar:setPercent(percent)
end

function YuanBaoConsumeActionUI:setLoadingBarText(text)
    text = Helper:getDef(text, "")
    self.LoadingBar.Text_TotalDayName:setString(text)
end

function YuanBaoConsumeActionUI:setRewardBtnFunc(func)
    self.Button_TotalPrize:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function YuanBaoConsumeActionUI:setRewardBtnTouchEnable(enable)
    enable = Helper:getDef(enable, false)
    self.Button_TotalPrize:setTouchEnabled(enable)
end

function YuanBaoConsumeActionUI:setRewardBtnName(name)
    name = Helper:getDef(name, "")
    self.Button_TotalPrize.Text_TotalPrizeName:setString(name)
end

function YuanBaoConsumeActionUI:setTimeText(text)
    text = Helper:getDef(text, "")
    self.Text_time:setString(text)
end

function YuanBaoConsumeActionUI:setTimeTextVisible(visible)
    visible = Helper:getDef(visible, false)
    self.Text_time:setVisible(visible)
end

function YuanBaoConsumeActionUI:setHongDianVisible(visible)
    visible = Helper:getDef(visible, false)
    self.Image_hongdian:setVisible(visible)
end

function YuanBaoConsumeActionUI:setTipsText(text)
    text = Helper:getDef(text, "")
    self.Text_name_0:setString(text)
end

function YuanBaoConsumeActionUI:setHelp1Text(text)
    text = Helper:getDef(text, "")
    self.Text_14:setString(text)
end

function YuanBaoConsumeActionUI:setHelp2Text(text)
    text = Helper:getDef(text, "")
    self.Text_15:setString(text)
end

function YuanBaoConsumeActionUI:setLeftBtnFunc(func)
    self.Panel_left:releaseFunc(function()
        if self.__switchAniming == true then
            return
        end

        if func then
            func()
        end
    end)
end

function YuanBaoConsumeActionUI:setRightBtnFunc(func)
    self.Panel_right:releaseFunc(function()
        if self.__switchAniming == true then
            return
        end

        if func then
            func()
        end
    end)
end

function YuanBaoConsumeActionUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function YuanBaoConsumeActionUI:initNowPanelInfo(itemList)
    local currPanel = self:__getCurrShowPanel()
    self:__initPanelInfo(currPanel, itemList)
end

function YuanBaoConsumeActionUI:initNextPanelInfo(itemList)
    local nextPanel = self:__getNextShowPanel()
    self:__initPanelInfo(nextPanel, itemList)
end

function YuanBaoConsumeActionUI:__getCurrShowPanel()
    return self.Panel_kuang["Panel_" .. self.__currPanelIndex]
end

function YuanBaoConsumeActionUI:__getNextShowPanel()
    return self.Panel_kuang["Panel_" .. self:__getNextPanelIndex()]
end

function YuanBaoConsumeActionUI:__initPanelInfo(panel, info)
    if MapIsEmpty(info) == false then
        for i = 1, #info do
            local item = panel:getChildByName("panelItem"..tostring(i))

            if not item then
                item = self:__cloneItem()
                item:addTo(panel)
                local x = Helper:getDef(itemPos[i].x, 0)
                local y = Helper:getDef(itemPos[i].y, 0)
                item:setPosition(x, y)
                item:setName("panelItem"..tostring(i))
            end
            
            self:__initItem(item, info[i])
        end
    end
end

function YuanBaoConsumeActionUI:__cloneItem()
	local item = self.Panel_item:clone()
	Helper:convertUIByParent(item)
	return item
end

function YuanBaoConsumeActionUI:__initItem(item, list)
	item.Image_zhuzi:loadTexture(list.icon,0)
	item.Text_name:setString(list.name)
	item.Text_NameDdes:setVisible(false)
	item.Text_num:setString(tostring(list.number))
    item:releaseFunc(function()
		if list.func then
            list.func()
        end
	end)
end

function YuanBaoConsumeActionUI:__getNextPanelIndex()
    if self.__currPanelIndex == 1 then
        return 2
    elseif self.__currPanelIndex == 2 then
        return 1
    end
end

function YuanBaoConsumeActionUI:setButtonPayFunc(btnFunc)
	btnFunc = Helper:getDef(btnFunc,EMPTY_FUNC)
	self.Button_toPay:releaseFunc(function()
		btnFunc()
	end)
end

function YuanBaoConsumeActionUI:switchNextByLeft()
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

function YuanBaoConsumeActionUI:switchNextByRight()
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

return YuanBaoConsumeActionUI
000000000000000