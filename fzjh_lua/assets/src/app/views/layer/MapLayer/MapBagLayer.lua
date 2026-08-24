local TableProxy = require("third.tableProxy.TableProxy")
local Item = require("app.models.item.Item")
local Resource = require("app.Resource")

local MapBagLayer = class("MapBagLayer", cc.Layer)

local roleItems1 = {} -- 玩家1交易前的背包

-- modify by zill 2016/08/13
-- id
-- index
-- count
-- name
-- itemId
-- 货币
local currency = {
    -- specialCurrency 服务器控制的特殊货币，
    money = {num = 0, name = "碎银", specialCurrency = false},
    gold = {num = 0, name = "黄金", specialCurrency = false},
    yuanbao = {num = 0, name = "元宝", specialCurrency = true},
    meiyu = {num = 0, name = "江湖美誉", specialCurrency = true},
    deadCurrency = {num = 0, name = "亿冥币", specialCurrency = true},
    yinpiao = {num = 0, name = "银票", specialCurrency = true},
    gongxiandian = {num = 0, name = "师门贡献点", specialCurrency = true},
    jiaozi = {num = 0, name = "游字令", specialCurrency = true}
}

currency = TableProxy:createEncryptedTableRecursive(currency)

local roleMoney = 0
local roleItems = {} --玩家临时背包
local storageItems = {} --容器临时背包，例如尸体

local sellerItems = {} --商人临时背包
local sellerSelledItemIds = {} --商人已卖出物品列表
local sellerCurrRecycledItemIds = {} --商人本次回收的物品id列表

--工具函数，查询arr中是否包含id
local IsIdInTable = function(id, arr)
    for i, v in ipairs(arr) do
        if v == id then
            return true
        end
    end
    return false
end

--从itemlist中移除一个itemId==id的item,要考虑数量
local function removeItemById(itemlist, id)
    for i, v in ipairs(itemlist) do
        if v.itemId == id then
            v.count = v.count - 1

            if v.count <= 0 then
                table.remove(itemlist, i)
            end
            return true
        end
    end
    return false
end

--从itemlist中添加一个itemId==id的item,要考虑数量
local function addItemById(itemlist, id)
    for i, v in ipairs(itemlist) do
        if v.itemId == id then
            v.count = v.count + 1
            return
        end
    end

    --没找到则要添加一项新的
    local itemAttr = Item:getOneItemByKeyWithEncrypted(id)
    if not itemAttr then
        --assert(nil, "MapBagLayer:createItem2(mapValue) -> 没有该物品".. id)
        return false
    end
    
    
    table.insert(itemlist, createSafeTable("addItemById", {id = User:getRole():getItemOnlyId(), count = 1, itemId = id, name = itemAttr.name}, function(tab, valueName, valueFrom, valueTo)
		Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
	end))
end

function MapBagLayer:create()
    local p = MapBagLayer:new()
    p:init()
    return p
end

function MapBagLayer:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    --self:setPanelBack()--没用到
    self:initButtons()
end

function MapBagLayer:show()
    self:setVisible(true)
end

function MapBagLayer:hide()
    self:setVisible(false)
end

--[[function MapBagLayer:print_lua_table(lua_table, indent)
	local function _print_lua_table(lua_table, indent)
		if lua_table == nil then
	        print( "table is nil" )
	        return
	    end

	    indent = indent or 0

	    for k, v in pairs(lua_table) do
	        if type(k) == "string" then
	            k = string.format("%q", k)
	        end

	        local szSuffix = ""
	        if type(v) == "table" then
	            szSuffix = "{"
	        end

	        local szPrefix = string.rep("    ", indent)

	        local formatting = szPrefix .. "[" .. k .. "]" .. " = " .. szSuffix

	        if type(v) == "table" then
	            print(formatting)
	            _print_lua_table(v, indent + 1)
	            print(szPrefix .. "},")
	        else
	            local szValue = ""
	            if type(v) == "string" then
	                szValue = string.format("%q", v)
	            else
	                szValue = tostring(v)
	            end
	            print(formatting .. szValue .. ",")
	        end
	    end
	end
	return _print_lua_table(lua_table, indent)
end
]]
-- 设置角色,参数1是玩家角色，参数2是NPC，func点击按钮关闭界面后的回调
function MapBagLayer:setRoles(role1, role2, func)
    if not role1 or not role2 then
        assert(nil, "MapBagLayer:setRoles(role1, role2) -> 角色1或者角色2不存在")
    end

    -- 背包交易界面，交易功能说明
    -- 进入界面，左边为玩家背包，右边为npc物品列表
    -- 设置标题和回调
    self.Image_title.Text_title2:setString(role2:getName())
    self._callBackFunc = func

    self.role1 = role1
    self.role2 = role2

    --为玩家临时背包填充数据
    roleItems = clone(role1:getItems())
    roleMoney = 0 --交易额置零

    -- 清空交易货币数量
    for k, v in pairs(currency) do
        v.num = 0
    end

    -- 能卖出售物品给NPC
    self.npcCanSale = true

    --把玩家背包的数据填充到ui
    self:setBagList(roleItems)

    -- 判断role2是不是商人
    if self.role2.canSale == 1 or self.role2.canSale == true then
        --重要的标志
        self.Is_Sales = true

        -- 江湖美誉
        self.meiyu = nil
        self.Text_meiyu:setVisible(false)

        self.deadCurrency = nil
        self.Text_deadCurrency:setVisible(false)

        self.gongxiandian = nil
        self.Text_gongxiandian:setVisible(false)
        -- 元宝
        self.yuanbao = nil

        self:setTextMoney()

        --商人的话，要把之前玩家卖的东西拿出来卖
        sellerSelledItemIds = {} --清空曾经卖掉的物品id列表，离柜概不负责
        sellerCurrRecycledItemIds = {} --清空本次典当的物品id列表

        --玩家以前典当的物品列表
        if role2.sellerRecycledItems == nil then
            role2.sellerRecycledItems = {}
        end

        --销售列表
        sellerItems = clone(role2:getItems())
        for i, v in ipairs(sellerItems) do
            --商品数量无限
            v.count = 999
        end

        -- 添加黑市商人物品
        for i, v in ipairs(role2.blackMarket) do
            if v.count == nil then
                v.count = 999
            end
            for j = 1, v.count do
                if addItemById(sellerItems, v.itemId) ~= false then
                    -- 添加第一个物品初始化数据
                    if j == 1 then
                        local tab = clone(v)
                        Helper:tableCover(sellerItems[table.getn(sellerItems)], tab)
                        sellerItems[table.getn(sellerItems)].count = 1
                    end
                end
            end
        end

        --商人模式需要额外放置回收物品，回收物品中包括玩家上次典当的物品和本次购买后又退还的物品
        for i, v in ipairs(role2.sellerRecycledItems) do
            --table.insert( sellerItems , v )
            --addItemById( sellerItems , v.itemId )
            for j = 1, v.count do
                addItemById(sellerItems, v.itemId)
            end
        end

        --先添加商店购买的物品
        self:setBagList2(sellerItems)
    else
        self.Is_Sales = false

        --容器存取
        storageItems = clone(role2:getItems())
        --把尸体背包的数据填充到ui
        self:setBagList2(storageItems)

        self.Text_money:setVisible(false)
        self.Text_deadCurrency:setVisible(false)
        self.Text_meiyu:setVisible(false)
        self.Text_gongxiandian:setVisible(false)
    end

    self:initSafeItem(roleItems)
    self:initSafeItem(sellerItems)
    self:initSafeItem(storageItems)

    -- 刷新玩家临时背包容量
    self:refreshWeightUI()

    -- 文本隐藏
    self.Text_desc:setVisible(false)

    -- 按钮初始化
    self:setButtons()
end

-- 自己的背包
function MapBagLayer:setBagList(list)
    if not list then
        return
    end

    -- self.totalCount = table.getn(list)
    -- if MapIsEmpty(list) then
    -- else
    -- 	for i = 1, table.getn(list) do
    -- 		local widget = self.ListView_1:getItem(i)
    -- 		local row = self:setOneItem(list[i], widget)
    -- 		if row ~= nil and widget == nil then
    -- 			self.ListView_1:pushBackCustomItem(row)
    -- 		end
    -- 	end
    -- end
    --显示我的背包
    -- self.ListView_1:removeAllItems()
    for i, v in ipairs(list) do
        local row
        if v.count > 0 then
            local item = Item:getOneItemByKeyWithEncrypted(v.itemId)
            if not item then
                if DEBUG_MODE == 1 then
                    assert(nil, "MapBagLayer:createItem1(mapValue) -> 没有该物品" .. v.itemId)
                end
            else
                --  NEEDTODO 考虑优化 物品太多时。。。
                local widget = self.ListView_1:getItem(i - 1)
                row = self:createItem1(v, item, widget, i)
                if widget == nil then
                    self.ListView_1:pushBackCustomItem(row)
                end
            end
        end
    end

    for i = table.getn(list) + 1, table.getn(self.ListView_1:getItems()) do
        self.ListView_1:removeLastItem()
    end
end

-- 对方的背包
function MapBagLayer:setBagList2(list)
    if not list then
        return
    end

    -- self.ListView_2:removeAllItems()

    for i, v in ipairs(list) do
        local row
        if v.count > 0 then
            local item = Item:getOneItemByKeyWithEncrypted(v.itemId)
            if not item then
                if DEBUG_MODE == 1 then
                    assert(nil, "MapBagLayer:createItem2(mapValue) -> 没有该物品" .. v.itemId)
                end
            end
            if v.prestige then --当前声望要求
                item.prestige = v.prestige
            end
            local widget = self.ListView_2:getItem(i - 1)
            row = self:createItem2(v, item, widget, i)

            if widget == nil then
                self.ListView_2:pushBackCustomItem(row)
            end
        end
    end

    for i = table.getn(list) + 1, table.getn(self.ListView_2:getItems()) do
        self.ListView_2:removeLastItem()
    end
