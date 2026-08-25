local class = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local Goods = require("app.models.Store.Goods")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")
local StoreHelper = require("app.models.Store.StoreHelper")
local XuanBingDongModel = require("app.models.ShenBing.XuanBingDongModel")
local ItemHelper = require("app.models.item.ItemHelper")
local StoreSellBag = require("app.models.Store.StoreBag.StoreSellBag")

local GOODS_TYPE = Goods.Const.TYPE

local Store = {}

local dis_img_path = {
    ["0.9"] = "Image/UI/StoreUI/jiuzhe.png",
    ["0.8"] = "Image/UI/StoreUI/bazhe.png",
    ["0.6"] = "Image/UI/StoreUI/liuzhe.png",
    default = "Image/UI/StoreUI/jiuzhe.png"
}

local GoodsType = {
    SellType = 1, --玩家售卖的商品
    BuyType = 2, --从商店购买的商品
    RedeemType = 3, --玩家上一次已售卖的商品
    BagType = 4 --玩家当前背包商品
}

local CHECK_CAN_BUY_FAIL_TYPE = {
    POP_TEXT = "popText",
    DUPLICATE_PURCHASE = "duplicatePurchase"
}

local createCheckCanBuyPopTextFailInfo = function(msg)
    return {
        failType = CHECK_CAN_BUY_FAIL_TYPE.POP_TEXT,
        msg = msg
    }
end

local createCheckCanBuyDuplicatePurchaseFailInfo = function(searchInfo)
    return {
        failType = CHECK_CAN_BUY_FAIL_TYPE.DUPLICATE_PURCHASE,
        searchInfo = searchInfo
    }
end

local isSettlement = false --是否结算成功

function Store:create()
    return Store:new()
end

function Store:ctor()
    self._mainCurrencyUnit = "money"
    self._currencyList = {}
    --@desc 藏衣阁物品
    self._cangYiGeItems = {}
    --刷新时间
    self._refreshTime = 0
end

function Store:setRole(role)
    self._role = role
    self._bagRole = clone(role)
    self._bagRole.userid = "bagStore"
end

function Store:setStore(npc)
    self._store = npc

    local RoleSoldBag = require("app.models.Store.StoreBag.RoleSoldBag")
    local roleSoldBag = RoleSoldBag:create(npc.roleSoldItems)

    self:setRoleSoldBag(roleSoldBag)
end

--[[
    @desc: 设置赎回背包
    author:tanqinjian
    time:2025-08-15 14:45:28
    --@bag: 
    @return:
]]
function Store:setRoleSoldBag(bag)
    self._roleSoldBag = bag
end

--[[
    @desc: 通过索引获取赎回背包道具数据
    author:tanqinjian
    time:2025-08-15 14:45:38
    --@index: 道具索引
    @return:
]]
function Store:getRoleSoldBagItem(index)
    return self._roleSoldBag:getItemBaseData(index)
end

--[[
    @desc: 获取赎回背包可售卖列表
    author:tanqinjian
    time:2025-08-15 14:47:19
    @return:
]]
function Store:getRoleSoldBagSellList()
    return self._roleSoldBag:getSellList()
end

--[[
    @desc: 获取赎回背包玩家已赎回列表
    author:tanqinjian
    time:2025-08-15 14:47:47
    @return:
]]
function Store:getRoleSoldBagSoldList()
    return self._roleSoldBag:getSoldList()
end

--[[
    @desc: 设置玩家背包
    author:tanqinjian
    time:2025-08-15 14:48:35
    --@bag: 
    @return:
]]
function Store:setLeftBag(bag)
    self._leftBag = bag
end

--[[
    @desc: 通过索引获取玩家背包道具数据
    author:tanqinjian
    time:2025-08-15 14:48:45
    --@index: 道具索引
    @return:
]]
function Store:getLeftBagItem(index)
    return self._leftBag:getItemBaseData(index)
end

--[[
    @desc: 获取玩家背包可出售列表
    author:tanqinjian
    time:2025-08-15 14:50:01
    @return:
]]
function Store:getLeftBagSellList()
    return self._leftBag:getSellList()
end

--[[
    @desc: 获取玩家背包已出售列表
    author:tanqinjian
    time:2025-08-15 14:50:25
    @return:
]]
function Store:getLeftBagSoldList()
    return self._leftBag:getSoldList()
