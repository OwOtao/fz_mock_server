local StorePresenter = class("StorePresenter", cc.Layer)
local GoodsHelper = require("app.models.Store.GoodsHelper")
local StoreHelper = require("app.models.Store.StoreHelper")
local Store = require("app.models.Store.Store")
local GoodsPresenterFactory = require("app.presenters.GoodsInfo.GoodsPresenterFactory")

function StorePresenter:create()
    local p = StorePresenter:new()
    p:init()
    return p
end

function StorePresenter:init()
    --@RefType [StoreUI]
    self._UI = require("app.views.ui.ActionUI.StoreUI"):create()

    self._UI:addTo(self)
    self._UI:addButton3()
    self._UI:initButtonPos()
    self._UI:setTipsPos(540, 300)

    self._interactor = Store:create()
    self._interactor:setUI(self)
end

function StorePresenter:setRole(role)
    self._interactor:setRole(role)
    self._role = role
end

function StorePresenter:setStore(npc)
    self._interactor:setStore(npc)
    self._npc = npc
end

function StorePresenter:setStoreLeftBag(bagType, role)
    local BagFactory = require("app.models.Store.StoreBag.BagFactory")
    local bag = BagFactory:create(bagType, role)

    self._interactor:setLeftBag(bag)
end

function StorePresenter:showLayer()
    for i = 1, 4, 1 do
        self._UI:setStoreText(i, "")
    end

    self._interactor:initStore(
        0,
        function()
            self:initUI()
            self._UI:showUI()
        end
    )
end

function StorePresenter:setBackCallBackFunc(func)
    if func then
        self._backCallFunc = func
    end
end

function StorePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "StorePresenter",
        function()
            self._UI:hideUI()
        end
    )
end

function StorePresenter:initUI()
    self._UI:setStoreTextVisible(true)
    self._UI:setStoreText(1, "背包容量：" .. self._interactor:getRoleItemNum() .. "/" .. self._interactor:getRoleItemLimit())
    self._UI:setDesc("")
    self._UI:setWeightText("")
    self._UI:setLeftTitle("背包")
    self._UI:setRightTitle(self._npc:getName())
    self._UI:setCurrencyText("")
    self._UI:setButton1Visible(true)
    self._UI:setButton2Visible(true)
    self._UI:setButton1Name("离开")
    self._UI:setButton1Func(
        function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:show()
            dialog:setRichText("选择离开后，将取消本次交易的所有已购买和已出售内容，若需要继续交易请点击返回，是否确定离开?")
            dialog:setButton1(
                "确定",
                function()
                    self:hideLayer()
                end
            )
            dialog:setButton2(
                "返回",
                function()
                    dialog:hide()
                end
            )
            dialog:setWeChatVisible(false)
        end
    )

    self._UI:setButton2Name("交易完成")
    self._UI:setButton2Func(
        function()
            local soldItems = self._interactor:getRoleSoldItems()
            local boughtItems = self._interactor:getRoleBoughtItems()

            if MapIsEmpty(soldItems) and MapIsEmpty(boughtItems) then
                PopText("少侠尚未交易任何商品")
                return
            end

            PopupLayerController:showLayer(
                "BlackStoreResultPresenter",
                function(layer)
                    layer:setBoughttList(boughtItems)
                    layer:setSoldList(soldItems)
                    layer:setBuyText("合计消耗：" .. self._interactor:getRoleBoughtItemPriceText())
                    layer:setSellText("卖出获得：" .. self._interactor:getRoleSoldItemsPriceText())
                    layer:setTipText("")

                    layer:setButton1Func(
                        function()
                            self._interactor:settlement(
                                function()
                                    self:hideLayer()
                                    if self._backCallFunc then
                                        self._backCallFunc()
                                    end

                                    layer:hideLayer()
                                end
                            )
                        end
                    )
                    layer:showLayer()
                end
            )
        end
    )

    local refreshState = self._interactor:getRefreshState()
    if refreshState == 0 then
        self._UI:setButton3Visible(false)
        self._UI:setTipsVisible(false)
    else
        self._UI:setTipsVisible(true)
        self._UI:setTips(StoreHelper:getStoreRefreshText(self._npc.id) .. "刷新\n当前刷新" .. self._interactor:getRefreshCost() .. self._interactor:getRefreshCostCurrencyName())
        self._UI:setButton3Visible(true)
        self._UI:setButton3Name("刷新")

        local texture = "Image/UI/TaskUI/anniu.png"
        if refreshState > 1 then
            texture = "Image/UI/TaskUI/anniuhui.png"
        end

        self._UI:setButton3Texture(texture)
        self._UI:setButton3Func(
            function()
                if refreshState > 1 then
                    PopText(self._interactor:getRefreshStateText())
                    return
                end

                local soldItems = self._interactor:getRoleSoldItems()
                local boughtItems = self._interactor:getRoleBoughtItems()

                if MapIsEmpty(soldItems) and MapIsEmpty(boughtItems) then
                    self._interactor:initStore(
                        1,
                        function()
                            self._interactor:refresh()
                            self:initUI()
                            PopText("刷新成功")
                        end
                    )
                    return
                end

                local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                local dialog = DialogALayer:getInstance()
                dialog:show()
                dialog:setRichText("刷新后会清除当前未结算商品，若不想未结算商品出现丢失的情况，请先点击交易完成进行商品结算后再进行刷新。")
                dialog:setButton1(
                    "确定刷新",
                    function()
                        self._interactor:initStore(
                            1,
                            function()
                                self._interactor:refresh()
                                self:initUI()
                                PopText("刷新成功")
                            end
                        )
                    end
                )
                dialog:setButton2(
                    "返回",
                    function()
                        dialog:hide()
                    end
                )
                dialog:setWeChatVisible(false)
            end
        )
    end

    self:showCurrencyText()
    self:__initLeftList()
    self:__initRightList()
