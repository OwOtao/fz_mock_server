local XuanBingDongLayer = class("XuanBingDongLayer", cc.Layer)
local PoisonUtil = require("app.models.Poison.PoisonUtil")
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

function XuanBingDongLayer:create()
    local p = XuanBingDongLayer:new()
    p:init()
    return p
end

function XuanBingDongLayer:init()
    self._UI = require("app.views.ui.ShenBing.XuanBingDongUI"):create()
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    --@RefType [src.app.models.ShenBing.XuanBingDongModel#XuanBingDongModel]
    self._interactor = require("app.models.ShenBing.XuanBingDongModel"):getInstance()

    self.__listType1 = "shenbing"
    self.__listType2 = ""
    self._inRoom = false
end

function XuanBingDongLayer:show()
    if not self._interactor:isInit() then
        self._interactor:getListFromServer(
            function()
                self:initUI()
            end
        )
    else
        self:initUI()
    end
end

function XuanBingDongLayer:setInRoom(isRoom)
    self._inRoom = isRoom
end

function XuanBingDongLayer:initUI()
    self:setNeiLiText()
    self:setCollectDesc()
    self:setDescText()
    self:setNumText()
    self:initButtons()
    self:showCurrList()
    self:initTypeList()
end

function XuanBingDongLayer:setNeiLiText()
    local desc = self._interactor:getRoleNeiLiDesc()

    self._UI:setText_1(desc)
end

function XuanBingDongLayer:setCollectDesc()
    local desc = self._interactor:getCollectDesc()

    self._UI:setText_2(desc)
end

function XuanBingDongLayer:setDescText()
    local desc = self._interactor:getNormalTextDesc()
    if self._inRoom == true then
        desc = self._interactor:getHomeLandTextDesc()
    end

    self._UI:setText_3(desc)
end

function XuanBingDongLayer:setNumText()
    local desc = self._interactor:getNumDesc()

    self._UI:setText_4(desc)
end

function XuanBingDongLayer:initButtons()
    local enabled1 = false
    local enabled2 = true
    local texture1 = "Image/UI/ShenBing/btn_white_grey.png"
    local texture2 = "Image/UI/ShenBing/btn_black_grey.png"
    if self.__listType1 ~= "shenbing" then
        texture1 = "Image/UI/ShenBing/btn_black_grey.png"
        texture2 = "Image/UI/ShenBing/btn_white_grey.png"
        enabled1 = true
        enabled2 = false
    end
    self._UI:setButton_1TouchEnabled(enabled1)
    self._UI:setButton_1Texture(texture1)
    self._UI:setButton_1Text("神兵")
    self._UI:setButton_1Func(
        function()
            self:showShenBingAll()
            self:initTypeList()
            self._UI:setButton_1TouchEnabled(false)
            self._UI:setButton_2TouchEnabled(true)
            self._UI:setButton_2Texture("Image/UI/ShenBing/btn_black_grey.png")
            self._UI:setButton_1Texture("Image/UI/ShenBing/btn_white_grey.png")
        end
    )

    self._UI:setButton_2TouchEnabled(enabled2)
    self._UI:setButton_2Text("普通兵器")
    self._UI:setButton_2Texture(texture2)
    self._UI:setButton_2Func(
        function()
            self:showNormalAll()
            self:initTypeList()
            self._UI:setButton_1TouchEnabled(true)
            self._UI:setButton_2TouchEnabled(false)
            self._UI:setButton_2Texture("Image/UI/ShenBing/btn_white_grey.png")
            self._UI:setButton_1Texture("Image/UI/ShenBing/btn_black_grey.png")
        end
    )

    self._UI:setButton_3Func(
        function()
            if self._interactor:checkCanUpgrade() == false then
                PopText("当前空间已达上限")
                return
            end

            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            local info = self._interactor:getNextLevelInfo()
            local currencyName = self._interactor:getCurrencyName(info.currency)
            dialog:show("当前悬兵洞可储存武器：" .. tostring(self._interactor:getCurrLimit()) .. "\n\n" .. "\n花费" .. tostring(info.count) .. currencyName .. "可升级到" .. tostring(info.bagcount) .. "把")
            dialog:setButton1(
                "升级",
                function()
                end
            )
            dialog:setButton2("否")
            dialog:setWeChatVisible(false)
        end
    )

    self._UI:setButton_4Func(
        function()
            PopupLayerController:showLayer(
                "XuanBingDongBagLayer",
                function(layer)
                    layer:setInputModel(self._interactor)
                    layer:setInputUi(self)
                    self:onPause()

                    layer:showUI()
                end
            )
        end
    )
end

function XuanBingDongLayer:showCurrList()
    if self.__listType1 == "shenbing" then
        if self.__listType2 and self.__listType2 ~= "" then
            self:showShenBingItemsByType(self.__listType2)
        else
            self:showShenBingAll()
        end
    elseif self.__listType1 == "normal" then
        if self.__listType2 and self.__listType2 ~= "" then
            self:showNormalItemsByType(self.__listType2)
        else
            self:showNormalAll()
        end
    end
end

function XuanBingDongLayer:showShenBingAll()
    local list = self._interactor:getShenBingItems()
    local itemInfo = {}
    for i, v in ipairs(list) do
        local info = {}
        info.itemId = v.itemId
        info.text1 = v.name
        info.text2 = "伤害力+" .. tostring(v.damage)
        info.text3 = "成功淬炼" .. tostring(v.cuilianCount) .. "次"
        info.posX = 696
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v.itemId)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType1 = "shenbing"
    self.__listType2 = ""

    self:initItemList(itemInfo)