end

-- 自己背包的栏目
function MapBagLayer:createItem1(bagItem, itemData, widget, index)
    local row = widget
    if row == nil then
        row = self.Panel_item1:clone()
        Helper:convertUI(row)
    end

    row:setVisible(true)
    row.Text_name:setColor(cc.c3b(208, 208, 208))
     --设置默认颜色
    if itemData.wpType == "神兵" then
        row.Text_name:setString(tostring(itemData.name))
    else
        row.Text_name:setString(tostring(itemData.name) .. " X " .. tostring(bagItem.count))
    end

    local outlineColor = cc.c4b(24, 24, 24, 255)
    local outlineWidth = 5
    row.Text_name:enableOutline(outlineColor, outlineWidth)

    local role = User:getRole()
    -- 点击处理
    row:releaseFunc(
        function()
            -- 当前选中栏目
            local item, i = role:getItemWithOnlyId(bagItem.id)
            local Itemss = role:getItems()

            local ret, msg = self:checkItemCanDrop(itemData)
            if ret == false then
                --物品不能转移
                PopText(msg)
                return
            end

            -- 设置货币单位
            local priceUnit = itemData.priceUnit
            if priceUnit == "" or priceUnit == nil then
                priceUnit = "money"
            end

            if self.Is_Sales == true then
                if self.npcCanSale ~= true then
                    PopText("此处无法出售商品")
                    return
                end
                --此处要考虑退货，卖出
                --出售给商店
                local ret, msg = self:checkItemCanSell(itemData)
                if ret == false then
                    --物品不能出售
                    PopText(msg)
                    return
                end

                local bgitemToSell = roleItems[index]
                local currMoney = User:getRole():getNumAttr("money") --人物当前金钱数量

                --判断物品是否是刚购买的物品，如果是，则原价退回
                if IsIdInTable(bgitemToSell.itemId, sellerSelledItemIds) == true then
                    --把物品放到商人回收物品中
                    if self:pushItemFoldAll(sellerItems, bgitemToSell, 9999) == true then
                        --从玩家数据中删除一件物品
                        self:popItemByIndex(roleItems, index)

                        --把刚从那件物品从购买记录中删除
                        for i, v in ipairs(sellerSelledItemIds) do
                            if v == bgitemToSell.itemId then
                                table.remove(sellerSelledItemIds, i)
                                break
                            end
                        end

                        currency[priceUnit].num = currency[priceUnit].num + tonumber(itemData.buyPrice)
                        roleMoney = roleMoney + tonumber(itemData.buyPrice)

                        local desc = "你退还一" .. tostring(itemData.unit) .. tostring(itemData.name) .. "收回了" .. tostring(math.abs(itemData.buyPrice)) .. currency[priceUnit].name
                        PopText(desc)
                    else
                        PopText("他不要!")
                    end
                elseif role:checkItemIsEquip(bagItem.id) then
                    PopText("装备中的物品无法出售")
                elseif role:checkIsPrepareWeapon(bagItem.id) then
                    PopText("准备中的武器无法出售")
                elseif bagItem.wanhaodu and bagItem.wanhaodu == 0 then
                    PopText("此兵器已经损坏，无法出售!")
                else
                    --典当一件玩家的物品
                    if self:pushItemFoldAll(sellerItems, bgitemToSell, 9999) == true then
                        --从玩家数据中删除一件物品
                        self:popItemByIndex(roleItems, index)

                        --把玩家典当掉的物品id记录起来，以便于记录赎回
                        table.insert(sellerCurrRecycledItemIds, bgitemToSell.itemId)

                        sellerCurrRecycledItemIds = TableProxy:createEncryptedTableRecursive(sellerCurrRecycledItemIds)

                        currency[priceUnit].num = currency[priceUnit].num + tonumber(itemData.salePrice)

                        roleMoney = roleMoney + tonumber(itemData.salePrice)

                        local desc = "你出售一" .. tostring(itemData.unit) .. tostring(itemData.name) .. "获得了" .. tostring(math.abs(itemData.salePrice)) .. currency[priceUnit].name
                        PopText(desc)
                    else
                        PopText("他不要!")
                    end
                end

                self:setBagList(roleItems)
                self:setBagList2(sellerItems)
                self:refreshWeightUI()
                self:setTextMoney(currMoney + roleMoney)
            else
                -- add by XiaoZhiWei 2017/11/06 14:57:46 已装备的物品不能放入尸体
                if role:checkItemIsEquip(bagItem.id) then
                    PopText("装备中的物品无法丢弃")
                    return
                elseif role:checkIsPrepareWeapon(bagItem.id) then
                    PopText("准备中的武器无法丢弃")
                    return
                else
                    --转移到尸体
                    local bgitem = roleItems[index]
                    --
                    if self:pushItem(storageItems, bgitem, 20) == true then
                        self:popItemByIndex(roleItems, index)
                    else
                        PopText("已经无法塞更多了")
                    end
                end
                self:setBagList(roleItems)
                self:setBagList2(storageItems)
            end

            -- 列表及金钱的刷新
            self:refreshWeightUI()
        end
    )
    return row
end