end

--[[
    @desc: 通过索引获取商店背包道具数据
    author:tanqinjian
    time:2025-08-15 14:50:57
    --@index: 道具索引
    @return:
]]
function Store:getStoreBagItem(index)
    return self._storeBag:getItemBaseData(index)
end

--[[
    @desc: 获取商店可出售列表
    author:tanqinjian
    time:2025-08-15 14:51:23
    @return:
]]
function Store:getStoreBagSellList()
    return self._storeBag:getSellList()
end

--[[
    @desc: 获取商店已出售列表
    author:tanqinjian
    time:2025-08-15 14:51:43
    @return:
]]
function Store:getStoreBagSoldList()
    return self._storeBag:getSoldList()
end

function Store:setUI(ui)
    self._ui = ui
end

function Store:refresh()
    self._leftBag:refreshBag()
    self._roleSoldBag:refreshBag()
end

function Store:getLeftList()
    local list = {}

    local leftBagList = self:getLeftBagSellList()

    for i, v in ipairs(leftBagList) do
        local item = {}
        local itemClass = self:getLeftBagItem(v.index)
        item.index = v.index
        item.count = v.count
        item.name = itemClass:getUIName(v.count)
        item.type = GoodsType.BagType

        table.insert(list, item)
    end

    local roleRedeemList = self:getRoleSoldBagSoldList()

    for i, v in ipairs(roleRedeemList) do
        local item = {}
        local itemClass = self:getRoleSoldBagItem(v.index)
        item.index = v.index
        item.count = v.count
        item.name = itemClass:getUIName(v.count)
        item.type = GoodsType.RedeemType

        table.insert(list, item)
    end

    local rightSoldList = self:getStoreBagSoldList()

    for i, v in ipairs(rightSoldList) do
        local item = {}
        local itemClass = self:getStoreBagItem(v.index)
        item.index = v.index
        item.count = v.count
        item.name = itemClass:getUIName(itemClass:getUnitCount() * v.count)
        item.type = GoodsType.BuyType
        item.showBg = true

        table.insert(list, item)
    end

    return list
end

function Store:getRightList()
    local list = {}

    local roleSoldList = self:getRoleSoldBagSellList()

    for i, item in ipairs(roleSoldList) do
        local _item = {}
        _item.index = item.index
        _item.status = false
        _item.isDazhe = false
        _item.texture1 = "Image/BaseUI/btn-daisy.png"
        _item.type = GoodsType.RedeemType

        local itemClass = self:getRoleSoldBagItem(item.index)
        _item.name = itemClass:getName()
        _item.price = Helper:getDef(itemClass:getPrice(), 0) .. itemClass:getPriceName()
        _item.count = item.count

        table.insert(list, _item)
    end

    local leftBagSoldList = self:getLeftBagSoldList()

    for i, item in ipairs(leftBagSoldList) do
        local _item = {}
        _item.index = item.index
        _item.status = false
        _item.isDazhe = false
        _item.texture1 = "Image/BaseUI/btn-daisy.png"
        _item.type = GoodsType.SellType

        local itemClass = self:getLeftBagItem(item.index)
        _item.name = itemClass:getName()
        _item.price = Helper:getDef(itemClass:getPrice(), 0) .. itemClass:getPriceName()
        _item.count = item.count

        table.insert(list, _item)
    end

    local rightSellList = self:getStoreBagSellList()
    for i, item in ipairs(rightSellList) do
        local _item = {}
        _item.index = item.index
        _item.status = false
        _item.isDazhe = false
        _item.type = GoodsType.BuyType

        local itemClass = self:getStoreBagItem(item.index)
        if itemClass:getUnitCount() == 1 then
            _item.name = itemClass:getName()
        else
            _item.name = itemClass:getName() .. " X " .. itemClass:getUnitCount()
        end

        _item.price = Helper:getDef(itemClass:getPrice(), 0) .. itemClass:getPriceName()
        _item.count = item.count

        if itemClass:getDiscount() then
            _item.isDazhe = true
            _item.texture2 = switch(tostring(itemClass:getDiscount()), dis_img_path)
        end

        if self:getLimitTypeText(itemClass:getLimitType()) ~= "" then
            _item.limitTypeText = self:getLimitTypeText(itemClass:getLimitType()) .. "限购"
        end

        table.insert(list, _item)
    end

    return list
