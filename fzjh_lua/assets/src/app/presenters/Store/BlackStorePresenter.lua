local BlackStorePresenter = class("BlackStorePresenter", cc.Layer)

function BlackStorePresenter:create()
    local p = BlackStorePresenter:new()
    p:init()
    return p
end

function BlackStorePresenter:init()
    self._UI = require("app.views.ui.ActionUI.StoreUI"):create()

    self._UI:addTo(self)

    local BlackStore = require("app.models.Store.BlackStore")

    self._interactor = BlackStore:create()
    self._interactor:setUI(self)
end

function BlackStorePresenter:setRole(role)
    self._interactor:setRole(role)
    self._role = role
end

function BlackStorePresenter:showLayer()
    self._interactor:initStore(function()
        self:initUI()
        self._UI:showUI()
    end)
end

function BlackStorePresenter:setBackCallBackFunc(func)
    if func then
        self._backCallFunc = func
    end
end

function BlackStorePresenter:hideLayer()
    PopupLayerController:hideLayer("BlackStorePresenter",function()
        self._UI:hideUI()
    end)
end 

function BlackStorePresenter:initUI()
    self._UI:setDesc("背包容量："..self._interactor:getRoleItemNum().."/"..self._interactor:getRoleItemLimit())
    self._UI:setWeightText("")
    self._UI:setTipsVisible(false)
    self._UI:setLeftTitle("背包")
    self._UI:setRightTitle("黑市商人")
    self._UI:setCurrencyText(self._interactor:getMainCurrencyName().."：".. Helper:mathFloor(self._interactor:getMainCurrencyNum()))
    self._UI:setButton1Visible(true)
    self._UI:setButton2Visible(true)
    self._UI:setButton1Name("离开")
    self._UI:setButton1Func(function()
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:show()
        dialog:setRichText("选择离开后，将取消本次交易的所有己购买和已出售内容，若需要继续交易请点击返回，是否确定离开?")
        dialog:setButton1("确定", function()
            self:hideLayer()
        end)
        dialog:setButton2("返回", function()
            dialog:hide()
        end)
        dialog:setWeChatVisible(false)
    end)

    self._UI:setButton2Name("交易完成")
    self._UI:setButton2Func(function()
        local soldItems = self._interactor:getRoleSoldItems()
        local boughtItems = self._interactor:getRoleBoughtItems()

        if MapIsEmpty(soldItems) and MapIsEmpty(boughtItems) then
            PopText("少侠尚未交易任何商品")
            return
        end

        PopupLayerController:showLayer("BlackStoreResultPresenter",function(layer)
            layer:setBoughttList(boughtItems)
            layer:setSoldList(soldItems)
            layer:setBuyText("合计消耗："..self._interactor:getRoleBoughtItemPriceText())
            layer:setSellText("合计获得："..self._interactor:getRoleSoldItemsPriceText())
            
            layer:setButton1Func(function()
                self._interactor:settlement(function()
                    self:hideLayer()
                    if self._backCallFunc then
                        self._backCallFunc()
                    end
                    
                    layer:hideLayer()
                end)
            end)
            layer:showLayer()
        end)
        
    end)

    self:__initLeftList()
    self:__initRightList()
end

function BlackStorePresenter:refreshUI()
    self._UI:setCurrencyText(self._interactor:getMainCurrencyName().."：".. Helper:mathFloor(self._interactor:getMainCurrencyNum()))
    self._UI:setDesc("背包容量："..self._interactor:getRoleItemNum().."/"..self._interactor:getRoleItemLimit())

    self:__initLeftList()
    self:__initRightList()
end

function BlackStorePresenter:__initLeftList()
    local list = self._interactor:getLeftList()
    for i, item in ipairs(list) do
        item.func = function()
            local canSell, arg = self._interactor:checkCanSellGoods(item)
            if canSell == false then
                PopText(arg)
                return
            end

            local maxCount = arg

            if maxCount == 1 then
                local goodsInfo = inherit({},item)
                goodsInfo.count = 1
                self._interactor:sellGoods(goodsInfo, function()
                    self:refreshUI()
                end)
                return
            end

            local restoreCount = self._interactor:getItemInRightSoldListCount(item.itemId)
            
            PopupLayerController:showLayer("BlackStoreGoodsSelectPresenter",function(layer)
                local itemAttr = self._role:getOneItemByKey(item.itemId)
                layer:setTitle("物品详情")
                layer:setTextDesc_1("    "..itemAttr.dsc)
                layer:setTextDesc_2("")
                layer:setTextDesc_3(itemAttr.name,1)
                layer:setText_1Str("将获得：")
                layer:setItemName(itemAttr.name)
                layer:setUnitPrice(Helper:getDef(itemAttr.salePrice, 0))
                layer:setPriceName("碎银")
                layer:setText_2Str(tostring(Helper:getDef(itemAttr.salePrice, 0)).."碎银")

                if restoreCount > 0 then
                    local restorePrice, restorePriceUnit = self._interactor:getGoodsPriceAndPriceUnit(item.itemId)
                    local priceName = self._interactor:getCurrencyName(restorePriceUnit)
                    layer:setExtraUnitPrice(Helper:getDef(restorePrice, 0))
                    layer:setExtraPriceName(priceName)
                    layer:setExtraBuyNumer(restoreCount)
                    layer:setText_2Str(tostring(Helper:getDef(restorePrice, 0))..priceName)
                else
                    layer:setExtraUnitPrice(0)
                    layer:setExtraPriceName("碎银")
                    layer:setExtraBuyNumer(0)
                end
                
                layer:setBuyNumber(1)
                layer:setMaxBuyNumber(maxCount)
                layer:setSelectText(tostring(1).."/"..tostring(maxCount))

                layer:setButton_1Func(function(buyNumber)
                    local goodsInfo = inherit({},item)
                    goodsInfo.count = buyNumber
                    self._interactor:sellGoods(goodsInfo, function()
                        self:refreshUI()
                    end)
                end)

                layer:setButton_2Func(function()
                    layer:hideLayer()
                end)

                layer:showLayer()
            end)
        end
    end

    self._UI:setLeftList(list)
end

function BlackStorePresenter:__initRightList()
    local list = self._interactor:getRightList()
    for i, item in ipairs(list) do
        item.func = function()
            local itemAttr = self._role:getOneItemByKey(item.itemId)
            local textList = {
                Text_tital = item.name,
                Text_type = itemAttr:getItemShowType(),
                Text_dsc = itemAttr.dsc,
                Text_price = "售价:"..item.price,
                Text_affirm = "确定购买"..item.name.."吗？",
                Text_havenum = "已拥有:".. self._interactor:getRoleItemCount(item.itemId)..itemAttr.unit,
            }
        
            PopupLayerController:showLayer("ShoppingDialogLayer",function(layer)
                layer:showLayer(textList,function()
                end)

                layer:setButton_confirm("确定", function()
                    local goodsInfo = inherit({},item)
                    goodsInfo.count = 1
                    self._interactor:buyGoods(goodsInfo, function()
                        self:refreshUI()
                    end)
                end)
                layer:setButton_close("取消", function()
                end)
            end)
        end
    end

    self._UI:setRightList(list)
end

Helper:classDefNodeGetInstance(BlackStorePresenter)
return BlackStorePresenter0000000000000