-- 对方背包的栏目
function MapBagLayer:createItem2(bagItem, itemData, widget, index)
    local row = widget
    if row == nil then
        row = self.Panel_item2:clone()
        Helper:convertUI(row)
    end

    -- 获取货币单位
    local priceUnit = bagItem.priceUnit
    if priceUnit == nil then
        priceUnit = itemData.priceUnit
        if priceUnit == "" or priceUnit == nil then
            priceUnit = "money"
        end
    end

    row:setVisible(true)

    --显示名字
    row.Text_name:setColor(cc.c3b(208, 208, 208)) --设置颜色
    row.Text_name:setString(tostring(itemData.name))
    local outlineColor = cc.c4b(24, 24, 24, 255)
    local outlineWidth = 5
    row.Text_name:enableOutline(outlineColor, outlineWidth)
    row.Text_num:enableOutline(outlineColor, outlineWidth)

    if self.Is_Sales then
        local buyPrice
        if bagItem.price ~= nil then
            buyPrice = bagItem.price
        else
            buyPrice = itemData.buyPrice
        end
        -- 显示价格或个数
        -- 经脉系统 黑市商人元宝购买有折扣 10%
        local role = User:getRole()
        if bagItem.isBlackChapman == true and priceUnit == "yuanbao" and role:isHaveImprintingId("fuhuiyin") then
            local Meridian = require("app.models.Meridian.Meridian")
            local meridianBuffValue = Meridian:getMeridianBuffValue("fuhuiyin")
            buyPrice = math.ceil(buyPrice * meridianBuffValue)
        end
        if self.isHaveTitle then --师门声望唯一头衔7.5折
            buyPrice = math.ceil(buyPrice * 0.75)
        end
        row.Text_num:setString(tostring(math.abs(buyPrice)) .. " " .. currency[priceUnit].name)
    else
        --尸体容器
        row.Text_num:setString(" X " .. tostring(bagItem.count))
    end

    row:releaseFunc(
        function()
            --购买按钮
            --判断物品唯一性,判断物品可以获取
            local ret, msg = self:checkItemCanLoot(itemData)
            if ret == false then
                --物品不能获取
                PopText(msg)
                return
            end

            if self.Is_Sales == true then
                --商人
                local bgitemToBuy = sellerItems[index]
                local weight = User:getRole():getNumAttr("weight") --人物背包容量
                local currMoney = User:getRole():getNumAttr("money") --人物当前金钱数量

                -- 现有的货币数额
                local currNum = User:getRole():getNumAttr(priceUnit)

                --查询是不是刚典当的物品id
                local isBuyBackItem = IsIdInTable(bgitemToBuy.itemId, sellerCurrRecycledItemIds)
                -- print( ">>>>>>>>>>>>>>>>>>>>>> isBuyBackItem=" .. tostring(isBuyBackItem) )
                -- print( ">>>>>>>>>>>>>>>>>>>>>> itemData.salePrice=" .. itemData.salePrice )
                -- print( ">>>>>>>>>>>>>>>>>>>>>> currMoney + roleMoney=" .. (currMoney + roleMoney) )
                if currency[priceUnit].specialCurrency ~= true then
                    if isBuyBackItem == true then
                        --赎回
                        if itemData.salePrice > currNum + currency[priceUnit].num then
                            --钱不够
                            PopText(currency[priceUnit].name .. "不够")
                            return
                        end
                    else
                        --购买
                        --限制购买灵石
                        if bgitemToBuy.itemId == "lingshi1" then
                            for k, item in pairs(User:getRole():getItems()) do
                                if item.itemId == "lingshi1" then
                                    PopText("灵石只能拥有一个")
                                    return
                                end
                            end

                            if sellerSelledItemIds then
                                for k, v in pairs(sellerSelledItemIds) do
                                    if v == "lingshi1" then
                                        PopText("灵石只能拥有一个")
                                        return
                                    end
                                end
                            end
                        end
                        local price = bgitemToBuy.price
                        if price == nil then
                            price = itemData.buyPrice
                        end

                        if tonumber(price) > currNum + currency[priceUnit].num then
                            --钱不够
                            PopText("你买不起")
                            return
                        end
                    end
                end

                -- self:pushItem() 中参数priceUnit 此处做判断时priceUnit必须统一为 specialCurrency，暂用"yuanbao",这样才不会不经过二次判断直接加入背包
                if self:pushItem(roleItems, bgitemToBuy, weight, "yuanbao") == true then
                    --此处要判断买入，赎回
                    --如果要买的物品id在购物记录中，则赎回
                    --如果判断要买的物品id在典当记录中，则赎回
                    if isBuyBackItem == true then
                        self:popItemByIndex(sellerItems, index)

                        --从典当记录中删除记录
                        for i, v in ipairs(sellerCurrRecycledItemIds) do
                            if v == bgitemToBuy.itemId then
                                table.remove(sellerCurrRecycledItemIds, i)
                                break
                            end
                        end

                        --以典当价赎回
                        currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.salePrice)
                        roleMoney = roleMoney - tonumber(itemData.salePrice)
                        if priceUnit == "meiyu" or priceUnit == "deadCurrency" or priceUnit == "money" then
                            self:pushItem(roleItems, bgitemToBuy, weight, "")
                        end
                        print(itemData.salePrice)
                        local desc = "你赎回一" .. tostring(itemData.unit) .. tostring(itemData.name) .. "花费了" .. tostring(math.abs(itemData.salePrice)) .. currency[priceUnit].name
                        PopText(desc)
                    else
                        if bagItem.price ~= nil and priceUnit == "yuanbao" then
                            -- 元宝购买
                            self:buyYuanBaoItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
                            return
                        elseif bagItem.price ~= nil and priceUnit == "money" and bagItem.is_buy_time ~= nil then
                            -- 碎银购买，但要记录次数
                            self:buyMoneyItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
                            return
                        elseif bagItem.price ~= nil and priceUnit == "deadCurrency" then
                            -- 冥币购买
                            self:buyDeadCurrencyItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
                            return
                        elseif bagItem.price ~= nil and priceUnit == "gongxiandian" then
                            -- 师门声望商人 贡献点
                            self:buyPrestigeItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
                        elseif priceUnit == "yuanbao" and bagItem.isBlackChapman == true then
                            local role = User:getRole()
                            local isDiscount = role:isHaveImprintingId("fuhuiyin")
                            local isFreeSingle = role:isHaveImprintingId("fulingyin")

                            --书页购买
                            PopYuanBaoBuyItemLayer(
                                itemData.id,
                                function(eventType)
                                    if eventType == "success" then
                                        local desc = "你购买了 " .. tostring(itemData.name)
                                        PopText(desc)

                                        -- 确认购买成功再放入玩家背包
                                        self:popItemByIndex(sellerItems, index)

                                        -- 先放入背包，避免玩家直接关闭游戏没有保存元宝购买的道具
                                        User:getRole():addItemCount(itemData.id, 1, nil, nil, "黑市商人购买")

                                        if
                                            itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or itemData.type == "淬炼材料" or
                                                itemData.type == "锻造材料"
                                         then
                                        else
                                            self:pushItem(roleItems, bgitemToBuy, weight, "")
                                        end
                                        self:setBagList(roleItems)
                                        self:setBagList2(sellerItems)
                                        self:refreshWeightUI()
                                        self:setTextMoney()
                                    end
                                end,
                                {mark = {isDiscount = isDiscount, isFreeSingle = isFreeSingle}}
                            )
                            return
                        elseif priceUnit == "meiyu" then
                            -- 江湖美誉 购买
                            self:buyMeiYuItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
                            return
                        elseif priceUnit == "jiaozi" then
                            self:buyJiaoZiItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
                            return
                        else
                            local textList = {
                                Text_tital = itemData.name,
                                Text_type = itemData:getItemShowType(),
                                Text_dsc = itemData.dsc,
                                Text_price = "售价:" .. itemData.buyPrice .. "碎银",
                                Text_affirm = "确定购买" .. itemData.name .. "吗？",
                                Text_havenum = "已拥有:" .. User:getRole():getItemTotalCount(itemData.id) .. itemData.unit
                            }

                            PopupLayerController:showLayer(
                                "ShoppingDialogLayer",
                                function(layer)
                                    layer:showLayer(
                                        textList,
                                        function()
                                        end
                                    )
                                    layer:setButton_confirm(
                                        "确定",
                                        function()
                                            self:popItemByIndex(sellerItems, index)

                                            local itemAttr = Item:getOneItemByKeyWithEncrypted(bgitemToBuy.itemId)

                                            if
                                                itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or
                                                    itemData.type == "淬炼材料" or
                                                    itemData.type == "锻造材料"
                                             then
                                                User:getRole():addItemCount(itemData.id, 1, nil, nil, "商人交易")
                                            else
                                                self:pushItem(roleItems, bgitemToBuy, weight, "")
                                            end

                                            --正常购买流程
                                            currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.buyPrice)
                                            roleMoney = roleMoney - tonumber(itemData.buyPrice)

                                            local desc = "你购买一" .. tostring(itemData.unit) .. tostring(itemData.name) .. "花费了" .. tostring(math.abs(itemData.buyPrice)) .. currency[priceUnit].name
                                            PopText(desc)

                                            --把本次购买的商品加入购物记录，以便本次退货时能原价退回
                                            table.insert(sellerSelledItemIds, bgitemToBuy.itemId)

                                            -- 列表刷新
                                            self:setBagList(roleItems)
                                            self:setBagList2(sellerItems)
                                            self:refreshWeightUI()
                                            self:setTextMoney(currMoney + roleMoney)
                                        end
                                    )
                                    layer:setButton_close(
                                        "取消",
                                        function()
                                        end
                                    )

                                    --不能进行批量购买物品列表
                                    local canNotbatchBuyList = {
                                        lingshi1 = true
                                    }
                                    if sellerItems[index].count > 1 and canNotbatchBuyList[bgitemToBuy.itemId] ~= true then
                                        layer:setButton_batchBuy(
                                            "批量购买",
                                            function()
                                                -- 先选择购买数量 ，然后判断背包容量
                                                if priceUnit ~= "money" then
                                                    PopText("碎银购买的物品才能批量购买")
                                                    return
                                                end
                                                PopupLayerController:showLayer(
                                                    "BatchProcessLayer",
                                                    function(batchLayer)
                                                        batchLayer:showLayer()
                                                        batchLayer:setBuyPrice(itemData.buyPrice)
                                                        batchLayer:setInitNum(1)
                                                        batchLayer:setMinNum(1)
                                                        batchLayer:setMaxNum(math.min(99, sellerItems[index].count))
                                                        batchLayer:setTextDesc(itemData.name)
                                                        batchLayer:setTextDesc4("选择你要购买的数量")
                                                        batchLayer:setTextDesc5("售价：" .. itemData.buyPrice .. "碎银")
                                                        batchLayer:setButtonConfirm(
                                                            function(batchBuyNum)
                                                                print("购买数量 = ", batchBuyNum)
                                                                if self:checkCanBuyThings(itemData.id, batchBuyNum) ~= true then
                                                                    PopText("背包容量不足")
                                                                    return
                                                                end

                                                                if tonumber(itemData.buyPrice) * batchBuyNum > currMoney + currency[priceUnit].num then
                                                                    --钱不够
                                                                    PopText("你买不起")
                                                                    return
                                                                end

                                                                --判断库存
                                                                if sellerItems[index].count < batchBuyNum then
                                                                    PopText("商品库存不足")
                                                                    return
                                                                elseif sellerItems[index].count == batchBuyNum then
                                                                    table.remove(sellerItems, index)
                                                                else
                                                                    sellerItems[index].count = sellerItems[index].count - batchBuyNum
                                                                end

                                                                local itemAttr = Item:getOneItemByKeyWithEncrypted(bgitemToBuy.itemId)

                                                                if
                                                                    itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or
                                                                        itemData.type == "淬炼材料" or
                                                                        itemData.type == "锻造材料"
                                                                 then
                                                                    User:getRole():addItemCount(itemData.id, batchBuyNum, nil, nil, "商人交易")
                                                                else
                                                                    self:pushMultItem(roleItems, bgitemToBuy, batchBuyNum)
                                                                end

                                                                currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.buyPrice) * batchBuyNum
                                                                roleMoney = roleMoney - tonumber(itemData.buyPrice) * batchBuyNum

                                                                local desc =
                                                                    "你购买" ..
                                                                    tostring(batchBuyNum) ..
                                                                        tostring(itemData.unit) ..
                                                                            tostring(itemData.name) .. "花费了" .. tostring(math.abs(itemData.buyPrice) * batchBuyNum) .. currency[priceUnit].name
                                                                PopText(desc)

                                                                for i = 1, batchBuyNum do
                                                                    --把本次购买的商品加入购物记录，以便本次退货时能原价退回
                                                                    table.insert(sellerSelledItemIds, bgitemToBuy.itemId)
                                                                end

                                                                -- 列表刷新
                                                                self:setBagList(roleItems)
                                                                self:setBagList2(sellerItems)
                                                                self:refreshWeightUI()
                                                                self:setTextMoney(currMoney + roleMoney)
                                                            end
                                                        )
                                                    end
                                                )
                                            end
                                        )
                                    end
                                end
                            )
                            return
                        end
                    end
                else
                    PopText("你的包塞不下了")
                end

                -- 列表刷新
                self:setBagList(roleItems)
                self:setBagList2(sellerItems)
                self:refreshWeightUI()
                self:setTextMoney(currMoney + roleMoney)
            else
                --从尸体容器拿去一个物品
                local bgitemToGet = storageItems[index]
                local weight = User:getRole():getNumAttr("weight") --人物背包容量

                local itemAttr = User:getRole():getOneItemByKey(bgitemToGet.itemId)
                -- 判断是否是书页类物品,如果是,则直接放进书箱
                if itemAttr.type == "书页" or itemAttr.type == "武学秘宝" or itemAttr.type == "毒药" or itemAttr.type == "制药材料" or itemData.type == "淬炼材料" or itemData.type == "锻造材料" then
                    User:getRole():addItemCount(bgitemToGet.itemId, 1)
                    self:popItemByIndex(storageItems, index)
                    PopText("你获得了 " .. tostring(itemAttr.name))
                elseif itemAttr.type == "神书" then --优化神书更新方式
                    if self:pushItem(roleItems, bgitemToGet, weight) == true then
                        self:popItemByIndex(storageItems, index)
                        local result = User:getRole():addItemCount(bgitemToGet.itemId, 1)
                        self:updateShenShuList(bgitemToGet.itemId)
                        PopText("你获得了 " .. tostring(itemAttr.name))
                    else
                        PopText("你的包塞不下了")
                    end
                else
                    if self:pushItem(roleItems, bgitemToGet, weight) == true then
                        -- PopText(bgitemToGet.itemId..","..bgitemToGet.name)
                        self:popItemByIndex(storageItems, index)
                    else
                        PopText("你的包塞不下了")
                    end
                end

                self:setBagList(roleItems)
                self:setBagList2(storageItems)
                self:refreshWeightUI()
            end
        end
    )
    return row