end

function XuanBingDongLayer:showShenBingItemsByType(type)
    if not type then
        return
    end

    local list = self._interactor:getShenBingItemsByType(type)
    local itemInfo = {}
    for i, v in ipairs(list) do
        local info = {}
        info.itemId = v.itemId
        info.text1 = v.name
        info.text2 = "伤害力+" .. tostring(v.damage)
        info.text3 = "成功淬炼" .. tostring(v.cuilianCount) .. "次"
        info.posX = 696
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v.itemId)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType1 = "shenbing"
    self.__listType2 = type

    self:initItemList(itemInfo)
end

function XuanBingDongLayer:showNormalAll()
    local list = self._interactor:getNormalItems()
    local itemInfo = {}
    for i, v in ipairs(list) do
        local info = {}
        info.itemId = v.itemId
        info.text1 = v.name
        info.text2 = "伤害力+" .. tostring(v.damage)
        info.text3 = v.bType
        info.posX = 768
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v.itemId)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType1 = "normal"
    self.__listType2 = ""

    self:initItemList(itemInfo)
end

function XuanBingDongLayer:showNormalItemsByType(type)
    if not type then
        return
    end

    local list = self._interactor:getNormalItemsByType(type)
    local itemInfo = {}
    for i, v in ipairs(list) do
        local info = {}
        info.itemId = v.itemId
        info.text1 = v.name
        info.text2 = "伤害力+" .. tostring(v.damage)
        info.text3 = v.bType
        info.posX = 768
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v.itemId)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType1 = "normal"
    self.__listType2 = type

    self:initItemList(itemInfo)
end

function XuanBingDongLayer:getClickOneItemInfo(itemId)
    local itemAttr = self._interactor:getOneItemByKey(itemId)
    if not itemAttr then
        error("item is not found!! itemId is" .. tostring(itemId))
    end

    local info = {}
    info.text1 = itemAttr.name
    info.text2 = itemAttr.wpType or itemAttr:getItemShowType()
    info.text3 = itemAttr:getDsc()
    info.visible = false

    info.func1 = function()
        self._UI:itemDescHide(true)
        local ItemDescInfo = require("app.models.item.ItemDescInfo")
        local weaponInfo

        if self.__listType1 == "shenbing" then
            weaponInfo = ItemDescInfo:getShenBingDescInfo(itemAttr, User:getRole())
        elseif self.__listType1 == "normal" then
            weaponInfo = ItemDescInfo:getNormalWeaponDescInfo(itemAttr, false, User:getRole())
        end

        PopupLayerController:showLayer(
            "WeaponDescInfoPresenter",
            function(layer)
                layer:setData(weaponInfo)
                layer:showLayer()
            end
        )
    end

    local clickState = true
    info.func2 = function()
        if self._interactor:checkItemCanOut(itemId) and clickState then
            clickState = false
            local result =
                self._interactor:outItem(
                itemId,
                function()
                    self:showCurrList()
                    self:setCollectDesc()
                    self:setNumText()
                    self._UI:itemDescHide(true)
                    clickState = true
                end
            )

            if result == false then
                clickState = true
            end
        end
    end

    return info
end

