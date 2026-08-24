local class = require("third.class.NewClass")

local BlackStore = {}

local dis_img_path = {
    ["0.9"] = "Image/UI/StoreUI/jiuzhe.png",
    ["0.8"] = "Image/UI/StoreUI/bazhe.png",
    ["0.6"] = "Image/UI/StoreUI/liuzhe.png",
    default = "Image/UI/StoreUI/jiuzhe.png"
}

local GoodsType = {
    SellType = 1, --自己售卖的商品
    BuyType = 2   --商店购买的商品
}

local StoreBehavior = {
    Sell = 1,
    Buy = 2
}

local isSettlement = false  --是否结算成功

function BlackStore:create()
    return BlackStore:new()
end

function BlackStore:ctor()
    --@desc 玩家售卖列表
    self._leftItems = {}
    --@desc 玩家已卖出的物品，等于商人赎回的物品
    self._leftSoldList = {}
    --@desc 商人售卖列表
    self._rightSellList = {}
    --@desc 商人已卖出的物品，等于玩家已购买的物品
    self._rightSoldList = {}
    --@desc 商品信息表
    self._goodsInfoList = {}
    self._mainCurrencyUnit = "money"
    self._currencyList = {}
    --@desc 悬兵洞物品
    self._xuanBingDongItems = {}
    --@desc 藏衣阁物品
    self._cangYiGeItems = {}
    self._behavior = 0
end

function BlackStore:setRole(role)
    self._role = role
end

function BlackStore:setUI(ui)
    self._ui = ui
end

function BlackStore:getLeftList()
    local list = {}

    for i, v in ipairs(self._leftItems) do
        local item = {}
        item.id = v.id
        item.itemId = v.itemId
        item.count = v.count

        local itemAttr = self._role:getOneItemByKey(v.itemId)
        if itemAttr.wpType == "神兵" then
            item.name = itemAttr.name
        else
            item.name = itemAttr.name .. " X " .. v.count
        end

        table.insert(list, item)
    end

    return list
end

function BlackStore:getRightList()
    local list = {}

    for i, item in ipairs(self._leftSoldList) do
        local _item = {}
        _item.id = item.id
        _item.itemId = item.itemId
        _item.count = item.count
        _item.status = false
        _item.isDazhe = false
        _item.texture1 = "Image/BaseUI/btn-daisy.png"
        _item.type = GoodsType.SellType

        local itemAttr = self._role:getOneItemByKey(item.itemId)
        _item.name = itemAttr.name
        _item.price = Helper:getDef(itemAttr.salePrice, 0) .. "碎银"

        table.insert(list,_item)
    end

    for i, item in ipairs(self._rightSellList) do
        local _item = {}
        _item.id = item.id
        _item.itemId = item.itemId
        _item.count = item.count
        _item.status = false
        _item.isDazhe = false
        _item.type = GoodsType.BuyType

        local goodsInfo = self:__getGoodsInfo(item.itemId)
        if goodsInfo then
            _item.name = goodsInfo.name
            _item.price = goodsInfo.price .. self:getCurrencyName(goodsInfo.priceUnit)
    
            if goodsInfo.discount then
                _item.isDazhe = true
                _item.texture2 = switch(tostring(goodsInfo.discount), dis_img_path)
            end
        end
       
        table.insert(list,_item)
    end

    return list
end

function BlackStore:getMainCurrencyNum()
    if self._currencyList[self._mainCurrencyUnit] then
        return self._currencyList[self._mainCurrencyUnit].num
    end
end

function BlackStore:getMainCurrencyName()
    if self._currencyList[self._mainCurrencyUnit] then
        return self._currencyList[self._mainCurrencyUnit].name
    end
end

function BlackStore:getRoleItemLimit()
    return self._role:getNumAttr("weight")
end

function BlackStore:getRoleItemNum()
    return #self._leftItems
end