end

--检查能否购买物品
function MapBagLayer:checkCanBuyThings(itemId, num)
    if not itemId or not num then
        return false
    end
    local role = User:getRole()
    local itemAttr = role:getOneItemByKey(itemId)
    if itemAttr == nil then
        return false
    end
    if itemAttr.canFold == ITEM_STATE_TRUE then
        for i, item in ipairs(roleItems) do
            if item.itemId == itemId then
                if item.count + num > 99 then
                    num = num - 99 + item.count
                else
                    num = 0
                end
            end
        end
        if num > 0 and table.getn(roleItems) + 1 > role:getNumAttr("weight") then
            return false
        end
    else
        if table.getn(roleItems) + num > role:getNumAttr("weight") then
            return false
        end
    end
    return true
end

function MapBagLayer:updateShenShuList(itemId)
    if itemId == nil then
        return
    end
    
    local ShenShuHelper = require("app.models.shenshu.shenshu")

	local role = User:getRole()

	if ShenShuHelper:checkIsInFindBook(role) == false then
		return
	end

	local isTrue = ShenShuHelper:findBook(role, itemId)

	if isTrue then
		ShenShuHelper:getHintText(itemId)
        local mapLayer = MainControllLayer:getLayer("MapLayer")
        mapLayer._currMap:removeTaskFromDelayTasks(itemId)
	end
end

function MapBagLayer:lootAllItems()
    --从storageItems中把物品全部转移过来
    local exitFor = false
    local weight = User:getRole():getNumAttr("weight") --人物背包容量

    --寻找是否已经有这类物品了
    local tcount = table.getn(storageItems)
    for i = tcount, 1, -1 do
        --for i,bgitem in ipairs( storageItems ) do
        local bgitem = storageItems[i]
        repeat
            local itemData = Item:getOneItemByKeyWithEncrypted(bgitem.itemId)
            -- add by XiaoZhiWei 2017/11/06 15:10:27 尸体上的动气能够全部转移过来
            -- local ret, msg = self:checkItemCanDrop(itemData)
            -- if ret == false then
            -- 	--物品不能转移
            -- 	PopText(msg)
            -- 	break
            -- end

            local count = bgitem.count
             --尸体中物品数量超过1
            if itemData.canFold == ITEM_STATE_FALSE then
                count = 1
            end

            for j = count, 1, -1 do
                if itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or itemData.type == "淬炼材料" or itemData.type == "锻造材料" then
                    User:getRole():addItemCount(bgitem.itemId, 1, nil, nil, "战利品")
                    self:popItemByIndex(storageItems, i)
                    PopText("你获得了 " .. tostring(itemData.name))
                elseif itemData.type == "神书" then --优化神书更新方式
                    if self:pushItem(roleItems, bgitem, weight) == true then
                        self:popItemByIndex(storageItems, i)
                        local result = User:getRole():addItemCount(bgitem.itemId, 1)
                        self:updateShenShuList(bgitem.itemId)
                        PopText("你获得了 " .. tostring(itemData.name))
                    else
                        PopText("你的包塞不下了")
                    end
                else
                    if self:pushItem(roleItems, bgitem, weight) == true then
                        self:popItemByIndex(storageItems, i)
                    else
                        PopText("你的背包满了,无法拿取")
                        exitFor = true
                        break
                    end
                end

                -- if self:pushItem( roleItems , bgitem , weight ) == true then
                -- 	self:popItemByIndex( storageItems , i )
                -- else
                -- 	PopText( "你的背包满了,无法拿取" )
                -- 	exitFor = true
                -- 	break
                -- end
            end
        until true

        if exitFor == true then
            break
        end
    end

    --刷新
    self:setBagList(roleItems)
    self:setBagList2(storageItems)
    self:refreshWeightUI()
end

function MapBagLayer:popItemByIndex(itemlist, index)
    local it = itemlist[index]

    --print( "popItemByIndex index=" .. index )
    --self:print_lua_table( it )
    --local itemAttr = Item:getOneItemByKeyWithEncrypted( it.itemId )
    --if itemAttr.canFold == ITEM_STATE_TRUE and it.count > 1 then
    if it.count > 1 then --弹出商品不关心是否能叠加
        --多于1个，只弹出一个物品
        it.count = it.count - 1

        return it
    else
        --不能堆叠，或者物品只有1个
        table.remove(itemlist, index)

        return it
    end
end

--往itemlist中放一个item,这个list最多maxcount个item
function MapBagLayer:pushItem(itemlist, bgitem, maxcount, priceUnit)
    --查询itemlist是否存在该物品
    local hasSameItem = false
    local sameitem = nil

    local itemAttr = Item:getOneItemByKeyWithEncrypted(bgitem.itemId)

    --寻找是否已经有这类物品了
    for i, it in ipairs(itemlist) do
        --itemId一样表示是同类物品
        if it.itemId == bgitem.itemId then
            hasSameItem = true --有同类物品

            --判断这个物品的数量是否还没超过99个
            if it.count < 99 then
                sameitem = it
                break
            end
        end
    end
    --print( "======== itemAttr ")
    --self:print_lua_table( itemAttr )
    if sameitem ~= nil and itemAttr.canFold == ITEM_STATE_TRUE and sameitem.count > 0 then
        -- 查询物品是否唯一
        if priceUnit and priceUnit ~= "" and currency[priceUnit].specialCurrency == true then
        else
            sameitem.count = sameitem.count + 1
        end
    else
        --创建一个新物品
        if table.getn(itemlist) >= maxcount then
            --背包已经满了超过了maxcount个物品
            print("[警告] 背包已经满了超过了maxcount=" .. maxcount .. "个物品")
            return false
        end

        if priceUnit and priceUnit ~= "" and currency[priceUnit].specialCurrency == true then
        else
            table.insert(itemlist, self:createSafeItem({id = User:getRole():getItemOnlyId(), count = 1, itemId = bgitem.itemId, name = itemAttr.name}))
        end
    end

    return true
end

--放入多个物品
-- pushNum 放入物品个数，一次最多99个
function MapBagLayer:pushMultItem(itemlist, bgitem, pushNum)
    if type(pushNum) ~= "number" or pushNum > 99 then
        assert(nil, "参数格式错误  pushNum = ", pushNum)
    end

    local itemNum = pushNum
    local itemAttr = Item:getOneItemByKeyWithEncrypted(bgitem.itemId)

    if itemAttr.canFold == ITEM_STATE_TRUE then
        for i, it in ipairs(itemlist) do
            if it.itemId == bgitem.itemId then
                if it.count + itemNum > 99 then
                    itemNum = itemNum - 99 + it.count
                    it.count = 99
                else
                    it.count = it.count + itemNum
                    itemNum = 0
                end
            end
        end
        if itemNum > 0 then
            table.insert(itemlist, self:createSafeItem({id = User:getRole():getItemOnlyId(), count = itemNum, itemId = bgitem.itemId, name = itemAttr.name}))
        end
    else
        for i = 1, pushNum do
            table.insert(itemlist, self:createSafeItem({id = User:getRole():getItemOnlyId(), count = 1, itemId = bgitem.itemId, name = itemAttr.name}))
        end
    end
end

--往itemlist中放一个item,这个list最多maxcount个item 无视堆叠条件和99堆叠上限，主要用于商人
function MapBagLayer:pushItemFoldAll(itemlist, bgitem, maxcount)
    --查询itemlist是否存在该物品
    local sameitem = nil

    --寻找是否已经有这类物品了
    for i, it in ipairs(itemlist) do
        --itemId一样表示是同类物品
        if it.itemId == bgitem.itemId then
            sameitem = it
        end
    end

    local itemAttr = Item:getOneItemByKeyWithEncrypted(bgitem.itemId)
    if sameitem ~= nil then
        -- 查询物品是否唯一
        sameitem.count = sameitem.count + 1
    else
        --创建一个新物品
        if table.getn(itemlist) >= maxcount then
            --背包已经满了超过了maxcount个物品
            print("[警告] 背包已经满了超过了maxcount=" .. maxcount .. "个物品")
            return false
        end
        print("----------------pushItemFoldAll--------------------")
        -- Helper:print_lua_table(bgitem)
        table.insert(itemlist, self:createSafeItem({id = User:getRole():getItemOnlyId(), count = 1, itemId = bgitem.itemId, name = itemAttr.name}))
    end

    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 14:50:12
-- @desc 创建防作弊物品列表
function MapBagLayer:createSafeItem(itemData)
    -- local itemId = tostring(itemData.itemId)
    -- return createEncryptTable(itemData)
    -- add by XiaoZhiWei 2017/08/30 12:14:13 修改为防作弊方式
    return createSafeTable(
        "MapBagLayer.item." .. tostring(itemData.itemId),
        itemData,
        function(itemData, valueName, valueFrom, valueTo)
            Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
        end
    )
