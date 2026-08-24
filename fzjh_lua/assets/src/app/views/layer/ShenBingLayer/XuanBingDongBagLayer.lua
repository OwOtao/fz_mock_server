local XuanBingDongBagLayer = class("XuanBingDongBagLayer", cc.Layer)

function XuanBingDongBagLayer:create()
    local p = XuanBingDongBagLayer:new()
    p:init()
    return p
end

function XuanBingDongBagLayer:init()
    self._UI = require("app.views.ui.ShenBing.XuanBingDongBagUI"):create()
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self._interactor = require("app.models.ShenBing.XuanBingDongBag"):create()
    self._interactor:setRole(User:getRole())

    self._UI:setButtonBack(function()
        self:hideLayer()
    end)
end

function XuanBingDongBagLayer:setInputModel(inputModel)
    self._inputModel = inputModel
end

function XuanBingDongBagLayer:setInputUi(inputUi)
    self._inputUi = inputUi
end

function XuanBingDongBagLayer:showUI()
    self._interactor:initList()

    self:initUI()
    self._UI:showUI()
end

function XuanBingDongBagLayer:hideLayer()
    PopupLayerController:hideLayer("XuanBingDongBagLayer",function()
        self._UI:hideUI()
        self._inputUi:onResume()
        self._inputUi:setCollectDesc()
        self._inputUi:setNumText()
        self._inputUi:showCurrList()
    end)
end

function XuanBingDongBagLayer:initUI()
    self._UI:setButton_1Text("神兵")
    self._UI:setButton_1TouchEnabled(false)
    self._UI:setButton_1Texture("Image/UI/ShenBing/btn_white_grey.png")
    self._UI:setButton_1Func(function()
        self:showShenBingAll()
        self:initTypeList()
        self._UI:setButton_1TouchEnabled(false)
        self._UI:setButton_2TouchEnabled(true)
        self._UI:setButton_2Texture("Image/UI/ShenBing/btn_black_grey.png")
        self._UI:setButton_1Texture("Image/UI/ShenBing/btn_white_grey.png")
    end)

    self._UI:setButton_2TouchEnabled(true)
    self._UI:setButton_2Text("普通兵器")
    self._UI:setButton_2Texture("Image/UI/ShenBing/btn_black_grey.png")
    self._UI:setButton_2Func(function()
        self:showNormalAll()
        self:initTypeList()
        self._UI:setButton_1TouchEnabled(true)
        self._UI:setButton_2TouchEnabled(false)
        self._UI:setButton_2Texture("Image/UI/ShenBing/btn_white_grey.png")
        self._UI:setButton_1Texture("Image/UI/ShenBing/btn_black_grey.png")
    end)

    self:showShenBingAll()
    self:initTypeList()
end

function XuanBingDongBagLayer:showShenBingAll()
    local list = self._interactor:getShenBingItems()
    local itemInfo = {}
    for i, v in ipairs(list) do
        local info = {}
        info.itemId = v.itemId
        info.text1 = v.name
        info.text2 = "伤害力+" .. tostring(v.damage)
        info.text3 = "成功淬炼" .. tostring(v.cuilianCount) .."次"
        info.posX = 696
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType1 = "shenbing"
    self.__listType2 = ""

    self._UI:initItemList(itemInfo)
end

function XuanBingDongBagLayer:showShenBingItemsByType(type)
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
        info.text3 = "成功淬炼" .. tostring(v.cuilianCount) .."次"
        info.posX = 696
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType1 = "shenbing"
    self.__listType2 = type

    self._UI:initItemList(itemInfo)
end

function XuanBingDongBagLayer:showNormalAll()
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
            local panelInfo = self:getClickOneItemInfo(v)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType1 = "normal"
    self.__listType2 = ""
    
    self._UI:initItemList(itemInfo)
end

function XuanBingDongBagLayer:showNormalItemsByType(type)
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
            local panelInfo = self:getClickOneItemInfo(v)
            self._UI:initItemDescPanel(panelInfo)
        end
        
        table.insert(itemInfo, info)
    end

    self.__listType1 = "normal"
    self.__listType2 = type
    
    self._UI:initItemList(itemInfo)
end

function XuanBingDongBagLayer:getClickOneItemInfo(itemInfo)
    local itemId = itemInfo.itemId
    local itemAttr = self._interactor:getOneItemByKey(itemId)
    if not itemAttr then
        error("item is not found!! itemId is "..tostring(itemId))
    end

    local info = {}
    info.text1 = itemAttr.name
    info.text2 = itemAttr.wpType or itemAttr:getItemShowType()
    info.text3 = itemAttr:getDsc()

    info.btnName = "放\n入"

    info.func1 = function()
        self._UI:itemDescHide(true)

        local ItemDescInfo = require("app.models.item.ItemDescInfo")
        local weaponInfo
        local isBreakage = false
        if itemInfo.wanhaodu == 0 then
            isBreakage = true
        end

        if self.__listType1 == "shenbing" then
            weaponInfo = ItemDescInfo:getShenBingDescInfo(itemAttr, User:getRole())
        elseif self.__listType1 == "normal" then
            weaponInfo = ItemDescInfo:getNormalWeaponDescInfo(itemAttr, isBreakage, User:getRole())
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
        if self._inputModel:checkItemCanPut(itemInfo) and clickState then
            clickState = false
            local result = self._inputModel:putItem(itemInfo, function()
                self._interactor:initList()

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

                self._UI:itemDescHide(true)
                clickState = true
            end)

            if result == false then
                clickState = true
            end
        end
    end

    return info
end

function XuanBingDongBagLayer:initTypeList()
    local type1List = {"全部","刀类","剑类","棍类","鞭类","双持","暗器","乐器"}
    local type2List = {"","刀","剑","棍","鞭","双持","暗器","乐器"}

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

Helper:classDefNodeGetInstance(XuanBingDongBagLayer)

return XuanBingDongBagLayer
0