function BlackStore:getRoleItemCount(itemId)
    local roleItemCount = 0
    local leftItemCount = 0
    local xuanBingDongItemCount = 0
    local cangYiGeItemCount = 0

	local boxList = {
		"ckitems", --仓库
		"decorative", --装饰箱
		"medicinalBox", --药囊
		"literaryBox", --书匣
		"shuxiang",	--武功书箱
		"zhaoShuXiang", --招式书箱
		"cwItems", --家园储物柜
		"smeltBox",--冶炼箱
	}

	for i = 1,#boxList do
		local boxName = boxList[i]
		local itemsList = self._role:getAttr(boxName)
		if not MapIsEmpty(itemsList) then
			for k,v in pairs(itemsList) do
				if v.itemId == itemId then
					roleItemCount = roleItemCount + v.count
				end
			end
		end
	end

    for i, v in ipairs(self._leftItems) do
        if v.itemId == itemId then
            leftItemCount = leftItemCount + v.count
        end
    end

    if self._xuanBingDongItems[itemId] then
        xuanBingDongItemCount = self._xuanBingDongItems[itemId]
    end

    if self._cangYiGeItems[itemId] then
        cangYiGeItemCount = self._cangYiGeItems[itemId]
    end

    return roleItemCount + leftItemCount + xuanBingDongItemCount + cangYiGeItemCount
end

function BlackStore:initStore(func)

    HttpManagerEx:getMarketStoreList(
        function(status, errcode, errmsg, data, isEncrypted)
            if isEncrypted == false then
                Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
                return
            end

            if status == 200 and errcode == 0 then
                if data.status == "OPEN" and data.list then
                    local items = data.list

                    self:__initXuanBingDongItems()

                    self:__initCangYiGeItems()

                    self:__initLeftList(self._role:getItems())
            
                    self:__initRightList(data.list)
                    
                    self:__initCurrencyList(data.currencyList)

                    self:__initGoodsPrice()

                    isSettlement = false

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
    goods = {
        id = "",
        itemId = "",
        count = 10
    }
]]

function BlackStore:sellGoods(goods, func)
    self._behavior = StoreBehavior.Sell

    local sellGoods = {
        id = goods.id,
        itemId = goods.itemId,
        count = goods.count,
    }

    self:__refreshLeftSoldList(sellGoods)
    self:__refreshLeftSellList(sellGoods)
    
    local restoreCount = self:__refreshRightSoldList(sellGoods)
    local isRestore = restoreCount > 0
    self:__refreshRightSellList(sellGoods, isRestore)

    local itemAttr = self._role:getOneItemByKey(goods.itemId)
    if isRestore then
        local RestorePrice,restorePriceUnit = self:getGoodsPriceAndPriceUnit(goods.itemId)
        PopText("您退还了".. tostring(restoreCount) .. itemAttr.unit .. itemAttr.name .. "收回了" .. tostring(RestorePrice * restoreCount) .. self:getCurrencyName(restorePriceUnit))
        self:__updateCurrency(restorePriceUnit, RestorePrice * restoreCount)
    end

    local sellCount = goods.count - restoreCount
    if sellCount > 0 then
        local salePrice = Helper:getDef(itemAttr.salePrice, 0)
        local salePriceUnit = "money"
        PopText("您出售了"..tostring(sellCount) .. tostring(itemAttr.unit) .. tostring(itemAttr.name) .. "获得了" .. tostring(sellCount * salePrice) .. self:getCurrencyName(salePriceUnit))
        self:__updateCurrency(salePriceUnit, sellCount * salePrice)
    end
    
    if func then
        func()
    end
end

function BlackStore:buyGoods(goods, func)
    local itemAttr = self._role:getOneItemByKey(goods.itemId)
    local buyPrice,buyPriceUnit
    local buyCount = goods.count

    if goods.type == GoodsType.SellType then
        buyPrice = Helper:getDef(tonumber(itemAttr.salePrice), 0)
        buyPriceUnit = "money"
    elseif goods.type == GoodsType.BuyType then
        buyPrice,buyPriceUnit = self:getGoodsPriceAndPriceUnit(goods.itemId)
    end

    local isCanBuy, msg = self:__checkCanBuyGoods({itemId = goods.itemId, count = buyCount, price = buyPrice * buyCount, priceUnit = buyPriceUnit})
    if isCanBuy == false then
        PopText(msg)
        return
    end

    self._behavior = StoreBehavior.Buy

    local sellGoods = {
        id = goods.id,
        itemId = goods.itemId,
        count = buyCount,
        type = goods.type
    }

    self:__refreshLeftSellList(sellGoods)
    local redeemCount = self:__refreshLeftSoldList(sellGoods)
    assert(redeemCount, "BlackStore:buyGoods self._behavior is error")
    local isRedeem = redeemCount > 0

    self:__refreshRightSoldList(sellGoods)
    self:__refreshRightSellList(sellGoods)

    if isRedeem then
        PopText("你赎回" ..tostring(redeemCount) .. tostring(itemAttr.unit) .. tostring(itemAttr.name) .. "花费了" .. tostring(math.abs(redeemCount * buyPrice)) .. self:getCurrencyName(buyPriceUnit))
    else
        PopText("你购买" ..tostring(buyCount) .. tostring(itemAttr.unit) .. tostring(itemAttr.name) .. "花费了" .. tostring(math.abs(buyCount * buyPrice)) .. self:getCurrencyName(buyPriceUnit))
    end

    self:__updateCurrency(buyPriceUnit, -buyPrice * buyCount)

    if func then
        func()
    end