end

--判断一个物品是否可以拾取
function MapBagLayer:checkItemCanLoot(item)
    return true
end

-- 添加物品
function MapBagLayer:checkItemCanSell(item)
    local result = true
    result =
        switch(
        item.priceUnit,
        {
            money = false,
            gold = false,
            yuanbao = true,
            meiyu = true,
            deadCurrency = true
        }
    )
    return result
end

function MapBagLayer:checkItemCanDrop(item)
    -- 物品属性中的ID 等于 背包中的itemId
    local itemId = item.id
    local role = User:getRole()

    -- if role:checkItemIsEquipbyItemId(item.id) then
    -- 	return false, "已经穿戴的装备不能这样处理！"
    -- end

    if item.itemCanSale ~= 1 and item.itemCanSale ~= true then
        return false, tostring(item.name) .. "不能出售丢弃购买!"
    end

    if itemId == "guanfugongwen" then
        return false, tostring(item.name) .. "不能出售丢弃购买!"
    end

    if item.priceUnit == "yuanbao" then
        return false, "此物太过珍贵,不能出售丢弃购买!"
    end

    if item.wpType == "神兵" then
        return false, "神兵不能出售丢弃购买!"
    end

    return true
end

--先解决wight上限问题   --  总结：毛线，什么BUG先找出最根本的原因，不然，改来改去，这个现象没了，那里又出问题了！！！！
--物品价格问题
function MapBagLayer:getItemsWithItemId(itemId)
    local list = {}
    for i, item in ipairs(self.list1) do
        if item.itemId == itemId then
            item.index = i
            table.insert(list, item)
        end
    end
    return list
end

-- --lijie  7/19
-- --在副本里判断能不能购买或者出售
-- function MapBagLayer:checkCanBuyThing(itemAttr, count, list, itemId)
-- 	if not itemAttr or not count or type(count) ~= "number" then
-- 		return false
-- 	end

-- 	local role = User:getRole()
-- 	local money = role:getNumAttr("money")
-- 	local weight = role:getNumAttr("weight")
-- 	local price = itemAttr.buyPrice
-- 	local salePrice = itemAttr.salePrice
-- 	local priceUnit = itemAttr.priceUnit

-- 	if itemAttr.priceUnit == "yuanbao" then
-- 		PopText("元宝商品不能出售购买")
-- 		return false
-- 	end

-- 	if itemAttr.id == role.shenBingweapon.id then
-- 		PopText("这是您的神兵，不能出售丢弃购买！")
-- 		return false
-- 	end

-- 	--判断是出售、赎回。购买、退还
-- 	local function TheTypeOfTrade(list, itemId, count)
-- 		if not list or type(list) ~= "table" or not itemId or not count then
-- 			assert(nil, "function MapBagLayer:compareListWithItemId(list, itemId, count)")
-- 		end

-- 		local function getItemCountWithItemId(list, itemId)
-- 			local rCount = 0
-- 			for i, item in ipairs(list) do
-- 				if item.itemId == itemId then
-- 					rCount = rCount + item.count
-- 				end
-- 			end
-- 			return rCount
-- 		end

-- 		local list1, list2 = roleItems1, list
-- 		local itemAttr = Item:getOneItemByKeyWithEncrypted(itemId)

-- 		-- count1 原来的数量  count2 现在的数量
-- 		local count1, count2 = getItemCountWithItemId(list1, itemId), getItemCountWithItemId(list2, itemId)
-- 		if(count > 0 and count1 > count2) then
-- 			--赎回
-- 			self.typeOfTrade = "shuhui"
-- 			-- elseif count < 0 and count1 > count2 then
-- -- 	--出售
-- -- 	self.typeOfTrade = "chusou"
-- -- elseif (count < 0 and count1 < count2) or (count < 0 and count1 == count2) then
-- -- 	--退还
-- -- 	self.typeOfTrade = "tuihuan"
-- 		elseif count > 0 and count1 < count2 or(count > 0 and count1 == count2) then
-- 			--购买
-- 			self.typeOfTrade = "goumai"
-- 		end
-- 	end

-- 	TheTypeOfTrade(list, itemId, count)
-- 	print("-------------------------------------------------self.typeOfTrade" .. tostring(self.typeOfTrade))
-- 	--判断是元宝的物品并且是小贩才提示，尸体直接放进放出
-- 	if self.typeOfTrade == "goumai" and self.Is_Sales == true then
-- 		print("if typeOfTrade ==goumai or typeOfTrade == tuihuan then")
-- 		if price and tonumber(price) * count > money then
-- 			PopText("碎银不够了，不能继续购买")
-- 			return false
-- 		end
-- 	end
-- 	--判断赎回出售的金币是否足够
-- 	if self.typeOfTrade == "shuhui" and self.Is_Sales == true then
-- 		print("if typeOfTrade == shuhui or typeOfTrade == chusou then")
-- 		if salePrice and tonumber(salePrice) * count > money then
-- 			PopText("碎银不够了，不能继续赎回")
-- 			return false
-- 		end
-- 	end

-- 	-- local items =role:getItems()
-- 	--因为在副本里都是操作list1的，而list1又是克隆的role:getItems(),所以
-- 	local items = self.list1
-- 	local itemList = self:getItemsWithItemId(itemAttr.id)

-- 	if itemAttr.canFold == ITEM_STATE_TRUE then
-- 		for i, item in ipairs(itemList) do
-- 			if item.count + count >= 99 then
-- 				count = count - 99 + item.count
-- 			elseif i == table.getn(itemList) and item.count + count > 99 and table.getn(items) + 1 > weight then
-- 				PopText("背包容量达到上限，无法继续购买物品")
-- 				return false
-- 			else
-- 				count = 0
-- 				break
-- 			end
-- 		end
-- 	end

-- 	if table.getn(items) + 1 > weight and count > 0 then
-- 		PopText("背包容量达到上限，无法继续获得物品")
-- 		return false
-- 	end
-- 	return true
-- end

-- 玩家数据保存
function MapBagLayer:connectToUserData()
    local role = User:getRole()

    -- 计算一下最终获得的物品数量
    self:getMapItemIdAndCount(role:getAttr("items"), roleItems)

    self:addSpecialItemToRole(role, roleItems) -- add by XiaoZhiWei 2017/04/08 17:28:02 遍历一遍,将特殊类型的物品添加到角色背包后,剔除出列表

    --保存玩家道具
    role:setAttr("items", roleItems)
    -- if TEACHER_TASK_IS_OPEN == true then
    --     local TeacherTask = require("app.models.task.teacherTask.teacherTask")
    --     TeacherTask:dealTypeZero()
    -- end

    --保存玩家的货币
    for k, v in pairs(currency) do
        if k == "yuanbao" or k == "meiyu" or k == "deadCurrency" then
        else
            print(k .. " = " .. role:getNumAttr(k) .. " + " .. v.num)
            role:setAttr(k, role:getNumAttr(k) + v.num)
        end
    end

    if self.role2 then
        if self.Is_Sales then
            --商人
            --商人需要保存的是回收商品列表，便于玩家下次来看还有之前卖掉的物品，只是它们没法赎回了
            --本次典当尚未被赎回的物品需要保存
            if self.role2.sellerRecycledItems == nil then
                self.role2.sellerRecycledItems = {}
            end

            --把物品添加到回收列表中
            for i, v in ipairs(sellerCurrRecycledItemIds) do
                addItemById(self.role2.sellerRecycledItems, v)
            end

            --玩家以前典当的物品列表没卖完的还要继续销售，已经卖掉的物品要扣除
            if table.getn(self.role2.sellerRecycledItems) > 0 then
                for i, v in ipairs(sellerSelledItemIds) do --遍历已经卖掉的物品id列表
                    removeItemById(self.role2.sellerRecycledItems, v)
                end
            end

            self.role2.sellerRecycledItems = TableProxy:createEncryptedTableRecursive(self.role2.sellerRecycledItems)
        else
            --容器尸体
            self.role2:setAttr("items", storageItems)
        end
    end
end

function MapBagLayer:createButton()
    local roleButton = Resource:getUIByName("Button_4")
    Helper:convertUI(roleButton)
    roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    return roleButton
end

--按钮初始化
function MapBagLayer:initButtons()
    local button1 = self:createButton() --关闭按钮
    local button2 = self:createButton() --确定按钮
    self:addChild(button1)
    self:addChild(button2)
    button1:move(cc.p(270, 200))
    button2:move(cc.p(810, 200))
    self.Button_1 = button1
    self.Button_2 = button2
end

function MapBagLayer:setButtons()
    -- 是否是小商贩
    if self.Is_Sales == true then
        self:setButton1()
        self:setButton2(
            "确定",
            function()
                self:connectToUserData()
                self:hide()
                if type(self._callBackFunc) == "function" then
                    self._callBackFunc()
                end
            end
        )

        local Chapman = require("app.models.Chapman.Chapman")
        if Chapman:checkIsPrestigeChapman(self.role2) then --师门声望商人
            self:PrestigeChapmanRefreshButton()
        end
    else
        self:setButton1(
            "关闭",
            function()
                self:connectToUserData()
                if type(self._callBackFunc) == "function" then
                    self._callBackFunc()
                end
            end
        )
        self:setButton2(
            "提取全部",
            function()
                --self:addToList(self.list1, self.list2)
                self:lootAllItems() --从storageItems里拾取所有物品

                self:delayFunc(
                    0,
                    function()
                        self:setBagList(self.list1)
                        self:setBagList2(self.list2)
                    end
                )
            end
        )
    end
end