end

--[[
    @desc: 背包空间上限
    author:tanqinjian
    time:2025-09-20 18:02:11
    @return:
]]
function Store:getRoleItemLimit()
    return self._bagRole:getNumAttr("weight")
end

--[[
    @desc: 当前背包数量
    author:tanqinjian
    time:2025-09-20 18:02:22
    @return:
]]
function Store:getRoleItemNum()
    return self._bagRole:getNowWeight()
end

--[[
    @desc: 获取当前玩家拥有物品数量
    author:tanqinjian
    time:2025-08-14 19:55:24
    --@itemId: 物品为货币时传入值为货币id,本地道具时传入值为itemId
    @return:
]]
function Store:getRoleItemCount(itemId)
    if self:checkIsCurrency(itemId) then
        return Helper:mathFloor(self:getCurrencyNum(itemId))
    end

    local cangYiGeItemCount = 0

    local count = ItemHelper.getRoleOwnedTotalCountWithItemId(self._role, itemId)

    if self._cangYiGeItems[itemId] then
        cangYiGeItemCount = self._cangYiGeItems[itemId]
    end

    return count + cangYiGeItemCount
end

--[[
    @desc: 
    author:tanqinjian
    time:2025-09-20 17:58:09
    --@isRefresh:是否需要手动刷新
	--@func: 
    @return:
]]
function Store:initStore(isRefresh, func)
    local currencyVersion = self._role:getCurrencyVersion()
    local dataVer = self._role:getServerActionSystem():getDataVersion()

    HttpManagerEx:getMerchantStoreList(
        self._store.id,
        isRefresh,
        currencyVersion,
        dataVer,
        function(status, errcode, errmsg, data, isEncrypted)
            if isEncrypted == false then
                Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
                return
            end

            if status == 200 and errcode == 0 then
                if self._storeBag then
                    self._storeBag = nil
                end

                --@desc 商人出售物品列表
                self._storeBag = StoreSellBag:create(data.goodsList)

                self:__initCurrencyList(data.currencyList)

                self._currencyShowList = data.currencyShowList

                self._refreshTime = data.refreshTime
                --刷新所需货币数量
                self._refreshCost = data.refreshCost
                --刷新状态 0 不能刷新 1 可刷新 2不可刷新
                self._refreshState = data.refreshState
                --刷新所需货币名称
                self._refreshCurrencyName = data.refreshCurrencyName

                isSettlement = false

                if data.currencyVersion then
                    self._role:setCurrencyVersion(data.currencyVersion)
                end

                if func then
                    func()
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--[[
    @desc: 获取商品信息
    author:tanqinjian
    time:2025-09-20 18:02:44
    --@type:商品类型
	--@index: 商品唯一下标
    @return:
]]
function Store:getItem(type, index)
    if type == GoodsType.BagType or type == GoodsType.SellType then
        return self:getLeftBagItem(index)
    elseif type == GoodsType.RedeemType then
        return self:getRoleSoldBagItem(index)
    elseif type == GoodsType.BuyType then
        return self:getStoreBagItem(index)
    end
end

--[[
    @desc: 商品售卖
    author:tanqinjian
    time:2025-09-20 18:04:33
    --@goods:{
        count = 1,
        index = 1, 
        type = 1,
    }
	--@func: 
    @return:
]]
function Store:sellGoods(goods, func)
    if goods.type == GoodsType.RedeemType then
        self._roleSoldBag:sell(goods.index, goods.count)
    elseif goods.type == GoodsType.BagType or goods.type == GoodsType.SellType then
        self._leftBag:sell(goods.index, goods.count)
    elseif goods.type == GoodsType.BuyType then
        self._storeBag:sell(goods.index, goods.count)
    end

    self:__bagRoleAddGoods(2, goods)

    local itemClass = self:getItem(goods.type, goods.index)

    if goods.type == GoodsType.BuyType then
        PopText("您退还了" .. itemClass:getName() .. "X" .. (itemClass:getUnitCount() * goods.count) .. "收回了" .. tostring(itemClass:getPrice() * goods.count) .. itemClass:getPriceName())
        self:__updateCurrency(itemClass:getPriceUnit(), itemClass:getPrice() * goods.count)
    end

    if goods.type == GoodsType.BagType or goods.type == GoodsType.RedeemType then
        PopText("您出售了" .. itemClass:getName() .. "X" .. (itemClass:getUnitCount() * goods.count) .. "收回了" .. tostring(itemClass:getPrice() * goods.count) .. itemClass:getPriceName())
        self:__updateCurrency(itemClass:getPriceUnit(), itemClass:getPrice() * goods.count)
    end

    if func then
        func()
    end
end

--[[
    @desc: 商品购买
    author:tanqinjian
    time:2025-09-20 18:05:19
    --@goods:{
        count = 1,
        index = 1, 
        type = 1,
    }
	--@func: 
    @return:
]]
function Store:buyGoods(goods, func)
    if self:checkNeedRefresh() then
        self:refresh()
        self:initStore(0)
        self._ui:refreshUI()
        PopText("该商品已更新，无法购买")
        return
    end

    local itemClass = self:getItem(goods.type, goods.index)

    local buyCount = goods.count

    local isCanBuy, failInfo = self:__checkCanBuyGoods({index = goods.index, type = goods.type, count = buyCount})
    if isCanBuy == false then
        if failInfo ~= nil and failInfo.failType == CHECK_CAN_BUY_FAIL_TYPE.DUPLICATE_PURCHASE then
            GoodsHelper:handleDuplicatePurchaseSearchInfo(
                failInfo.searchInfo,
                {
                    flowType = GoodsHelper.DUPLICATE_PURCHASE_FLOW_TYPE.BLOCK
                }
            )
        else
            PopText(failInfo and failInfo.msg)
        end

        return
    end

    if goods.type == GoodsType.RedeemType then
        self._roleSoldBag:buy(goods.index, buyCount)
    elseif goods.type == GoodsType.BagType or goods.type == GoodsType.SellType then
        self._leftBag:buy(goods.index, buyCount)
    elseif goods.type == GoodsType.BuyType then
        self._storeBag:buy(goods.index, buyCount)
    end

    self:__bagRoleAddGoods(1, goods)

    if goods.type == GoodsType.SellType or goods.type == GoodsType.RedeemType then
        PopText("你赎回" .. tostring(buyCount) .. tostring(itemClass:getName()) .. "花费了" .. tostring(math.abs(buyCount * itemClass:getPrice())) .. itemClass:getPriceName())
    else
        PopText("你购买" .. itemClass:getName() .. "X" .. (itemClass:getUnitCount() * buyCount) .. "花费了" .. tostring(math.abs(buyCount * itemClass:getPrice())) .. itemClass:getPriceName())
    end

    self:__updateCurrency(itemClass:getPriceUnit(), -itemClass:getPrice() * buyCount)

    if func then
        func()
    end

    return true
end

--[[
    @desc: 背包角色道具变化（用于判断背包）
    author:tanqinjian
    time:2025-06-18 17:57:02
    --@addType:1 加 2 减
	--@goods: 
    @return:
]]
function Store:__bagRoleAddGoods(addType, goods)
    local itemClass = self:getItem(goods.type, goods.index)

    if goods.type == GoodsType.BagType or goods.type == GoodsType.RedeemType or goods.type == GoodsType.SellType then
        local count = goods.count

        if addType == 2 then
            count = -count
        end

        if itemClass:isCurrency() == true then
            self:__updateCurrency(itemClass:getId(), count)
        else
            self._bagRole:addItemCount(itemClass:getItemId(), count)
        end
    elseif goods.type == GoodsType.BuyType then
        local count = goods.count * itemClass:getUnitCount()

        if addType == 2 then
            count = -count
        end

        if itemClass:getLimitBoughtCount() then
            itemClass:setLimitBoughtCount(itemClass:getLimitBoughtCount() + count / itemClass:getUnitCount())
        end

        local items = {
            {
                id = itemClass:getId(),
                num = count
            }
        }

        local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

        GoodsHelper:fromNetworkGrantGoods(self._bagRole, GrantGoodRequest:create({goodsList = items}))

        if itemClass:getItemId() == "money" or itemClass:getItemId() == "gold" then
            self:__updateCurrency(itemClass:getItemId(), count)
        end

        local goodsClass = GoodsHelper:getGoodsResClass(itemClass:getId())
        if goodsClass:getItype() == GOODS_TYPE.VERSION_CURRENCY then
            local currencyInfo = self._currencyList[goodsClass:getItemId()]
            if currencyInfo then
                self:__updateCurrency(itemClass:getItemId(), count)
                if currencyInfo.cycleLimit then
                    currencyInfo.cycleNum = currencyInfo.cycleNum + count
                end
            end
        end
    end
end

--[[
    @desc: 角色已售卖的商品
    author:tanqinjian
    time:2025-09-20 18:05:52
    @return:
]]
function Store:getRoleSoldItems()
    local leftSoldList = self._leftBag:getSoldList()
    if MapIsEmpty(leftSoldList) then
        return {}
    end

    local list = {}

    for i, v in ipairs(leftSoldList) do
        local info = {}
        local itemClass = self:getItem(GoodsType.BagType, v.index)
        info.name = itemClass:getName() .. " X " .. v.count

        table.insert(list, info)
    end

    return list
end

--[[
    @desc: 角色已购买的商品
    author:tanqinjian
    time:2025-09-20 18:06:27
    @return:
]]
function Store:getRoleBoughtItems()
    local roleBoughtItems = {}

    local rightSoldList = self._storeBag:getSoldList()

    local roleRedeemItems = self._roleSoldBag:getSoldList()

    for i, v in ipairs(roleRedeemItems) do
        local itemClass = self:getItem(GoodsType.RedeemType, v.index)

        if not roleBoughtItems[itemClass:getItemId()] then
            roleBoughtItems[itemClass:getItemId()] = {count = 0}
        end

        if not roleBoughtItems[itemClass:getItemId()].name then
            roleBoughtItems[itemClass:getItemId()].name = itemClass:getName()
        end

        roleBoughtItems[itemClass:getItemId()].count = roleBoughtItems[itemClass:getItemId()].count + v.count
    end

    for i, v in ipairs(rightSoldList) do
        local itemClass = self:getItem(GoodsType.BuyType, v.index)

        if not roleBoughtItems[itemClass:getItemId()] then
            roleBoughtItems[itemClass:getItemId()] = {count = 0}
        end

        if not roleBoughtItems[itemClass:getItemId()].name then
            roleBoughtItems[itemClass:getItemId()].name = itemClass:getName()
        end

        roleBoughtItems[itemClass:getItemId()].count = roleBoughtItems[itemClass:getItemId()].count + v.count * itemClass:getUnitCount()
    end

    local list = {}

    for itemId, itemInfo in pairs(roleBoughtItems) do
        local info = {}

        info.name = itemInfo.name .. " X " .. itemInfo.count

        table.insert(list, info)
    end

    return list
end

--[[
    @desc: 角色售卖商品价值文本
    author:tanqinjian
    time:2025-09-20 18:06:37
    @return:
]]
function Store:getRoleSoldItemsPriceText()
    local leftSoldList = self._leftBag:getSoldList()
    if MapIsEmpty(leftSoldList) then
        return "0碎银"
    end

    local total = 0
    for i, v in ipairs(leftSoldList) do
        local itemClass = self:getItem(GoodsType.BagType, v.index)
        total = total + Helper:getDef(itemClass:getPrice(), 0) * v.count
    end

    return total .. "碎银"
end

--[[
    @desc: 角色购买商品的价值文本
    author:tanqinjian
    time:2025-09-20 18:07:08
    @return:
]]
function Store:getRoleBoughtItemPriceText()
    local rightSoldList = self._storeBag:getSoldList()

    local roleRedeemItems = self._roleSoldBag:getSoldList()

    if MapIsEmpty(rightSoldList) and MapIsEmpty(roleRedeemItems) then
        return "0碎银"
    end

    local priceTotal = {}
    local priceUnitCount = 0

    for i, v in ipairs(roleRedeemItems) do
        local itemClass = self:getItem(GoodsType.RedeemType, v.index)
        if not priceTotal[itemClass:getPriceUnit()] then
            priceTotal[itemClass:getPriceUnit()] = 0
            priceUnitCount = priceUnitCount + 1
        end

        priceTotal[itemClass:getPriceUnit()] = priceTotal[itemClass:getPriceUnit()] + itemClass:getPrice() * v.count
    end

    for i, v in ipairs(rightSoldList) do
        local itemClass = self:getItem(GoodsType.BuyType, v.index)
        if not priceTotal[itemClass:getPriceUnit()] then
            priceTotal[itemClass:getPriceUnit()] = 0
            priceUnitCount = priceUnitCount + 1
        end

        priceTotal[itemClass:getPriceUnit()] = priceTotal[itemClass:getPriceUnit()] + itemClass:getPrice() * v.count
    end

    local str = ""
    for priceUnit, price in pairs(priceTotal) do
        str = str .. price .. self:getCurrencyName(priceUnit)
        priceUnitCount = priceUnitCount - 1
        if priceUnitCount > 0 then
            str = str .. "、"
        end
    end

    return str
end

--[[
    @desc: 结算
    author:tanqinjian
    time:2025-09-20 18:09:08
    --@func: 
    @return:
]]
function Store:settlement(func)
    if isSettlement == true then
        return
    end

    if self:checkNeedRefresh() then
        self:refresh()
        self:initStore(0)
        self._ui:refreshUI()
        PopText("商品已更新，无法结算")
        return
    end

    local goodsList = {}

    local rightSoldList = self._storeBag:getSoldList()

    for i, v in ipairs(rightSoldList) do
        local itemClass = self:getItem(GoodsType.BuyType, v.index)
        table.insert(goodsList, {count = v.count, storeId = itemClass:getStoreId()})
    end

    local sellGoodsList = {}
    local redeemGoodsList = {}
    local totalMoney = 0

    --玩家赎回上次售卖的商品
    local roleRedeemItems = self._roleSoldBag:getSoldList()

    for i, v in ipairs(roleRedeemItems) do
        local itemClass = self:getItem(GoodsType.RedeemType, v.index)

        totalMoney = totalMoney - Helper:getDef(itemClass:getPrice(), 0) * v.count

        table.insert(redeemGoodsList, {itemId = itemClass:getItemId(), count = v.count})
    end

    --玩家当前售卖商品
    local leftSoldList = self._leftBag:getSoldList()

    for i, v in ipairs(leftSoldList) do
        local itemClass = self:getItem(GoodsType.BagType, v.index)

        totalMoney = totalMoney + Helper:getDef(itemClass:getPrice(), 0) * v.count

        table.insert(sellGoodsList, {itemId = itemClass:getItemId(), count = v.count})
    end

    local recordList = {}

    if MapIsEmpty(sellGoodsList) == false or MapIsEmpty(redeemGoodsList) == false then
        recordList = {sellGoodsList = sellGoodsList, redeemGoodsList = redeemGoodsList, getMoney = totalMoney}
    end

    local currencyVersion = self._role:getCurrencyVersion()
    local dataVer = self._role:getServerActionSystem():getDataVersion()
    HttpManagerEx:buyMerchantGoods(
        self._store.id,
        goodsList,
        recordList,
        currencyVersion,
        dataVer,
        function(status, errcode, errmsg, data, isEncrypted)
            if status == 200 then
                if errcode == 0 then
                    if isSettlement == false then
                        self:__settlementLocal()
                        self:__saveRoleSell()
                        self:__settlementWeb(data.goodsList, data.dataVer, data.yashi_expired_time)
                        isSettlement = true

                        if data.currencyVersion then
                            self._role:setCurrencyVersion(data.currencyVersion)
                        end
                    end
                elseif errcode == 1 then --数据非法
                    PopText("请合法游戏")
                    isSettlement = true
                elseif errcode == 2 then --售卖列表刷新
                    PopText("商品列表已更新，请重新选择你要购买的商品")
                    self:refresh()
                    self:initStore(0)
                    self._ui:refreshUI()
                else
                    PopText(errmsg)
                end

                if isSettlement then
                    if func then
                        func()
                    end
                end
            else
                PopText(errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--[[
    @desc: 结算购买的商品
    author:tanqinjian
    time:2025-06-19 22:01:37
    --@goodsList: {{id = "商品id", num = "数量"}}
    --@dataVer:
    @return:
]]
function Store:__settlementWeb(goodsList, dataVer, yashiExpiredTime)
    local GrantGoodRequest = require("app.models.Store.GrantGoodRequest")

    GoodsHelper:fromNetworkGrantGoods(self._role, GrantGoodRequest:create({goodsList = goodsList, dataVersion = dataVer, yashiExpiredTime = yashiExpiredTime}))
end

--[[
    @desc: 结算本地
    author:tanqinjian
    time:2025-06-19 21:18:27
    @return:
]]
function Store:__settlementLocal()
    local total = 0
    --玩家赎回上次售卖的商品
    local roleRedeemItems = self._roleSoldBag:getSoldList()
    for i, v in ipairs(roleRedeemItems) do
        local itemClass = self:getItem(GoodsType.RedeemType, v.index)
        total = total - Helper:getDef(itemClass:getPrice(), 0) * v.count

        self._role:addItemCount(itemClass:getItemId(), v.count, nil, nil, "商人赎回")
    end

    --玩家当前售卖商品
    local leftSoldList = self._leftBag:getSoldList()
    for i, v in ipairs(leftSoldList) do
        local itemClass = self:getItem(GoodsType.BagType, v.index)
        total = total + Helper:getDef(itemClass:getPrice(), 0) * v.count

        self._role:addItemCount(itemClass:getItemId(), -v.count, nil, nil, "商人售卖")
    end

    self._role:addAttr("money", total)
end

--[[
    @desc: 记录玩家售卖数据
    author:tanqinjian
    time:2025-06-19 21:16:59
    @return:
]]
function Store:__saveRoleSell()
    self._store.roleSoldItems = {}

    --玩家上一次已售卖的商品
    local roleSoldItems = self._roleSoldBag:getSellList()
    for i, v in ipairs(roleSoldItems) do
        local itemClass = self:getItem(GoodsType.RedeemType, v.index)
        table.insert(self._store.roleSoldItems, {id = self._role:getItemOnlyId(), itemId = itemClass:getItemId(), count = v.count})
    end

    --玩家当前售卖商品
    local leftSoldList = self._leftBag:getSoldList()
    for i, v in ipairs(leftSoldList) do
        local itemClass = self:getItem(GoodsType.BagType, v.index)
        table.insert(self._store.roleSoldItems, {id = self._role:getItemOnlyId(), itemId = itemClass:getItemId(), count = v.count})
    end
end

function Store:checkCanSellGoods(goods)
    local can_sell, msg = true, ""

    if goods.type ~= GoodsType.BuyType then --非购买商品
        if self._store.roleCanSellItem ~= 1 then
            can_sell = false
            msg = "该商店不可出售"
            return can_sell, msg
        end

        local itemClass = self:getItem(goods.type, goods.index)

        if itemClass:getCanSell() then
            return true, goods.count
        else
            return false, itemClass:getSellMsg()
        end
    else
        return true, goods.count
    end
end

function Store:__checkCanBuyGoods(goods)
    if MapIsEmpty(goods) then
        return false, createCheckCanBuyPopTextFailInfo()
    end

    local itemClass = self:getItem(goods.type, goods.index)

    local currencyNum = self:getCurrencyNum(itemClass:getPriceUnit())

    if currencyNum < itemClass:getPrice() * goods.count then
        local currencyName = self:getCurrencyName(itemClass:getPriceUnit())
        return false, createCheckCanBuyPopTextFailInfo(currencyName .. "不足")
    end

    if goods.type == GoodsType.BuyType then
        if itemClass:getLimitBoughtCount() then
            if goods.count + itemClass:getLimitBoughtCount() > itemClass:getLimitCount() then
                local text = "此商品已达到限购条件，%s内无法再次购买"
                text = string.format(text, self:getLimitTypeText(itemClass:getLimitType()))
                return false, createCheckCanBuyPopTextFailInfo(text)
            end
        end

        local result, searchInfo = GoodsHelper:checkDuplicatePurchase(self._role, itemClass:getId())
        if result == true then
            return false, createCheckCanBuyDuplicatePurchaseFailInfo(searchInfo)
        end

        local goodsClass = GoodsHelper:getGoodsResClass(itemClass:getId())

        local finalCount = itemClass:getUnitCount() * goods.count

        local items = {
            {
                id = itemClass:getId(),
                num = finalCount
            }
        }

        if goodsClass:getItype() == GOODS_TYPE.VERSION_CURRENCY then
            local currencyInfo = self._currencyList[goodsClass:getItemId()]
            if MapIsEmpty(currencyInfo) == false then
                if currencyInfo.cycleNum and currencyInfo.cycleLimit then
                    if currencyInfo.cycleNum + finalCount > currencyInfo.cycleLimit then
                        return false, createCheckCanBuyPopTextFailInfo(string.format("%s已超出%s可获取的上限，无法购买", goodsClass:getName(), CurrencyUtil:getLimitTypeText(goodsClass:getItemId())))
                    end
                end

                if currencyInfo.num and currencyInfo.limit then
                    if currencyInfo.num + finalCount > currencyInfo.limit then
                        return false, createCheckCanBuyPopTextFailInfo(string.format("%s已超出上限，无法购买", goodsClass:getName()))
                    end
                end
            end
        end

        local isTrue = GoodsHelper:checkRoleBagGoods(self._bagRole, items)
        if isTrue then
            return true
        end
    else
        if itemClass:isCurrency() == true then
            return true
        end

        local isTrue = self._bagRole:checkCanBuyThings(itemClass:getItemId(), goods.count, nil, false)
        if isTrue then
            return true
        end
    end

    return false, createCheckCanBuyPopTextFailInfo("背包容量已达上限，无法购买。")
end

function Store:__initCurrencyList(list)
    -- 服务器下发list：data.currencyList :
    -- 1、商品列表中，商品的出售货币合集
    -- 2、商品本身作为货币管理表中的货币时（即商品表类型为10）
    -- 3、商人展示的货币（商人表中配置的displaycurrency）
    -- 4、加上本地角色的碎银、黄金

    self._currencyList = {
        ["money"] = {
            name = "碎银",
            num = self._role:getAttr("money")
        },
        ["gold"] = {
            name = "黄金",
            num = self._role:getAttr("gold")
        }
    }

    if MapIsEmpty(list) == false then
        for k, v in pairs(list) do
            if not self._currencyList[v.unit] then
                self._currencyList[v.unit] = {
                    name = v.name,
                    num = v.num,
                    limit = v.limit,
                    cycleLimit = v.cycleLimit,
                    cycleNum = v.cycleNum
                }
            end
        end
    end
end

function Store:checkIsCurrency(currencyUnit)
    if self._currencyList[currencyUnit] then
        return true
    end

    return false
end

function Store:getCurrencyNum(currencyUnit)
    if self._currencyList[currencyUnit] then
        return self._currencyList[currencyUnit].num
    end
end

function Store:getCurrencyName(currencyUnit)
    if self._currencyList[currencyUnit] then
        return self._currencyList[currencyUnit].name
    end
end

function Store:__updateCurrency(currencyUnit, num)
    if self._currencyList[currencyUnit] then
        self._currencyList[currencyUnit].num = self._currencyList[currencyUnit].num + num
    end
end

function Store:checkGoodsTypeIsBuyType(goodsType)
    return GoodsType.BuyType == goodsType
end

function Store:checkGoodsTypeIsSellType(goodsType)
    return GoodsType.SellType == goodsType
end

function Store:checkNeedRefresh()
    if self._refreshTime and self._refreshTime > 0 then
        if GetTime() > self._refreshTime then
            return true
        end
    end

    return false
end

function Store:getCurrencyShowList()
    return self._currencyShowList
end

function Store:getLimitTypeText(limitType)
    local text = {
        [1] = "",
        [2] = "本日",
        [3] = "本周",
        [4] = "本月"
    }

    if text[limitType] then
        return text[limitType]
    end

    return ""
end

--[[
    @desc: 刷新所需数量
    author:tanqinjian
    time:2025-08-21 17:03:52
    @return:
]]
function Store:getRefreshCost()
    return self._refreshCost
end

--[[
    @desc: 刷新所需货币名称
    author:tanqinjian
    time:2025-08-21 17:04:13
    @return:
]]
function Store:getRefreshCostCurrencyName()
    return self._refreshCurrencyName
end

--[[
    @desc: 0 不能刷新 1 可刷新 2次数不足 3 货币不足 4商品售罄
    author:tanqinjian
    time:2025-08-20 17:44:48
    @return:
]]
function Store:getRefreshState()
    return self._refreshState
end

function Store:getRefreshStateText()
    if self._refreshState == 2 then
        return "本次刷新次数已耗尽，无法刷新"
    elseif self._refreshState == 3 then
        return self._refreshCurrencyName .. "不足支付本次刷新所需数量，无法刷新"
    elseif self._refreshState == 4 then
        return "已无剩余商品可售卖，无法刷新"
    end
end

return class("Store", {}, Store)
00000000000