end

function StorePresenter:refreshUI()
    self:showCurrencyText()
    self._UI:setStoreText(1, "背包容量：" .. self._interactor:getRoleItemNum() .. "/" .. self._interactor:getRoleItemLimit())

    self:__initLeftList()
    self:__initRightList()
end

function StorePresenter:showCurrencyText()
    local currencyShowList = self._interactor:getCurrencyShowList()
    local CurrencyUtil = require("app.models.Currency.CurrencyUtil")

    for i = 1, #currencyShowList, 1 do
        if i < 4 then
            local currencyId = currencyShowList[i]
            local num = self._interactor:getCurrencyNum(currencyId)
            local name = ""
            local index = i + 1
            if CurrencyUtil:isCurrencyId(currencyId) then
                --@RefType [src.app.models.Currency.CurrencyUtil#CurrencyResClass]
                local currencyResClass = CurrencyUtil:getCurrencyResClass(currencyId)
                name = currencyResClass:getName()
                local desc = currencyResClass:getDesc()

                local tipText = nil
                if currencyResClass:isTimeClear() then
                    tipText = "货币清空时间：" .. currencyResClass:getTimeClearText()
                else
                    tipText = ""
                end
                self._UI:setStoreTextClickFunc(
                    index,
                    function()
                        self._UI:popTextDetail(index, name, desc, tipText)
                    end
                )
            else
                name = self._interactor:getCurrencyName(currencyId)
                self._UI:setStoreTextClickFunc(index, nil)
            end
            self._UI:setStoreText(index, name .. "：" .. tostring(Helper:mathFloor(num)))
        end
    end
end

function StorePresenter:__initLeftList()
    local list = self._interactor:getLeftList()
    for i, item in ipairs(list) do
        item.func = function()
            local canSell, arg = self._interactor:checkCanSellGoods({index = item.index, count = item.count, type = item.type})
            if canSell == false then
                PopText(arg)
                return
            end

            local maxCount = arg

            if maxCount == 1 then
                local goods = {count = 1, type = item.type, index = item.index}
                self._interactor:sellGoods(
                    goods,
                    function()
                        self:refreshUI()
                    end
                )
                return
            end

            local info = {}
            local itemClass = self._interactor:getItem(item.type, item.index)
            info.priceName = itemClass:getPriceName()
            info.price = itemClass:getPrice()
            info.priceUnit = itemClass:getPriceUnit()
            info.unitCount = itemClass:getUnitCount()
            info.maxCount = maxCount
            info.text1 = "将获得："
            info.text2 = ""
            info.text3 = "总持有数量：" .. tostring(self._interactor:getRoleItemCount(itemClass:getItemId()))

            info.dsc = "    " .. itemClass:getDsc()
            info.name = itemClass:getName()
			info.goodsTipText = ""
			info.goodsTipIsVisible = false
			info.goodsClickFunc = EMPTY_FUNC

            info.func = function(buyNumber)
                local goods = {count = buyNumber, type = item.type, index = item.index}

                self._interactor:sellGoods(
                    goods,
                    function()
                        self:refreshUI()
                    end
                )
            end

            self:__showSelectLayer(info)
        end
    end

    self._UI:setLeftList(list)
end

function StorePresenter:__initRightList()
    local list = self._interactor:getRightList()
    for i, item in ipairs(list) do
        item.func = function()
            local itemClass = self._interactor:getItem(item.type, item.index)

            if (itemClass:getLimitBoughtCount() and itemClass:getLimitBoughtCount() == itemClass:getLimitCount()) then
                local goods = {count = 1, type = item.type, index = item.index}
                self._interactor:buyGoods(
                    goods,
                    function()
                        self:refreshUI()
                    end
                )
                return
            end

            local info = {}

            info.priceName = itemClass:getPriceName()
            info.price = itemClass:getPrice()
            info.priceUnit = itemClass:getPriceUnit()
            info.unitCount = itemClass:getUnitCount()
            info.maxCount = item.count
            info.dsc = "    " .. itemClass:getDsc()
            info.name = itemClass:getName()
			local goodsResClass = GoodsHelper:getGoodsResClass(itemClass:getId())
			
			if goodsResClass:getViewType() ~= 0 then
				info.goodsTipText = "点击可查看道具详情"
				info.goodsTipIsVisible = true
				info.goodsClickFunc = function()
					PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
						layer:showLayer({{id = itemClass:getId()}})
					end)
				end
			else
				info.goodsTipText = ""
				info.goodsTipIsVisible = false
				info.goodsClickFunc = EMPTY_FUNC
			end

            if self._interactor:checkGoodsTypeIsBuyType(item.type) == false then
                info.text1 = "将获得："
                info.text2 = ""
                info.text3 = "总持有数量：" .. tostring(self._interactor:getRoleItemCount(itemClass:getItemId()))
            else
                info.text1 = "将花费："
                info.text2 = ""
                if item.limitTypeText then
                    info.text2 = item.limitTypeText .. "：" .. tostring(itemClass:getLimitBoughtCount()) .. "/" .. tostring(itemClass:getLimitCount())
                    info.limitCount = itemClass:getLimitCount()
                end

                info.text3 = "剩余库存数量：" .. tostring(item.count)
                info.text4 = "总持有数量：" .. tostring(self._interactor:getRoleItemCount(itemClass:getItemId()))
            end

            info.func = function(buyNumber)
                local goods = {count = buyNumber, type = item.type, index = item.index}
                self._interactor:buyGoods(
                    goods,
                    function()
                        self:refreshUI()
                    end
                )
            end

            self:__showSelectLayer(info)
        end
    end

    self._UI:setRightList(list)