end

function BlackStore:getRoleSoldItems()
    if MapIsEmpty(self._leftSoldList) then
        return {}
    end

    local list = {}
    for i, v in ipairs(self._leftSoldList) do
        local itemAttr = self._role:getOneItemByKey(v.itemId)

        local info = {}
        info.name = itemAttr.name .. " X " .. v.count

        table.insert(list, info)
    end

    return list
end

function BlackStore:getRoleBoughtItems()
    if MapIsEmpty(self._rightSoldList) then
        return {}
    end

    local list = {}
    for i, v in ipairs(self._rightSoldList) do
        local itemAttr = self._role:getOneItemByKey(v.itemId)

        local info = {}
        info.name = itemAttr.name .. " X " .. v.count

        table.insert(list, info)
    end

    return list
end

function BlackStore:getRoleSoldItemsPriceText()
    if MapIsEmpty(self._leftSoldList) then
        return "0碎银"
    end

    local total = 0
    for i, v in ipairs(self._leftSoldList) do
        local itemAttr = self._role:getOneItemByKey(v.itemId)
        total = total + Helper:getDef(itemAttr.salePrice, 0) * v.count
    end

    return total .. "碎银"
end

function BlackStore:getRoleBoughtItemPriceText()
    if MapIsEmpty(self._rightSoldList) then
        return "0碎银"
    end

    local priceTotal = {}
    local priceUnitCount = 0

    for i, v in ipairs(self._rightSoldList) do
        local price, priceUnit = self:getGoodsPriceAndPriceUnit(v.itemId)
        if not priceTotal[priceUnit] then
            priceTotal[priceUnit] = 0
            priceUnitCount = priceUnitCount + 1
        end

        priceTotal[priceUnit] = priceTotal[priceUnit] + price * v.count
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