function XuanBingDongLayer:initItemList(list)
    self._UI.ListView_item:setVisible(false)
    self._UI.ListView_item:setSwallowTouches(false)

    if MapIsEmpty(list) then
        self._UI.ListView_item:removeAllItems()
        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end
        return
    end

    local roleItemNum = #list
    local listSize = self._UI.ListView_item:getContentSize()
    local itemSize = self._UI.Panel_item:getContentSize()
    local itemsMargin = self._UI.ListView_item:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height / (itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self._UI.ListView_item:setItemHeight(itemSize.height)

    self._UI.ListView_item:setItemInitFunc(
        function(item, info)
            self._UI:initPanelInfo(item, info)
        end
    )

    self._UI.ListView_item:setItemCreateFunc(
        function()
            return self._UI:getItemPanel()
        end
    )

    self._UI.ListView_item:showListView(list, itemMaxCount)

    self._UI.ListView_item:setVisible(true)

    if isSchedule then
        self._UI.ListView_item:jumpToTop()

        local isTrue = self._UI.ListView_item:refreshReuseItems()
        while isTrue do
            isTrue = self._UI.ListView_item:refreshReuseItems()
        end

        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end

        self.listViewSchedule =
            self:schedule(
            function()
                self._UI.ListView_item:refreshReuseItems()
            end
        )
    else
        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end
    end
end

function XuanBingDongLayer:initTypeList()
    local type1List = {"全部", "刀类", "剑类", "棍类", "鞭类", "双持", "暗器", "乐器"}
    local type2List = {"", "刀", "剑", "棍", "鞭", "双持", "暗器", "乐器"}

    local list = {}
    for i, v in ipairs(type1List) do
        local info = {}
        info.text1 = v
        info.visible = self.__listType2 == type2List[i]
        info.func = function()
            if self.__listType1 == "shenbing" then
                if type2List[i] == "" then
                    self:showShenBingAll()
                else
                    self:showShenBingItemsByType(type2List[i])
                end
            elseif self.__listType1 == "normal" then
                if type2List[i] == "" then
                    self:showNormalAll()
                else
                    self:showNormalItemsByType(type2List[i])
                end
            end
            self:initTypeList()
        end
        table.insert(list, info)
    end

    self._UI:initTypeListView(list)
end

function XuanBingDongLayer:onResume()
    local list = {
        ["android"] = true
        -- ["ios"] = {},
        -- ["fzjh"] = {},
    }
    local titleLayer = MainControllLayer:getLayer("TitleLayer")
    if titleLayer then
        titleLayer:setTipFunc(
            function(func)
                if list[device.platform] ~= nil and (list[device.platform] == true or list[device.platform][CURR_DEVICE_CHANNEL] == true) then
                    local DialogKlayer = require("app.views.layer.DialogLayer.ShenBingGuiZe")
                    local dialog = DialogKlayer:getInstance()
                    dialog:hide()
                    local str =
                        "CYN藏衣阁规则：\n藏衣阁可将珍贵稀有的衣服饰品放入其中，同种衣服饰品只能放入一件，珍贵稀有的衣服饰品会提升收藏评价。\n注：普通衣物不可放入藏衣阁\n \n悬兵洞规则：\n悬兵洞可将珍贵稀有的兵器放入其中，同种兵器只能放入一把，珍贵稀有的兵器会提升收藏评价，神兵也可放入悬兵洞、但没有收藏评价。\n注：普通兵器不可放入悬兵洞\n \n悬兵洞与藏衣室内的道具可进行传承，神兵系统在传承后会直接开启。"

                    dialog:showLayer("收藏规则", str, func)
                else
                    local DialogKlayer = require("app.views.layer.DialogLayer.DialogKLayer")
                    local dialog = DialogKlayer:getInstance()
                    dialog:hide()
                    local str =
                        "藏衣阁规则：\n藏衣阁可将珍贵稀有的衣服饰品放入其中，同种衣服饰品只能放入一件，珍贵稀有的衣服饰品会提升收藏评价。\n注：普通衣物不可放入藏衣阁\n \n悬兵洞规则：\n悬兵洞可将珍贵稀有的兵器放入其中，同种兵器只能放入一把，珍贵稀有的兵器会提升收藏评价，神兵也可放入悬兵洞、但没有收藏评价。\n注：普通兵器不可放入悬兵洞\n \nHIY悬兵洞与藏衣室内的道具可进行传承，神兵系统在传承后会直接开启。"

                    dialog:showLayer("收藏规则", str, func)
                end
            end
        )
    end
end

function XuanBingDongLayer:onPause()
    if self.listViewSchedule then
        self:unschedule(self.listViewSchedule)
        self.listViewSchedule = nil
    end
    self._UI:itemDescHide()
end

return XuanBingDongLayer
0000000000000000