end

function StorePresenter:__showSelectLayer(selectInfo)
    PopupLayerController:showLayer(
        "StoreGoodsSelectPresenter",
        function(layer)
            layer:setTitle("物品详情")
            layer:setTextDesc_1(selectInfo.dsc)
            layer:setTextDesc_2("")
            layer:setTextDesc_3(selectInfo.name, selectInfo.unitCount)
			layer:setTextDesc_4(selectInfo.goodsTipText,selectInfo.goodsTipIsVisible,selectInfo.goodsClickFunc)
            layer:setText_1Str(selectInfo.text1)
            layer:setItemName(selectInfo.name)
            layer:setUnitPrice(selectInfo.price)
            layer:setGoodsUnitCount(selectInfo.unitCount)
            layer:setPriceName(selectInfo.priceName)
            layer:setText_2Str(tostring(selectInfo.price) .. selectInfo.priceName)
            layer:setBuyNumber(1)
            layer:setMaxBuyNumber(selectInfo.maxCount)
            layer:setLimitBuyNumber(selectInfo.limitCount)
            layer:setSelectText(tostring(1) .. "/" .. tostring(selectInfo.maxCount))
            layer:setText_3Str(Helper:getDef(selectInfo.text2, ""))
            layer:setText_4Str(Helper:getDef(selectInfo.text3, ""))
            layer:setText_5Str(Helper:getDef(selectInfo.text4, ""))

            layer:setButton_1Func(
                function(buyNumber)
                    if selectInfo.func then
                        selectInfo.func(buyNumber)
                    end
                end
            )

            layer:setButton_2Func(
                function()
                    layer:hideLayer()
                end
            )

            layer:showLayer()
        end
    )
end

Helper:classDefNodeGetInstance(StorePresenter)
return StorePresenter
00000000000