function MapBagLayer:setButton1(name, func, isHide)
    if not name then
        self.Button_1:setVisible(false)
        return
    else
        self.Button_1:setVisible(true)
    end
    if isHide == nil then
        isHide = true
    end
    self.Button_1.Text_buttonName:setString(name)
    self.Button_1:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")
            if func then
                func()
            end
            if isHide == true then
                self:hide()
            end
        end
    )
end

function MapBagLayer:setButton2(name, func)
    if not name then
        self.Button_2:setVisible(false)
        return
    else
        self.Button_2:setVisible(true)
    end
    self.Button_2.Text_buttonName:setString(name)
    self.Button_2:releaseFunc(
        function()
            Audio:playEffect("xiaoAnNiu")
            if func then
                func()
            end
        end
    )
end

--师门声望商人刷新按钮
function MapBagLayer:PrestigeChapmanRefreshButton()
    self:setButton1(
        "立即刷新",
        function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            local refreshPrice = self:getNextRefreshPrice()
            if type(refreshPrice) ~= "number" then
                PopText("刷新失败")
                return
            end
            dialog:show("确定花费" .. refreshPrice .. "元宝立即刷新商人道具列表吗？")
            dialog:setButton1(
                "确定",
                function()
                    local is_refresh = "Y"
                    HttpManagerEx:getPrestigeGoods(
                        self.role2.id,
                        is_refresh,
                        function(status, errcode, errmsg, data, isEncrypted)
                            -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
                            if isEncrypted == false then
                                Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
                                return
                            end
                            if status == 200 then
                                if errcode ~= 0 then
                                    PopText(errmsg)
                                else
                                    if data then
                                        local items = data.list
                                        self.role2.items = {}
                                        Helper:print_lua_table(data)
                                        self.role2.blackMarket = {}
                                        for k, v in pairs(items) do
                                            print("商人添加道具 " .. v.itemId, v.unit)
                                            table.insert(
                                                self.role2.blackMarket,
                                                {id = User:getRole():getItemOnlyId(), count = 999, itemId = v.itemId, price = v.price, prestige = v.needSw, priceUnit = v.unit}
                                            )
                                        end
                                        self.role2.canSale = 1
                                        self:setCurrPrestigeInfo(data.shengwang, data.title)
                                        self:setRoles(
                                            User:getRole(),
                                            self.role2,
                                            function()
                                                self:setCurrPrestigeInfo() --清除声望商人相关信息
                                            end
                                        )
                                        local remove = data.remove
                                        local nextRemove = data.next_yuanbao
                                        PopText("消耗" .. remove .. "元宝")
                                        self.Text_desc:setVisible(true)
                                        self.Text_desc:setString("花费" .. nextRemove .. "元宝立即刷新")
                                        self:setNextRefreshPrice(nextRemove)
                                        -- 根据返回货币类型，设置商店显示货币
                                        self:setTextGongXianDian(Helper:getDef(data.point, User:getRoleAttr("money")), Helper:getDef(data.unit, "money"))
                                        self:setNpcCanSale(false)
                                    end
                                end
                            end
                        end,
                        IS_SHOW_WAITING
                    )
                end
            )

            dialog:setButton2(
                "取消",
                function()
                end
            )
        end,
        false
    )
end

--设置下次刷新所需费用
function MapBagLayer:setNextRefreshPrice(price)
    self.nextRefreshPrice = price
end

--获取下次刷新所需费用
function MapBagLayer:getNextRefreshPrice()
    return self.nextRefreshPrice
end

-- 当前值的计数在list的重新渲染中统计
function MapBagLayer:refreshWeightUI()
    self.Text_weight:setString((table.getn(roleItems)) .. "/" .. User:getRoleAttr("weight"))
end

function MapBagLayer:setTextMoney()
    local money = User:getRole():getNumAttr("money")

    money = money + currency.money.num
    self.Text_money:setVisible(true)
    self.Text_money:setString(tostring("碎银： " .. tostring(math.floor(money))))

    -- 元宝
    self:setTextYuanBao()

    -- 江湖美誉
    self:setTextMeiYu()

    -- 冥币
    self:setTextDeadCurrency()

    --声望（贡献点）
    self:setTextGongXianDian()
end

-- 显示元宝
function MapBagLayer:setTextYuanBao(yuanbao)
    if yuanbao ~= nil then
        self.yuanbao = yuanbao
    end

    if self.yuanbao == nil then
        return
    end

    local yuanbaoNum = self.yuanbao + currency.yuanbao.num
    self.Text_meiyu:setVisible(false)
    self.Text_deadCurrency:setVisible(false)
    self.Text_gongxiandian:setVisible(false)
    self.Text_money:setVisible(true)
    self.Text_money:setString(tostring("元宝： " .. tostring(math.floor(yuanbaoNum))))
end

-- 显示江湖美誉
function MapBagLayer:setTextMeiYu(meiyu)
    if meiyu ~= nil then
        self.meiyu = meiyu
    end

    if self.meiyu == nil then
        return
    end
    local meiyu = self.meiyu + currency.meiyu.num
    self.Text_meiyu:setVisible(true)
    self.Text_meiyu:setString(tostring("江湖美誉： " .. tostring(math.floor(meiyu))))

    -- 隐藏碎银
    self.Text_money:setVisible(false)
    self.Text_deadCurrency:setVisible(false)
    self.Text_gongxiandian:setVisible(false)
    self.Text_desc:setVisible(true)
    self.Text_desc:setString("花费50元宝立即刷新")
end

-- 显示冥币
function MapBagLayer:setTextDeadCurrency(deadCurrency)
    if deadCurrency ~= nil then
        self.deadCurrency = deadCurrency
    end

    if self.deadCurrency == nil then
        return
    end

    local deadCurrency = self.deadCurrency + currency.deadCurrency.num
    self.Text_deadCurrency:setVisible(true)
    self.Text_deadCurrency:setString(tostring("HIM冥币： " .. math.floor(deadCurrency) .. "亿"))

    -- 隐藏碎银
    self.Text_money:setVisible(false)
    self.Text_meiyu:setVisible(false)
    self.Text_gongxiandian:setVisible(false)
    self.Text_desc:setVisible(true)
    if device.platform == "android" then
        self.Text_desc:setString([[]])
    elseif device.platform == "ios" then
        self.Text_desc:setString([[]])
    elseif device.platform == "windows" then
        self.Text_desc:setString([[]])
    else
    end
end

-- 显示贡献点
function MapBagLayer:setTextGongXianDian(gongxiandian)
    if gongxiandian ~= nil then
        self.gongxiandian = gongxiandian
    end

    if self.gongxiandian == nil then
        return
    end
    self.Text_money:setVisible(false)
    self.Text_meiyu:setVisible(false)
    self.Text_deadCurrency:setVisible(false)
    self.Text_gongxiandian:setVisible(true)
    local gongxiandian = self.gongxiandian + currency.gongxiandian.num
    self.Text_gongxiandian:setString(tostring("师门贡献点： " .. tostring(math.floor(gongxiandian))))
end

-- 能否将物品出售给NPC
function MapBagLayer:setNpcCanSale(flag)
    self.npcCanSale = flag
end

-- 获取价格单位
function MapBagLayer:getPriceUnit(first, second)
    -- 设置货币单位
    local priceUnit = first
    if priceUnit == nil then
        priceUnit = second
    end
    if priceUnit == "" or priceUnit == nil then
        priceUnit = "money"
    end
    return priceUnit
end
local function getVoucherPrice(item, price, npcId)
    --折扣物品Id,最大折扣个数,每个物品享有的折扣率,商人Id
    if item.voucherId == nil or item.voucherId == "" or type(npcId) ~= "string" then
        print("返回1")
        return 0, price, nil
    end
    if tonumber(price) == nil or price < 0 then
        assert(nil, "商品价格要必须是数字且数值不小于0")
    end
    local list = string.split(item.voucherId, ",")
    if table.getn(list) ~= 4 then
        print(item.voucherId)
        if DEBUG_MODE == 1 then
            assert(nil)
        end
        print("返回2")
        return 0, price, nil
    end
    if list[4] ~= npcId then
        if DEBUG_MODE == 1 then
            print("不是在指定的npc商人处购买，不享有折扣")
        end
        print("返回3", npcId, list[4])
        return 0, price, nil
    end
    local itemNum = math.min(User:getRole():getItemCount(list[1]), tonumber(list[2]))
    print(itemNum, math.floor(price * (1 - itemNum * tonumber(list[3]))))
    return itemNum, math.floor(price * (1 - itemNum * tonumber(list[3]))), User:getRole():getOneItemByKey(list[1]), (itemNum * tonumber(list[3])) * 100