function BlackStore:settlement(func)
    if isSettlement == true then
        return
    end

    local goodsList = {}

    print("----------------_leftSoldList----------------------")
    Helper:print_lua_table(self._leftSoldList)
    
    if MapIsEmpty(self._rightSoldList) then
        for i, v in ipairs(self._leftSoldList) do
            self._role:addItemCount(v.itemId, -v.count, nil, nil, "黑市商人售卖")
        end

        self._role:setAttr("money", self:__getCurrencyNum("money"))

        isSettlement = true

        if func then
            func()
        end

        return
    end

    for i, v in ipairs(self._rightSoldList) do
        local goods = {
            itemId = v.itemId,
            number = v.count
        }

        local price, priceUnit = self:getGoodsPriceAndPriceUnit(v.itemId)
        goods.price = price
        goods.priceUnit = priceUnit

        table.insert(goodsList, goods)
    end

    local isDiscount = self._role:isHaveImprintingId("fuhuiyin")
    local isFreeSingle = self._role:isHaveImprintingId("fulingyin")
    local mark = {isDiscount = isDiscount, isFreeSingle = isFreeSingle}

    TransCheck:getTransIdFromWeb(function(transId)
        Helper:print_lua_table(goodsList)
        HttpManagerEx:buyBlackGoods(goodsList, transId, mark,
            function(status, errcode, errmsg, data, isEncrypted)
                if status == 200 then
                    if errcode == 0 then
                        if isSettlement == false then
                            for i, v in ipairs(self._leftSoldList) do
                                self._role:addItemCount(v.itemId, -v.count, nil, nil, "黑市商人售卖")
                            end

                            local list = data.goodsList
                            local isFree = false
                            local freeItems = {}
                            local freeItemsCount = 0
                            if MapIsEmpty(list) == false then
                                for k, v in pairs(list) do
                                    if v.priceUnit == "yuanbao" and v.price == 0 then
                                        isFree = true
                                        freeItemsCount = freeItemsCount + 1
                                        if not freeItems[v.itemId] then
                                            freeItems[v.itemId] = 0
                                        end
                                        freeItems[v.itemId] = freeItems[v.itemId] + v.number
                                    end

                                    self._role:addItemCount(v.itemId, v.number, nil, nil, "黑市商人购买")
                                end
                            end

                            if isFree == true then
                                local str = "鸿运当头，本次交易免费获得"
                                for itemId, number in pairs(freeItems) do
                                    local itemAttr = self._role:getOneItemByKey(itemId)
                                    str = str.. itemAttr.name .. "X" .. number
                                    freeItemsCount = freeItemsCount - 1
                                    if freeItemsCount > 0 then
                                        str = str .. "、"
                                    end
                                end

                                PopText(str)
                            end

                            self._role:setAttr("money", self:__getCurrencyNum("money"))

                            isSettlement = true
                        end
                    elseif errcode == 1 then --数据非法
                        PopText("请合法游戏")
                        isSettlement = true
                    elseif errcode == 2 then --售卖列表刷新
                        PopText("商品列表已更新，请重新选择你要购买的商品")
                        self:initStore()
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
	end)
end

function BlackStore:__initXuanBingDongItems()
    self._xuanBingDongItems = {}

    HttpManagerEx:getCkItemsList(
        "xuanbingdong",
        self._role.sCk_ver["xuanbingdong"],
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self._role.sCk_ver["xuanbingdong"] = data.ver
                if MapIsEmpty(data.list) == false then
                    for k, v in pairs(data.list) do
                        self._xuanBingDongItems[v.itemId] = 1
                    end
                end
            end
        end,
    IS_SHOW_WAITING)
end

function BlackStore:__initCangYiGeItems()
    self._cangYiGeItems = {}

    HttpManagerEx:getCkItemsList(
        "cangyige",
        self._role.sCk_ver["cangyige"],
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self._role.sCk_ver["cangyige"] = data.ver
                if MapIsEmpty(data.list) == false then
                    for k, v in pairs(data.list) do
                        self._cangYiGeItems[v.itemId] = 1
                    end
                end
            end
        end,
    IS_SHOW_WAITING)
end

function BlackStore:__initLeftList(list)
    self._leftItems = {}
    self._leftSoldList = {}

    if MapIsEmpty(list) == false then
        for i, item in ipairs(list) do
            local left_item = {
                id = item.id,
                itemId = item.itemId,
                count = item.count,
            }

            table.insert(self._leftItems, left_item)
        end
    end
end

function BlackStore:__initRightList(list)
    self._rightSellList = {}
    self._goodsInfoList = {}
    self._rightSoldList = {}

    if MapIsEmpty(list) == false then
        for k, v in pairs(list) do
            local goods = {
                id = self._role:getItemOnlyId(),
                count = 1,
                itemId = v.itemId,
            }

            self._goodsInfoList[v.itemId] = {
                name = v.name,
                price = v.price,
                priceUnit = v.priceUnit,
                discount = v.discount,
            }

            table.insert(self._rightSellList, goods)
        end
    end
end

function BlackStore:getItemInRightSoldListCount(itemId)
    for i, v in ipairs(self._rightSoldList) do
        if v.itemId == itemId then
            return v.count
        end
    end

    return 0
end

function BlackStore:checkCanSellGoods(goods)
    local can_sell, msg = true, ""
    local itemAttr = self._role:getOneItemByKey(goods.itemId)

    if can_sell and itemAttr.itemCanSale ~= 1 and itemAttr.itemCanSale ~= true then
        can_sell = false
        msg = itemAttr.name .. "不能出售!"
    end

    if can_sell and self._role:checkItemIsEquip(goods.id) == true then
        can_sell = false
        msg = "装备中的物品无法出售"
    end

    if can_sell and self._role:checkIsPrepareWeapon(goods.id) == true then
        can_sell = false
        msg = "准备中的武器无法出售"
    end

    if can_sell and itemAttr.id == "guanfugongwen" then
        can_sell = false
        msg = tostring(itemAttr.name) .. "不能出售!"
    end

    if can_sell and itemAttr.priceUnit == "yuanbao" then
        can_sell = false
        msg = "此物太过珍贵,不能出售!"
    end

    if can_sell and itemAttr.wpType == "神兵" then
        can_sell = false
        msg = "神兵不能出售!"
    end

    if can_sell then
        return true, goods.count
    end

    --在购买列表中 可直接出售
    for i, v in ipairs(self._rightSoldList) do
        if v.itemId == goods.itemId then
            return true, v.count
        end
    end

    return false, msg
end

--[[
    goods = {
        itemId = "",
        count = 1,
        price = 111,
        priceUnit = "yuanbao"
    }
]]
function BlackStore:__checkCanBuyGoods(goods)
    if MapIsEmpty(goods) then
        return false
    end

    local currencyNum = self:__getCurrencyNum(goods.priceUnit)
    if currencyNum < goods.price then
        local currencyName = self:getCurrencyName(goods.priceUnit)
        return false, currencyName.."不足"
    end

    local itemId = goods.itemId
    local itemAttr = self._role:getOneItemByKey(itemId)

    local currItemNum = #self._leftItems

    if itemAttr.canFold == ITEM_STATE_TRUE then
        if currItemNum + math.ceil(goods.count/99) <= self:getRoleItemLimit() then
            return true
        end

        for _, leftItem in ipairs(self._leftItems) do
            if leftItem.itemId == itemId and leftItem.count + goods.count <= 99 then
                return true
            end
        end
    else
        if currItemNum + goods.count <= self:getRoleItemLimit() then
            return true
        end
    end

    return false, "背包容量已达上限，无法购买。"
end

function BlackStore:__initCurrencyList(list)
    self._currencyList = {
        ["money"] = {
            name = "碎银",
            num  = self._role:getAttr("money")
        },
    }

    if MapIsEmpty(list) == false then
        for k, v in pairs(list) do
            if not self._currencyList[v.unit] then
                self._currencyList[v.unit] = {
                    name = v.name,
                    num = v.num
                }
            end
        end
    end
end

function BlackStore:__getCurrencyNum(currencyUnit)
    if self._currencyList[currencyUnit] then
        return self._currencyList[currencyUnit].num
    else
        error("非法货币")
    end
end

function BlackStore:getCurrencyName(currencyUnit)
    if self._currencyList[currencyUnit] then
        return self._currencyList[currencyUnit].name
    else
        error("非法货币")
    end
end

function BlackStore:__updateCurrency(currencyUnit, num)
    if self._currencyList[currencyUnit] then
        self._currencyList[currencyUnit].num = self._currencyList[currencyUnit].num + num
    else
        error("非法货币")
    end
end

--[[
    goods = {
        id = id,
        itemId = itemId,
        count = sellCount,
    }
]]
function BlackStore:__refreshLeftSoldList(goods)
    if self._behavior == StoreBehavior.Buy then
        local count = 0

        if goods.type == GoodsType.BuyType then
            return count
        end

        for i = #self._leftSoldList, 1, -1 do
            local item = self._leftSoldList[i]
            if goods.itemId == item.itemId then
                if item.count > goods.count then
                    item.count = item.count - goods.count
                    count = goods.count
                else
                    count = item.count
                    table.remove(self._leftSoldList, i)
                end
                break
            end 
        end

        return count
    elseif self._behavior == StoreBehavior.Sell then
        local isReturn = false

        for i, v in ipairs(self._rightSoldList) do
            if goods.itemId == v.itemId then
                isReturn = true
                break
            end
        end
        
        if isReturn == false then
            local isSold = false

            for i, v in ipairs(self._leftSoldList) do
                if goods.itemId == v.itemId then
                    v.count = v.count + goods.count
                    isSold = true
                    break
                end
            end

            if isSold == false then
                local sell_item = {
                    id = goods.id,
                    itemId = goods.itemId,
                    count = goods.count,
                }

                table.insert(self._leftSoldList, sell_item)
            end
        end
    end
end

--[[
    goods = {
        id = id,
        itemId = itemId,
        count = sellCount,
    }
]]
function BlackStore:__refreshLeftSellList(goods)
    local itemAttr = self._role:getOneItemByKey(goods.itemId)

    if self._behavior == StoreBehavior.Buy then
        if itemAttr.canFold == ITEM_STATE_TRUE then
            local isFold = false
            local buyCount = goods.count
            local lastCount = goods.count
            for index, leftItem in ipairs(self._leftItems) do
                if leftItem.itemId == goods.itemId then
                    if leftItem.count < 99 then
                        if leftItem.count + buyCount < 99 then
                            leftItem.count = leftItem.count + buyCount
                            isFold = true
                        else
                            lastCount = buyCount + leftItem.count - 99
                            leftItem.count = 99
                            isFold = false
                        end
                        break
                    end
                end
            end

            if isFold == false then
                local foleNum = math.ceil(lastCount / 99)
                for i = 1, foleNum, 1 do
                    local count = lastCount < 99 and lastCount or 99
                    local buyItem = {
                        id = self._role:getItemOnlyId(),
                        itemId = goods.itemId,
                        count = count,
                    }

                    table.insert(self._leftItems, buyItem)

                    lastCount = lastCount - count
                end
            end
        else
            for i = 1, goods.count, 1 do
                local buyItem = {
                    id = self._role:getItemOnlyId(),
                    itemId = goods.itemId,
                    count = 1,
                }
        
                table.insert(self._leftItems, buyItem)
            end
        end
    elseif self._behavior == StoreBehavior.Sell then
        local lastCount = goods.count

        for i = #self._leftItems, 1, -1 do
            local item = self._leftItems[i]
            if item.itemId == goods.itemId then
                if lastCount < item.count then
                    item.count = item.count - lastCount
                    break
                else
                    lastCount = lastCount - item.count
                    table.remove(self._leftItems, i)
                end
            end
        end
    end
end

function BlackStore:__refreshRightSoldList(goods)
    if self._behavior == StoreBehavior.Buy then
        if goods.type == GoodsType.BuyType then
            local isFold = false
            for i, v in ipairs(self._rightSoldList) do
                if goods.itemId == v.itemId then
                    v.count = v.count + goods.count
                    isFold = true
                    break
                end
            end

            if isFold == false then
                local bought_item = {
                    id = goods.id,
                    itemId = goods.itemId,
                    count = goods.count,
                }
        
                table.insert(self._rightSoldList, bought_item)
            end
        end
    elseif self._behavior == StoreBehavior.Sell then
        local sellCount = goods.count
        local restoreCount = 0
    
        for i = #self._rightSoldList, 1, -1 do
            local item = self._rightSoldList[i]
            if goods.itemId == item.itemId then
                if item.count > sellCount then
                    item.count = item.count - sellCount
                    restoreCount = sellCount
                    break
                else
                    restoreCount = item.count
                    table.remove(self._rightSoldList, i)
                end
            end 
        end
    
        return restoreCount
    end
end

function BlackStore:__refreshRightSellList(goods, isSold)
    if self._behavior == StoreBehavior.Buy then
        if goods.type == GoodsType.BuyType then
            for i = #self._rightSellList, 1, -1 do
                local item = self._rightSellList[i]
                if goods.itemId == item.itemId then
                    item.count = item.count - goods.count
                    if item.count <= 0 then
                        table.remove(self._rightSellList, i)
                    end
                    break
                end
            end
        end
    elseif self._behavior == StoreBehavior.Sell then
        if isSold then
            local isTrue = false

            for i, v in ipairs(self._rightSellList) do
                if goods.itemId == v.itemId then
                    v.count = v.count + goods.count
                    isTrue = true
                end
            end

            if isTrue == false then
                local right_item = {
                    id = goods.id,
                    itemId = goods.itemId,
                    count = goods.count,
                }

                table.insert(self._rightSellList, right_item)
            end
        end
    end
end

function BlackStore:__initGoodsPrice()
    local fuhuiyin = self._role:isHaveImprintingId("fuhuiyin")

    for i, goods in pairs(self._goodsInfoList) do
        if goods.priceUnit == "yuanbao" and fuhuiyin then
            local Meridian = require("app.models.Meridian.Meridian")
            local meridianBuffValue = Meridian:getMeridianBuffValue("fuhuiyin")
            meridianBuffValue = Helper:roundPreciseDecimal(meridianBuffValue, 5)
            goods.price = math.ceil(goods.price * meridianBuffValue)

        end
    end
end

function BlackStore:getGoodsPriceAndPriceUnit(itemId)
    if self._goodsInfoList[itemId] then
        return self._goodsInfoList[itemId].price, self._goodsInfoList[itemId].priceUnit
    else
        local itemAttr = self._role:getOneItemByKey(itemId)
        return itemAttr.salePrice, "money"
    end
end

function BlackStore:__getGoodsInfo(itemId)
    if self._goodsInfoList[itemId] then
        return self._goodsInfoList[itemId]
    end
end

return class("BlackStore", {}, BlackStore)
00000000000