local ShenBingWareHouseLayer = class("ShenBingWareHouseLayer", cc.Layer)

function ShenBingWareHouseLayer:create()
    local p = ShenBingWareHouseLayer:new()
    p:init()
    return p
end

function ShenBingWareHouseLayer:init()
    self._UI = require("app.views.ui.ShenBing.ShenBingWareHouseUI"):create()
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self._interactor = require("app.models.ShenBing.ShenBingWareHouse"):create()
    self._interactor:setRole(User:getRole())
end

function ShenBingWareHouseLayer:setBackConditionFunc(func)
    self._backConditionFunc = func
end

function ShenBingWareHouseLayer:showUI()
    self._interactor:initShenBingItems()
    self:initUI()
end

function ShenBingWareHouseLayer:hideLayer()
    local result = true
    if self._backConditionFunc then
        result = self._backConditionFunc()
    end

    if result then
        PopupLayerController:hideLayer("ShenBingWareHouseLayer",function()
            self._UI:hideUI()
        end)
    end
end

function ShenBingWareHouseLayer:initUI()
    self:setNumText()
    self:showShenBingAll()
    self:initTypeList()

    self._UI:setButtonBack(function()
        self:hideLayer()
    end)

    self._UI:showUI()
end

function ShenBingWareHouseLayer:setNumText()
    local list = self._interactor:getShenBingItems()
    local text = "携带上限："..tostring(#list) .. "/" .. tostring(self._interactor:getShenBingLimit())

    self._UI:setText_2(text)
end

function ShenBingWareHouseLayer:showShenBingAll()
    local list = self._interactor:getShenBingItems()
    local itemInfo = {}
    for i, v in ipairs(list) do
        local info = {}
        info.itemId = v.itemId
        info.text1 = v.name
        info.text2 = "伤害力+" .. tostring(v.damage)
        info.text3 = "成功淬炼" .. tostring(v.cuilianCount) .."次"
        info.posX = 696
        info.visible = self._interactor:checkShenBingIsDefault(v.itemId) == true
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v.itemId)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType = ""

    self._UI:initItemList(itemInfo)
end

function ShenBingWareHouseLayer:showShenBingItemsByType(type)
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
        info.visible = self._interactor:checkShenBingIsDefault(v.itemId) == true
        info.func = function()
            self._UI:itemDescShow(true)
            local panelInfo = self:getClickOneItemInfo(v.itemId)
            self._UI:initItemDescPanel(panelInfo)
        end

        table.insert(itemInfo, info)
    end

    self.__listType = type

    self._UI:initItemList(itemInfo)
end

function ShenBingWareHouseLayer:getClickOneItemInfo(itemId)
    local itemAttr = self._interactor:getOneItemByKey(itemId)
    if not itemAttr then
        error("item is not found!! itemId is "..tostring(itemId))
    end

    local info = {}
    info.text1 = itemAttr.name
    info.text2 = itemAttr.wpType or itemAttr:getItemShowType()
    info.text3 = itemAttr:getDsc()

    local isDefault = self._interactor:checkShenBingIsDefault(itemId)
    if isDefault then
        info.btnName = "卸默\n下认"
    else
        info.btnName = "设默\n置认"
    end

    info.func1 = function()
        self._UI:itemDescHide(true)
        local ItemDescInfo = require("app.models.item.ItemDescInfo")
        local weaponInfo = ItemDescInfo:getShenBingDescInfo(itemAttr, User:getRole())
        PopupLayerController:showLayer(
            "WeaponDescInfoPresenter",
            function(layer)
                layer:setData(weaponInfo)
                layer:showLayer()
            end
        )
    end

    info.func2 = function()
        self._UI:itemDescHide(true)
        
        if isDefault then
            self._interactor:setDefaultShenBing()
        else
            self._interactor:setDefaultShenBing(itemId)
        end
        
        if self.__listType == "" then
            self:showShenBingAll()
        else
            self:showShenBingItemsByType(self.__listType)
        end
    end

    return info
end

function ShenBingWareHouseLayer:initTypeList()
    local type1List = {"全部","刀类","剑类","棍类","鞭类","双持","暗器","乐器"}
    local type2List = {"","刀","剑","棍","鞭","双持","暗器","乐器"}

    local list = {}
    for i, v in ipairs(type1List) do
        local info = {}
        info.text1 = v
        info.visible = self.__listType == type2List[i]
        info.func = function()
            if v == "全部" then
                self:showShenBingAll()
            else
                self:showShenBingItemsByType(type2List[i])
            end
            self:initTypeList()
        end
        table.insert(list, info)
    end

    self._UI:initTypeListView(list)
end

Helper:classDefNodeGetInstance(ShenBingWareHouseLayer)

return ShenBingWareHouseLayer
0000000000