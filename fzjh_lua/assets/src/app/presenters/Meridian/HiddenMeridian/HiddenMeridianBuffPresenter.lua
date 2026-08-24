local HiddenMeridianEffect = require("app.models.Meridian.HiddenMeridianBuff.HiddenMeridianEffect")

local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

local HiddenMeridianBuffPresenter = class("HiddenMeridianBuffPresenter", LayerEx)

function HiddenMeridianBuffPresenter:create()
    return HiddenMeridianBuffPresenter:new()
end

--@author:LvBin
--@time:2025-01-21 11:16:11
--@Iinput: [src.app.models.Meridian.HiddenMeridianInteractor#HiddenMeridianInteractor]
--@return
function HiddenMeridianBuffPresenter:setInput(Iinput)
    self.__input = Iinput
end

function HiddenMeridianBuffPresenter:setUI(ui)
    self.__ui = ui

    self.__ui:addTo(self)

    self.__ui:setPanelInfoVisible(false)
end

function HiddenMeridianBuffPresenter:setCallFunc(func)
    self.__callFunc = func
end

function HiddenMeridianBuffPresenter:showPresenter(acupointId)
    self.__acupointId = acupointId

    self.__index = 1

    self.__buffId = nil

    self.__sle_panel = nil

    self.__sle_title = nil

    self.__role = self.__input:getRole()

    --@RefType [src.app.models.Meridian.HiddenMeridianSystem.HiddenMeridianSystem#HiddenMeridianSystem]
    self.__sys = self.__role:getHiddenMeridianSystem()

    self.__ui:setTextTitle("调脉")

    self:__setButton1()

    self:__refreshButton()

    self:__showBuffList()

    self:__showTitleList()

    self:__setPanelInfoFunc()

    self.__ui:showUI()
end

function HiddenMeridianBuffPresenter:__refreshButton()
    self:__setButton2()

    self:__setButton3()
end

function HiddenMeridianBuffPresenter:__showTitleList()
    for i = 1, 3 do
        local titleName = self.__input:getMeridianBuffLvName(i)

        self.__ui:setPanelTitleName(i, titleName)

        if self.__index == i then
            self.__ui:setPanelTitleColor(i, {r = 255, g = 255, b = 255})
        else
            self.__ui:setPanelTitleColor(i, {r = 142, g = 142, b = 142})
        end

        self.__ui:setPanelTitleFunc(
            i,
            function()
                self.__index = i

                self.__buffId = nil

                self.__sle_panel = nil

                self:__showTitleList()

                self:__showBuffList()

                self:__refreshButton()
            end
        )
    end
end

function HiddenMeridianBuffPresenter:__showBuffList()
    self.__ui:removeListViewAllItems()

    self.__sle_panel = nil

    local buffIdList = self.__input:getHiddenMeridianBuffIdList(self.__acupointId, self.__index)

    if MapIsEmpty(buffIdList) then
        self.__ui:setTextNotBuffVisible(true)
        return
    end

    self.__ui:setTextNotBuffVisible(false)

    for _, buffId in ipairs(buffIdList) do
        local panel = self.__ui:createPanel()

        local buff = self.__sys:getHiddenMeridianBuff(buffId)

        panel.Image_di2:setVisible(false)

        panel.Image_1:setVisible(false)

        panel.Image_2:setVisible(false)

        panel.Text_name:setString(buff:getName())

        if self.__sys:isBuffUnlocked(buffId) then
            panel.Text_lock:setVisible(false)
            local effects = buff:getProperty()
            for attrIndex = 1, 4 do
                local effectData = effects[attrIndex]
                if effectData then
                    local effect = HiddenMeridianEffect:create(effectData)

                    local name = effect:getDamageName()

                    local value = Helper:mathFloor(effect:getValue() * HiddenMeridianConstants.BuffAttrMult)

                    panel["Text_attr" .. attrIndex]:setVisible(true)

                    panel["Text_attr" .. attrIndex]:setString(name .. ":" .. value)
                else
                    panel["Text_attr" .. attrIndex]:setVisible(false)
                end
            end

            if #effects <= 2 then
                panel["Text_attr1"]:setPositionY(88)
                panel["Text_attr2"]:setPositionY(88)
            end

            if self.__sys:isBuffAttach(buffId) then
                panel.Text_attach:setVisible(true)
                panel.Text_name:setTextColor({r = 55, g = 129, b = 141})
                for attrIndex = 1, 4 do
                    panel["Text_attr" .. attrIndex]:setTextColor({r = 55, g = 129, b = 141})
                end
            else
                panel.Text_attach:setVisible(false)
                panel.Text_name:setTextColor({r = 55, g = 129, b = 141})
                for attrIndex = 1, 4 do
                    panel["Text_attr" .. attrIndex]:setTextColor({r = 55, g = 129, b = 141})
                end
            end

            local text = buff:getSpecialAttrText()
            if text ~= "" then
                panel.Image_1:setVisible(true)
            end

            local text = buff:getSpecialEffectText()
            if text ~= "" then
                panel.Image_2:setVisible(true)
            end
        else
            panel.Text_attach:setVisible(false)
            panel.Text_lock:setVisible(true)
            panel.Text_name:setPositionY(115)
            panel.Text_name:setTextColor({r = 122, g = 122, b = 122})
            for attrIndex = 1, 4 do
                panel["Text_attr" .. attrIndex]:setVisible(false)
            end
        end

        panel:releaseFunc(
            function()
                if self.__sle_panel then
                    self.__sle_panel.Image_di2:setVisible(false)
                end
                self.__buffId = buffId

                panel.Image_di2:setVisible(true)

                self.__sle_panel = panel

                self:__refreshButton()
            end
        )

        self.__ui:insertPanelToListView(panel)
    end
end

function HiddenMeridianBuffPresenter:__setButton1()
    local buttonIndex = 1

    self.__ui:setButtonName(buttonIndex, "取 消")

    self.__ui:setButtonVisible(buttonIndex, true)

    self.__ui:setButtonFunc(
        buttonIndex,
        function()
            Audio:playEffect("xiaoAnNiu")

            self:hidePresenter()
        end
    )
end

function HiddenMeridianBuffPresenter:__setButton2()
    local buttonIndex = 2

    self.__ui:setButtonName(buttonIndex, "详 细")

    self.__ui:setButtonVisible(buttonIndex, self.__buffId ~= nil)

    self.__ui:setButtonFunc(
        buttonIndex,
        function()
            Audio:playEffect("xiaoAnNiu")

            self:__showPanelInfo()
        end
    )
end

function HiddenMeridianBuffPresenter:__setButton3()
    local buttonIndex = 3

    if self.__buffId == nil then
        self.__ui:setButtonVisible(buttonIndex, false)
    else
        self.__ui:setButtonVisible(buttonIndex, true)
    end

    local isUnlocked = self.__sys:isBuffUnlocked(self.__buffId)

    if isUnlocked then
        self.__ui:setButtonName(buttonIndex, "调 脉")

        self.__ui:setButtonFunc(
            buttonIndex,
            function()
                Audio:playEffect("xiaoAnNiu")

                self:__attachMeridianBuff()
            end
        )
    else
        self.__ui:setButtonName(buttonIndex, "解 锁")

        self.__ui:setButtonFunc(
            buttonIndex,
            function()
                Audio:playEffect("xiaoAnNiu")

                self:__showUnlockUI()
            end
        )
    end
end

function HiddenMeridianBuffPresenter:__setPanelInfoFunc()
    self.__ui:setPanelInfoFunc(
        function()
            Audio:playEffect("fanHuiQuXiao")

            self.__ui:setPanelInfoVisible(false)
        end
    )
end

function HiddenMeridianBuffPresenter:__showPanelInfo()
    self.__ui:setPanelInfoVisible(true)

    self.__ui:removeInfoListViewAllItems()

    local index = 0

    local buff = self.__sys:getHiddenMeridianBuff(self.__buffId)

    local panel = self.__ui:createInfoTitlePanel()

    panel.Text_1:setString(buff:getName())

    self.__ui:insertPanelToInfoListView(panel)

    index = index + 1

    local effects = buff:getProperty()

    local texts = {}

    for attrIndex = 1, 4 do
        local effectData = effects[attrIndex]
        if effectData then
            local effect = HiddenMeridianEffect:create(effectData)

            local name = effect:getDamageName()

            local value = Helper:mathFloor(effect:getValue() * HiddenMeridianConstants.BuffAttrMult)

            table.insert(texts, name .. ":" .. value)
        end
    end

    for i = 1, #texts, 1 do
        if i % 2 > 0 then
            local panel = self.__ui:createInfoAttrPanel()
            self.__ui:insertPanelToInfoListView(panel)
            index = index + 1
            panel.Text_1:setString(texts[i])
            panel.Text_2:setString("")
        else
            local panel = self.__ui:getInfoListViewItem(index - 1)
            panel.Text_2:setString(texts[i])
        end
    end

    local isUnlocked = self.__sys:isBuffUnlocked(self.__buffId)
    
    if isUnlocked == false then
        local panel = self.__ui:createInfoTitlePanel()

        panel.Text_1:setString("解锁条件")

        self.__ui:insertPanelToInfoListView(panel)

        index = index + 1

        local panel

        local str = buff:getUnlockText()

        if string.len(str) > 127 then
            panel = self.__ui:createInfoLongTextPanel()
        else
            panel = self.__ui:createInfoTextPanel()  
        end

        panel.Text_1:setString(str)

        self.__ui:insertPanelToInfoListView(panel)

        index = index + 1
    end

    local text = buff:getSpecialAttrText()

    if text ~= "" then
        local panel = self.__ui:createInfoTitlePanel()

        panel.Text_1:setString("特殊属性及效果解锁条件")

        self.__ui:insertPanelToInfoListView(panel)

        index = index + 1

        local panel = self.__ui:createInfoTextPanel()

        panel.Text_1:setString(buff:getSpecialUnlockText())

        self.__ui:insertPanelToInfoListView(panel)

        index = index + 1
    end

    local panel = self.__ui:createInfoTitlePanel()

    panel.Text_1:setString("特殊属性")

    self.__ui:insertPanelToInfoListView(panel)

    index = index + 1

    if text == "" then
        text = "无"
    end

    local panel = self.__ui:createInfoTextPanel()

    panel.Text_1:setString(text)

    self.__ui:insertPanelToInfoListView(panel)

    index = index + 1

    local text = buff:getSpecialEffectText()

    if text == "" then
        text = "无"
    end

    local panel = self.__ui:createInfoTitlePanel()

    panel.Text_1:setString("特殊效果")

    self.__ui:insertPanelToInfoListView(panel)

    index = index + 1

    local panel = self.__ui:createInfoTextPanel()

    panel.Text_1:setString(text)

    panel.Text_1:setColor(cc.c3b(255,198,0))

    self.__ui:insertPanelToInfoListView(panel)

    index = index + 1

    local isUnlocked = self.__sys:isBuffUnlocked(self.__buffId)

    if isUnlocked then
        self.__ui:setPanelInfoButton(
            "调 脉",
            function()
                Audio:playEffect("xiaoAnNiu")

                self.__ui:setPanelInfoVisible(false)

                self:__attachMeridianBuff()
            end
        )
    else
        self.__ui:setPanelInfoButton(
            "解 锁",
            function()
                Audio:playEffect("xiaoAnNiu")

                self.__ui:setPanelInfoVisible(false)

                self:__showUnlockUI()
            end
        )
    end
end

function HiddenMeridianBuffPresenter:__attachMeridianBuff()
    local isOk, msg = self.__input:canAttachMeridianBuff(self.__acupointId, self.__buffId)
    if isOk then
        self.__sys:attachMeridianBuff(self.__acupointId, self.__buffId)

        self.__buffId = nil

        self:__refreshButton()

        self:__showBuffList()

        if self.__callFunc then
            self.__callFunc()
        end
    else
        PopText(msg)
    end
end

function HiddenMeridianBuffPresenter:__showUnlockUI()
    PopupLayerController:showLayer(
        "HiddenMeridianUnlockBuffPresenter",
        function(layer)
            local ui = require("app.views.ui.Meridian.HiddenMeridian.HiddenMeridianUnlockBuffUI"):create()
            layer:setInput(self.__input)
            layer:setUI(ui)
            layer:setCallFunc(
                function()
                    self.__buffId = nil

                    self:__refreshButton()

                    self:__showBuffList()

                    if self.__callFunc then
                        self.__callFunc()
                    end
                end
            )
            layer:showPresenter(self.__buffId)
        end
    )
end

function HiddenMeridianBuffPresenter:hidePresenter()
    PopupLayerController:hideLayer(
        "HiddenMeridianBuffPresenter",
        function(layer)
            self.__ui:hideUI()
        end,
        0
    )
end

Helper:classDefNodeGetInstance(HiddenMeridianBuffPresenter)
return HiddenMeridianBuffPresenter
00000000