end
-- 购买元宝类道具
function MapBagLayer:buyYuanBaoItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
    local price = sellerItems[index].price
    local priceUnit = "yuanbao"
    local unitName = currency[priceUnit].name

    local itemNum, voucherPrice, voucherItem, voucher = getVoucherPrice(itemData, sellerItems[index].price, self.role2.baseId)
    local textList = {
        Text_tital = itemData.name,
        Text_type = itemData:getItemShowType(),
        Text_dsc = itemData.dsc,
        Text_price = "售价:" .. voucherPrice .. unitName,
        Text_affirm = "确定购买" .. itemData.name .. "吗？",
        Text_havenum = "已拥有:" .. User:getRole():getItemTotalCount(itemData.id) .. itemData.unit
    }

    PopupLayerController:showLayer(
        "ShoppingDialogLayer",
        function(layer)
            layer:showLayer(
                textList,
                function()
                end
            )
            layer:setButton_confirm(
                "确定",
                function()
                    TransCheck:setTransWithWebOrderId(
                        function(transId)
                            HttpManagerEx:buyChapmanItem(
                                self.role2.baseId,
                                itemData.id,
                                transId,
                                itemNum,
                                function(status, errcode, errmsg, data)
                                    if status == 200 then
                                        if errcode == 0 then
                                            TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
                                            local desc = "你购买了 " .. tostring(itemData.name)
                                            PopText(desc)

                                            -- 设置货币单位
                                            local priceUnit = self:getPriceUnit(sellerItems[index].priceUnit, itemData.priceUnit)
                                            currency[priceUnit].num = currency[priceUnit].num - tonumber(voucherPrice)

                                            -- 处理价格变动 价格单位也变动
                                            if sellerItems[index].is_buy_time ~= nil then
                                                sellerItems[index].is_buy_time = sellerItems[index].is_buy_time - 1
                                                if sellerItems[index].is_buy_time <= 0 and sellerItems[index].price2 ~= nil then
                                                    if sellerItems[index].price2 then
                                                        sellerItems[index].price = sellerItems[index].price2
                                                    end
                                                    if sellerItems[index].priceUnit2 then
                                                        sellerItems[index].priceUnit = sellerItems[index].priceUnit2
                                                    end
                                                end
                                            end

                                            -- 确认购买成功再放入玩家背包
                                            self:popItemByIndex(sellerItems, index)

                                            -- 先放入背包，避免玩家直接关闭游戏没有保存元宝购买的道具
                                            User:getRole():addItemCount(itemData.id, 1, nil, nil, "商人元宝购买")

                                            if
                                                itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or
                                                    itemData.type == "淬炼材料" or
                                                    itemData.type == "锻造材料"
                                             then
                                            else
                                                self:pushItem(roleItems, bgitemToBuy, weight, "")
                                            end

                                            self:setBagList(roleItems)
                                            self:setBagList2(sellerItems)
                                            self:refreshWeightUI()
                                            self:setTextMoney()
                                        else
                                            PopText(errmsg)
                                        end
                                        return true
                                    else
                                        PopText(errmsg)
                                    end
                                end,
                                IS_SHOW_WAITING,
                                HTTP_MANAGER_RETRY_TYPE_RETRY
                            )
                        end,
                        itemData.id,
                        1,
                        1
                    )
                end
            )
            layer:setButton_close(
                "取消",
                function()
                end
            )
        end
    )
end

-- -- 碎银购买，但要记录次数
function MapBagLayer:buyMoneyItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
    local price = sellerItems[index].price
    local priceUnit = "money"

    local unitName = currency[priceUnit].name

    local textList = {
        Text_tital = itemData.name,
        Text_type = itemData:getItemShowType(),
        Text_dsc = itemData.dsc,
        Text_price = "售价:" .. price .. unitName,
        Text_affirm = "确定购买" .. itemData.name .. "吗？",
        Text_havenum = "已拥有:" .. User:getRole():getItemTotalCount(itemData.id) .. itemData.unit
    }

    PopupLayerController:showLayer(
        "ShoppingDialogLayer",
        function(layer)
            layer:showLayer(
                textList,
                function()
                end
            )
            layer:setButton_confirm(
                "确定",
                function()
                    HttpManagerEx:addChapmanItemCount(
                        self.role2.baseId,
                        itemData.id,
                        function(status, errcode, errmsg, data)
                            if status == 200 then
                                if errcode == 0 then
                                    local desc = "你购买了 " .. tostring(itemData.name)
                                    PopText(desc)

                                    -- 设置货币单位
                                    local priceUnit = itemData.priceUnit
                                    if priceUnit == "" or priceUnit == nil then
                                        priceUnit = "money"
                                    end
                                    currency[priceUnit].num = currency[priceUnit].num - tonumber(price)

                                    User:getRole():addItemCount(itemData.id, 1, nil, nil, "商人碎银购买")

                                    if
                                        itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or itemData.type == "淬炼材料" or
                                            itemData.type == "锻造材料"
                                     then
                                    else
                                        self:pushItem(roleItems, bgitemToBuy, weight, "")
                                    end

                                    -- 处理价格变动 价格单位也变动
                                    if sellerItems[index].is_buy_time ~= nil then
                                        sellerItems[index].is_buy_time = sellerItems[index].is_buy_time - 1
                                        if sellerItems[index].is_buy_time <= 0 and sellerItems[index].price2 ~= nil then
                                            if sellerItems[index].price2 then
                                                sellerItems[index].price = sellerItems[index].price2
                                            end
                                            if sellerItems[index].priceUnit2 then
                                                sellerItems[index].priceUnit = sellerItems[index].priceUnit2
                                            end
                                        end
                                    end
                                    self:popItemByIndex(sellerItems, index)

                                    self:setBagList(roleItems)
                                    self:setBagList2(sellerItems)
                                    self:refreshWeightUI()
                                    self:setTextMoney()
                                else
                                    PopText(errmsg)
                                end
                                return true
                            else
                                PopText(errmsg)
                            end
                        end,
                        IS_SHOW_WAITING,
                        HTTP_MANAGER_RETRY_TYPE_RETRY
                    )
                end
            )
            layer:setButton_close(
                "取消",
                function()
                end
            )
        end
    )
end

-- 购买信物材料
function MapBagLayer:buyMeiYuItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
    local price = itemData.buyPrice
    local priceUnit = "meiyu"
    local unitName = currency[priceUnit].name

    local textList = {
        Text_tital = itemData.name,
        Text_type = itemData:getItemShowType(),
        Text_dsc = itemData.dsc,
        Text_price = "售价:" .. price .. unitName,
        Text_affirm = "确定购买" .. itemData.name .. "吗？",
        Text_havenum = "已拥有:" .. User:getRole():getItemTotalCount(itemData.id) .. itemData.unit
    }

    PopupLayerController:showLayer(
        "ShoppingDialogLayer",
        function(layer)
            layer:showLayer(
                textList,
                function()
                end
            )
            layer:setButton_confirm(
                "确定",
                function()
                    TransCheck:setTransWithWebOrderId(
                        function(transId)
                            HttpManagerEx:buyMaskPiece(
                                transId,
                                sellerItems[index].itemId,
                                function(status, errcode, errmsg, data)
                                    if status == 200 then
                                        if errcode == 0 then
                                            TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
                                            local desc = "你购买了 " .. tostring(itemData.name)
                                            PopText(desc)

                                            -- 确认购买成功再放入玩家背包
                                            self:popItemByIndex(sellerItems, index)

                                            -- 先放入背包，避免玩家直接关闭游戏没有保存元宝购买的道具
                                            User:getRole():addItemCount(itemData.id, 1, nil, nil, "商人美誉购买")

                                            if
                                                itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or
                                                    itemData.type == "淬炼材料" or
                                                    itemData.type == "锻造材料"
                                             then
                                            else
                                                self:pushItem(roleItems, bgitemToBuy, weight, "")
                                            end
                                            -- 设置货币单位
                                            local priceUnit = "meiyu"

                                            if priceUnit == "" or priceUnit == nil then
                                                priceUnit = "money"
                                            end

                                            currency[priceUnit].num = currency[priceUnit].num - tonumber(itemData.buyPrice)
                                            self:setBagList(roleItems)
                                            self:setBagList2(sellerItems)
                                            self:refreshWeightUI()
                                            self:setTextMoney()
                                        else
                                            PopText(errmsg)
                                        end
                                        return true
                                    else
                                        PopText(errmsg)
                                    end
                                end,
                                IS_SHOW_WAITING,
                                HTTP_MANAGER_RETRY_TYPE_RETRY
                            )
                        end,
                        itemData.id,
                        1,
                        5
                    )
                end
            )
            layer:setButton_close(
                "取消",
                function()
                end
            )
        end
    )
end

-- 购买冥币类道具 deadCurrency
function MapBagLayer:buyDeadCurrencyItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
    local price = sellerItems[index].price
    local priceUnit = "deadCurrency"
    local unitName = currency[priceUnit].name

    local textList = {
        Text_tital = itemData.name,
        Text_type = itemData:getItemShowType(),
        Text_dsc = itemData.dsc,
        Text_price = "售价:" .. price .. unitName,
        Text_affirm = "确定购买" .. itemData.name .. "吗？",
        Text_havenum = "已拥有:" .. User:getRole():getItemTotalCount(itemData.id) .. itemData.unit
    }

    PopupLayerController:showLayer(
        "ShoppingDialogLayer",
        function(layer)
            layer:showLayer(
                textList,
                function()
                end
            )
            layer:setButton_confirm(
                "确定",
                function()
                    TransCheck:setTransWithWebOrderId(
                        function(transId)
                            HttpManagerEx:buyDeadCurrencyGoods(
                                transId,
                                sellerItems[index].itemId,
                                function(status, errcode, errmsg, data)
                                    if status == 200 then
                                        if errcode == 0 then
                                            TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
                                            local desc = "你购买了 " .. tostring(itemData.name)
                                            PopText(desc)

                                            -- 确认购买成功再放入玩家背包
                                            if itemData.id == "item201_08" then
                                            else
                                                self:popItemByIndex(sellerItems, index)
                                            end

                                            -- 先放入背包，避免玩家直接关闭游戏没有保存元宝购买的道具
                                            User:getRole():addItemCount(itemData.id, 1, nil, nil, "商人冥币购买")

                                            if
                                                itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or
                                                    itemData.type == "淬炼材料" or
                                                    itemData.type == "锻造材料"
                                             then
                                            else
                                                self:pushItem(roleItems, bgitemToBuy, weight, "")
                                            end
                                            -- 设置货币单位
                                            local priceUnit = bagItem.priceUnit
                                            if priceUnit == nil then
                                                priceUnit = itemData.priceUnit
                                                if priceUnit == "" or priceUnit == nil then
                                                    priceUnit = "money"
                                                end
                                            end
                                            currency[priceUnit].num = currency[priceUnit].num - tonumber(price)
                                            self:setBagList(roleItems)
                                            self:setBagList2(sellerItems)
                                            self:refreshWeightUI()
                                            self:setTextMoney()
                                        else
                                            PopText(errmsg)
                                        end
                                        return true
                                    else
                                        PopText(errmsg)
                                    end
                                end,
                                IS_SHOW_WAITING,
                                HTTP_MANAGER_RETRY_TYPE_RETRY
                            )
                        end,
                        itemData.id,
                        1,
                        8
                    )
                end
            )
            layer:setButton_close(
                "取消",
                function()
                end
            )
        end
    )
end

-- -- 购买声望商人道具 货币 贡献点
function MapBagLayer:buyPrestigeItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
    local price = sellerItems[index].price
    local priceUnit = "gongxiandian"
    local unitName = currency[priceUnit].name
    local itemNum, voucherPrice, voucherItem, voucher = getVoucherPrice(itemData, sellerItems[index].price, self.role2.baseId)
    if self.isHaveTitle then
        voucherPrice = self.prestigeDiscount * voucherPrice
    end
    local textList = {
        Text_tital = itemData.name,
        Text_type = itemData:getItemShowType(),
        Text_dsc = itemData.dsc,
        Text_price = "售价:" .. voucherPrice .. unitName,
        Text_affirm = "确定购买" .. itemData.name .. "吗？",
        Text_havenum = "已拥有:" .. User:getRole():getItemTotalCount(itemData.id) .. itemData.unit
    }

    PopupLayerController:showLayer(
        "ShoppingDialogLayer",
        function(layer)
            layer:showLayer(
                textList,
                function()
                end
            )
            layer:setRichText("				RED需求师门声望不小于" .. itemData.prestige .. "NOR\n				  当前师门声望：" .. tostring(self.currPrestige))
            layer:setButton_confirm(
                "确定",
                function()
                    TransCheck:setTransWithWebOrderId(
                        function(transId)
                            HttpManagerEx:buyPrestigeGoods(
                                itemData.id,
                                transId,
                                self.role2.id,
                                function(status, errcode, errmsg, data)
                                    if status == 200 then
                                        if errcode == 0 then
                                            TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
                                            local desc = "你购买了 " .. tostring(itemData.name)
                                            PopText(desc)
                                            if self.isHaveTitle then
                                                PopText("由于你拥有唯一头衔，所有商品7.5折")
                                            end
                                            -- 设置货币单位
                                            local priceUnit = self:getPriceUnit(sellerItems[index].priceUnit, itemData.priceUnit)
                                            currency[priceUnit].num = currency[priceUnit].num - tonumber(voucherPrice)

                                            -- 确认购买成功再放入玩家背包
                                            self:popItemByIndex(sellerItems, index)

                                            -- 先放入背包，避免玩家直接关闭游戏没有保存元宝购买的道具
                                            User:getRole():addItemCount(itemData.id, 1, nil, nil, "商人声望购买")

                                            if
                                                itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or
                                                    itemData.type == "淬炼材料" or
                                                    itemData.type == "锻造材料"
                                             then
                                            else
                                                self:pushItem(roleItems, bgitemToBuy, weight, "")
                                            end

                                            self:setBagList(roleItems)
                                            self:setBagList2(sellerItems)
                                            self:refreshWeightUI()
                                            self:setTextMoney()
                                        else
                                            PopText(errmsg)
                                        end
                                        return true
                                    else
                                        PopText(errmsg)
                                    end
                                end,
                                IS_SHOW_WAITING,
                                HTTP_MANAGER_RETRY_TYPE_RETRY
                            )
                        end,
                        itemData.id,
                        1,
                        7
                    )
                end
            )
            layer:setButton_close(
                "取消",
                function()
                end
            )
        end
    )
end

function MapBagLayer:buyJiaoZiItem(itemData, sellerItems, roleItems, bgitemToBuy, bagItem, weight, index)
    local price = sellerItems[index].price
    local priceUnit = "jiaozi"
    local unitName = currency[priceUnit].name
    local itemNum, voucherPrice, voucherItem, voucher = getVoucherPrice(itemData, sellerItems[index].price, self.role2.baseId)

    local textList = {
        Text_tital = itemData.name,
        Text_type = itemData:getItemShowType(),
        Text_dsc = itemData.dsc,
        Text_price = "售价:" .. voucherPrice .. unitName,
        Text_affirm = "确定购买" .. itemData.name .. "吗？",
        Text_havenum = "已拥有:" .. User:getRole():getItemTotalCount(itemData.id) .. itemData.unit
    }

    PopupLayerController:showLayer(
        "ShoppingDialogLayer",
        function(layer)
            layer:showLayer(
                textList,
                function()
                end
            )
            layer:setButton_confirm(
                "确定",
                function()
                    TransCheck:setTransWithWebOrderId(
                        function(transId)
                            HttpManagerEx:buyJiaoZiGoods(
                                itemData.id,
                                transId,
                                self.role2.id,
                                function(status, errcode, errmsg, data)
                                    if status == 200 then
                                        if errcode == 0 then
                                            TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
                                            local desc = "你购买了 " .. tostring(itemData.name)
                                            PopText(desc)

                                            -- 设置货币单位
                                            local priceUnit = self:getPriceUnit(sellerItems[index].priceUnit, itemData.priceUnit)
                                            currency[priceUnit].num = currency[priceUnit].num - tonumber(voucherPrice)

                                            -- 确认购买成功再放入玩家背包
                                            self:popItemByIndex(sellerItems, index)

                                            -- 先放入背包，避免玩家直接关闭游戏没有保存元宝购买的道具
                                            User:getRole():addItemCount(itemData.id, 1, nil, nil, "商人游字令购买")

                                            if
                                                itemData.type == "书页" or itemData.type == "武学秘宝" or itemData.type == "毒药" or itemData.type == "制药材料" or itemData.type == "秘籍残页" or
                                                    itemData.type == "淬炼材料" or
                                                    itemData.type == "锻造材料"
                                             then
                                            else
                                                self:pushItem(roleItems, bgitemToBuy, weight, "")
                                            end

                                            self:setBagList(roleItems)
                                            self:setBagList2(sellerItems)
                                            self:refreshWeightUI()
                                            self:setTextMoney()
                                        else
                                            PopText(errmsg)
                                        end
                                        return true
                                    else
                                        PopText(errmsg)
                                    end
                                end,
                                IS_SHOW_WAITING,
                                HTTP_MANAGER_RETRY_TYPE_RETRY
                            )
                        end,
                        itemData.id,
                        1,
                        9
                    )
                end
            )
            layer:setButton_close(
                "取消",
                function()
                end
            )
        end
    )
end

function MapBagLayer:setCurrPrestigeInfo(prestige, title)
    self.currPrestige = prestige or 0
    self.isHaveTitle = title or false
    self.prestigeDiscount = 0.75
    print("---------self.isHaveTitle:", self.isHaveTitle)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/18 14:44:28
-- @desc 获取最终得到物品的列表及数量
function MapBagLayer:getMapItemIdAndCount(beforeItems, afterItems)
    beforeItems = Helper:getDef(beforeItems, {})
    afterItems = Helper:getDef(afterItems, {})
    local retMap = {}
    local function mergeItemCountToItemId(items)
        local retItems = {}
        for i, item in pairs(items) do
            if retItems[item.itemId] ~= nil then
                retItems[item.itemId] = retItems[item.itemId] + item.count
            else
                retItems[item.itemId] = item.count
            end
        end
        return retItems
    end

    beforeItems = mergeItemCountToItemId(beforeItems)
    afterItems = mergeItemCountToItemId(afterItems)

    local Record = require("app.models.Record.Record")
    local logData = {}
    local itemsFlag = {}
    for k, v in pairs(beforeItems) do
        if v ~= afterItems[k] then
            retMap[k] = Helper:getDef(afterItems[k], 0) - v
            Statistics:recordItemCount(k, retMap[k])
            logData[k] = retMap[k]
        end
        itemsFlag[k] = true
    end

    for k, v in pairs(afterItems) do
        if itemsFlag[k] ~= true then
            retMap[k] = v
            Statistics:recordItemCount(k, retMap[k])
            logData[k] = retMap[k]
        end
    end

    Record:addLog(Record.LOG_TYPE.ITEM, logData, "商人交易")
    return retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/08 17:18:08
-- @desc 将物品添加到指定角色身上. 判断物品类型,将其添加到指定列表
function MapBagLayer:addSpecialItemToRole(role, items)
    if MapIsEmpty(role) == true or MapIsEmpty(items) == true then
        return
    end
    local itemAttr, item
    for i = table.getn(items), 1, -1 do -- add by XiaoZhiWei 2017/04/08 17:26:36 必须使用倒序
        item = items[i]
        itemAttr = Item:getOneItemByKeyWithEncrypted(item.itemId)
        switch(
            itemAttr.type,
            {
                ["秘籍残页"] = function()
                    role:addItemCount(item.itemId, item.count)
                    table.remove(items, i)
                end
            }
        )
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 15:48:14
-- @desc 初始化后调用,创建防修改物品列表
function MapBagLayer:initSafeItem(items)
    for k, v in pairs(items) do
        items[k] = self:createSafeItem(v)
    end
end
-- Decorator:beforeAll(MapBagLayer, function(functionName, self)
-- 	print("functionName = "..functionName)
-- 	print("self.list2 = "..tostring(self.list2))
-- end)
-- Decorator:afterAll(MapBagLayer, function (functionName, self)
-- 	print("functionName = "..functionName)
-- 	print("self.list2 = "..tostring(self.list2))
-- end)
Helper:classDefNodeGetInstance(MapBagLayer)

return MapBagLayer
00000000000000