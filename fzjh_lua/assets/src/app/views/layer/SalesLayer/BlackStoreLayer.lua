--[[
    黑市商人界面逻辑

    售卖货币只有：元宝和碎银,

    不支持批量出售
    
    不支持购买数量限制
]]
local BlackStoreLayer = class("BlackStoreLayer", LayerEx)

local dis_img_path = {
    ["0.9"] = "Image/UI/StoreUI/jiuzhe.png",
    ["0.8"] = "Image/UI/StoreUI/bazhe.png",
    ["0.6"] = "Image/UI/StoreUI/liuzhe.png",
    default = "Image/UI/StoreUI/jiuzhe.png"
}

--@desc 不需要进入背包的物品，直接进入药囊、书箱等。。。
local not_cache_item_type = {
    ["书页"] = true,
    ["武学秘宝"] = true,
    ["毒药"] = true,
    ["制药材料"] = true,
    ["秘籍残页"] = true,
    ["淬炼材料"] = true,
    ["锻造材料"] = true
}

local moneyGoodsPrice = {}

function BlackStoreLayer:create()
    local p = BlackStoreLayer:new()
    p:init()
    return p
end

function BlackStoreLayer:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]
    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    local button1 = Resource:getUIByName("Button_4")
    Helper:convertUIByParent(button1)
    button1.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    self:addChild(button1)
    button1:move(cc.p(810, 200))
    button1.Text_buttonName:setString("确定")

    button1:releaseFunc(
        function()
            self:hideLayer()

            if MapIsEmpty(self._leftSoldList) == false then
                for i, v in ipairs(self._leftSoldList) do
                    --@desc 此处理论只会存在碎银物品
                    if v.priceUnit == "money" then
                        self._leftRole:addItemCount(v.itemId, -1)
                        self._leftRole:setAttr("money", math.max(0, self._leftRole:getNumAttr("money") + v.price))
                    end
                end
            end

            if MapIsEmpty(self._rightSoldList) == false then
                for i, v in ipairs(self._rightSoldList) do
                    if v.priceUnit == "money" then
                        self._leftRole:addItemCount(v.itemId, 1)
                        self._leftRole:setAttr("money", math.max(0, self._leftRole:getNumAttr("money") - v.price))
                    end
                end
            end


            self._confirmCallback()

            -- if PRINT_MODE == 1 then
            print("-------------- 玩家售出列表（碎银物品） -----------------")
            Helper:print_lua_table(self._leftSoldList)
            print("--------------------------------------------\n")

            print("-------------- 玩家购买列表 -----------------")
            Helper:print_lua_table(self._rightSoldList)
            print("--------------------------------------------\n")
            -- end
        end
    )

    self.btnRight = button1

    self.Text_money:setVisible(true)
end

--@desc 碎银数量显示
function BlackStoreLayer:refeshMoney()
    self.Text_money:setString(tostring("碎银： " .. tostring(math.floor(self._curr_money))))
end

--@desc 背包数量
function BlackStoreLayer:refreshWeight()
    self._curr_weight = #self.leftItems
    self._max_weight = self._leftRole:getNumAttr("weight")
    self.Text_weight:setString((self._curr_weight) .. "/" .. tostring(self._max_weight))
end

--@desc: 进入界面，设置左右两边列表绑定的玩家。并初始化列表
--@author:Liang SongQiang
--@time:2019-07-27 14:29:02
--@leftRole:[src.app.models.role.Role#Role]
--@rightRole: [src.app.models.role.Role#Role]
function BlackStoreLayer:showLayer(leftRole, rightRole,confirmCallback)

    self._confirmCallback = Helper:getDef(confirmCallback,EMPTY_FUNC)

    --@desc 玩家已卖出的物品，等于商人赎回的物品
    self._leftSoldList = {}

    --@desc 商人已卖出的物品，等于玩家已购买的物品
    self._rightSoldList = {}

    self.leftItems = {}

    self.rightItems = {}

    self._rightRole = rightRole

    self._leftRole = leftRole

    self._curr_money = leftRole:getAttr("money")

    -- print("----------------------------")
    -- Helper:print_lua_table(self.rightItems)
    -- print("----------------------------\n")

    -- print("----------------------------")
    -- Helper:print_lua_table(self.leftItems)
    -- print("----------------------------\n")

    local left_role_items = self._leftRole:getItems()

    if MapIsEmpty(left_role_items) == false then
        for i, roleItem in ipairs(left_role_items) do
            local itemAttr = self._leftRole:getOneItemByKey(roleItem.itemId)
            local left_item = {
                id = roleItem.id,
                itemId = roleItem.itemId,
                count = roleItem.count,
                name = itemAttr.name,
                price = nil,
                priceUnit = nil
            }

            if itemAttr.wpType == "神兵" then
                left_item.wpType = "神兵"
            end

            table.insert(self.leftItems, left_item)
        end
    end

    local right_role_items = self._rightRole.blackMarket
    if MapIsEmpty(right_role_items) == false then
        for i, roleItem in ipairs(right_role_items) do
            local itemAttr = self._rightRole:getOneItemByKey(roleItem.itemId)
            local right_item = {
                id = roleItem.id,
                itemId = roleItem.itemId,
                count = roleItem.count,
                name = itemAttr.name,
                price = roleItem.price,
                priceUnit = roleItem.priceUnit,
                discount = roleItem.discount
            }

            if right_item.priceUnit == "yuanbao" and self._leftRole:isHaveImprintingId("fuhuiyin") then
                local Meridian = require("app.models.Meridian.Meridian")
                local meridianBuffValue = Meridian:getMeridianBuffValue("fuhuiyin")
                right_item.price = math.ceil(right_item.price * meridianBuffValue)
            end

            if right_item.priceUnit == "money" then
                moneyGoodsPrice[right_item.itemId] = right_item.price
            end

            table.insert(self.rightItems, right_item)
        end
    end

    moneyGoodsPrice = TableProxy:createEncryptedTableRecursive(moneyGoodsPrice)

    self:initLeftList()

    self:initRightList()

    self:refeshMoney()

    self:refreshWeight()

    self:show()
end

function BlackStoreLayer:hideLayer()
    PopupLayerController:hideLayer(
        "BlackStoreLayer",
        function(layer)
            layer:hide()
        end
    )
end

function BlackStoreLayer:initRightList()
    if MapIsEmpty(self.rightItems) == true then
        self.ListView_2:removeAllItems()
        return
    end

    for index, sellerItem in ipairs(self.rightItems) do
        local panel_row = self.ListView_2:getItem(index - 1)
        if panel_row == nil then
            panel_row = self.Panel_item2:clone()
            Helper:convertUIByParent(panel_row)
            self.ListView_2:pushBackCustomItem(panel_row)
        end

        panel_row:setVisible(true)
        panel_row.Text_name:setColor(cc.c3b(208, 208, 208)) --设置颜色
        local outlineColor = cc.c4b(24, 24, 24, 255)
        local outlineWidth = 5
        panel_row.Text_name:enableOutline(outlineColor, outlineWidth)
        panel_row.Text_num:enableOutline(outlineColor, outlineWidth)

        --@region 打折显示
        if sellerItem.discount ~= nil then
            local img_path = switch(tostring(sellerItem.discount), dis_img_path)
            panel_row.Image_DaZhe:loadTexture(img_path, 0)
            panel_row.Image_DaZhe:setVisible(true)
        else
            panel_row.Image_DaZhe:setVisible(false)
        end
        --@endregion

        panel_row.Text_name:setString(tostring(sellerItem.name))

        panel_row.Text_num:setString(tostring(math.abs(sellerItem.price)) .. self._rightRole:getCHAttrName(sellerItem.priceUnit))

        panel_row:releaseFunc(
            function()
                self:clickRightItem(sellerItem)
            end
        )
    end

    local listCount = #self.ListView_2:getItems()
    if listCount - #self.rightItems > 0 then
        for i = listCount - 1, #self.rightItems, -1 do
            self.ListView_2:removeItem(i)
        end
    end
end

--@desc: 初始化左边列表
--@author:Liang SongQiang
--@time:2019-07-27 16:21:28
function BlackStoreLayer:initLeftList()
    if MapIsEmpty(self.leftItems) == true then
        self.ListView_1:removeAllItems()
        return
    end

    local listItemCount = 0
    for index, roleItem in ipairs(self.leftItems) do
        --@region 列表UI初始化设置
        local panel_row = self.ListView_1:getItem(listItemCount)
        if panel_row == nil then
            panel_row = self.Panel_item1:clone()
            Helper:convertUIByParent(panel_row)
            self.ListView_1:pushBackCustomItem(panel_row)
        end
        panel_row:setVisible(true)
        panel_row.Text_name:setColor(cc.c3b(208, 208, 208))
        --设置默认颜色
        local outlineColor = cc.c4b(24, 24, 24, 255)
        local outlineWidth = 5
        panel_row.Text_name:enableOutline(outlineColor, outlineWidth)
        --@endregion

        if roleItem ~= nil then
            listItemCount = listItemCount + 1

            if roleItem.wpType == "神兵" then
                panel_row.Text_name:setString(roleItem.name)
            else
                panel_row.Text_name:setString(tostring(roleItem.name) .. " X " .. tostring(roleItem.count))
            end

            panel_row:releaseFunc(
                function()
                    self:clickLeftItem(roleItem)
                end
            )
        else
            if PRINT_MODE == 1 then
                print("item is not found of itemId : " .. roleItem.itemId)
            end
        end
    end

    local listCount = #self.ListView_1:getItems()
    if listCount - listItemCount > 0 then
        for i = listCount - 1, listItemCount, -1 do
            self.ListView_1:removeItem(i)
        end
    end
end

--@desc:检查物品是否可以出售
--@author:Liang SongQiang
--@time:2019-07-29 14:11:25
function BlackStoreLayer:checkCanSellItem(role, roleItem)
    local can_sell, msg = true, ""
    local itemAttr = role:getOneItemByKey(roleItem.itemId)

    if itemAttr.itemCanSale ~= 1 and itemAttr.itemCanSale ~= true then
        can_sell = false
        msg = itemAttr.name .. "不能出售!"
        return can_sell, msg
    end

    if role:checkItemIsEquip(roleItem.id) == true then
        can_sell = false
        msg = "装备中的物品无法出售"
        return can_sell, msg
    end

    if role:checkIsPrepareWeapon(roleItem.id) == true then
        can_sell = false
        msg = "准备中的武器无法出售"
        return can_sell, msg
    end

    if itemAttr.id == "guanfugongwen" then
        can_sell = false
        msg = tostring(itemAttr.name) .. "不能出售!"
        return can_sell, msg
    end

    if itemAttr.priceUnit == "yuanbao" then
        can_sell = false
        msg = "此物太过珍贵,不能出售!"
        return can_sell, msg
    end

    if itemAttr.wpType == "神兵" then
        can_sell = false
        msg = "神兵不能出售!"
        return can_sell, msg
    end

    return true
end

--@desc: 点击左边列表的panel逻辑（出售物品）
--@author:Liang SongQiang
--@time:2019-07-27 16:05:43
function BlackStoreLayer:clickLeftItem(roleItem)
    --@region 判断是否哦可以出售
    local can_drop, msg = self:checkCanSellItem(self._leftRole, roleItem)
    if can_drop == false then
        PopText(msg)
        return
    end
    --@endregion

    --@region 售出 ，先检查是不是从对方手里买来的，如果是，移出售出列表
    local isRestore = false
    local restoreItem
    if MapIsEmpty(self._rightSoldList) == false then
        for _, soldItem in ipairs(self._rightSoldList) do
            if soldItem.itemId == roleItem.itemId then
                isRestore = true
                restoreItem = soldItem
                break
            end
        end
    end
    --@endregion

    --@region 检查左边列表是否有相同的物品
    local same_item = nil
    if MapIsEmpty(self.rightItems) == false then
        for _, rightItem in ipairs(self.rightItems) do
            if rightItem.itemId == roleItem.itemId then
                same_item = rightItem
                break
            end
        end
    end

    if isRestore == true then
        --@desc 退还操作。
        local itemAttr = self._leftRole:getOneItemByKey(restoreItem.itemId)
        if itemAttr.priceUnit == "yuanbao" then
            assert(false, "元宝物品不应该能出现在该步骤，请检查代码")
        end

        --退还价格：如果使用用元宝购买的，用策划配置表中价格出售
        local sell_price = 0

        if restoreItem.priceUnit == "yuanbao" or restoreItem.priceUnit == nil then
            --@desc 配置表中的出售价格
            sell_price = Helper:getDef(tonumber(itemAttr.salePrice), 0)
        else
            sell_price = Helper:getDef(tonumber(restoreItem.price), 0)
        end

        --@desc 归还后清除购买记录
        local index = table.indexof(self._rightSoldList, restoreItem)
        table.remove(self._rightSoldList, index)

        --@region 更新右边列表
        if same_item == nil then
            local right_item = {
                id = roleItem.id,
                itemId = roleItem.itemId,
                count = 1,
                name = roleItem.name,
                price = sell_price,
                priceUnit = "money"
            }
            table.insert(self.rightItems, right_item)
        else
            same_item.count = same_item.count + 1
        end
        self:initRightList()
        --@endregion

        --@region 更新左边列表
        roleItem.count = roleItem.count - 1
        if roleItem.count <= 0 then
            local roleItem_index = table.indexof(self.leftItems, roleItem)
            table.remove(self.leftItems, roleItem_index)
        end
        self:initLeftList()
        --@endregion

        --@desc 刷新当前金币数
        self._curr_money = self._curr_money + sell_price
        PopText("您退还了一" .. itemAttr.unit .. itemAttr.name .. "收回了" .. tostring(sell_price) .. "碎银")
        self:refeshMoney()
        self:refreshWeight()
        --@endregion
    else
        --@desc 正常出售
        local itemAttr = self._leftRole:getOneItemByKey(roleItem.itemId)
        if itemAttr.priceUnit == "yuanbao" then
            assert(false, "元宝物品不应该能出现在该步骤，请检查代码")
        end

        local sell_price = Helper:getDef(tonumber(itemAttr.salePrice), 0)

        --@desc 卖出物品的数据结构
        local sell_item = {
            id = roleItem.id,
            itemId = roleItem.itemId,
            price = sell_price,
            priceUnit = "money"
        }

        table.insert(self._leftSoldList, sell_item)

        --@region 更新右边列表
        if same_item == nil then
            local right_item = {
                id = roleItem.id,
                itemId = roleItem.itemId,
                count = 1,
                name = roleItem.name,
                price = sell_price,
                priceUnit = "money"
            }
            table.insert(self.rightItems, right_item)
        else
            same_item.count = same_item.count + 1
        end
        self:initRightList()
        --@endregion

        --@region 更新左边列表
        roleItem.count = roleItem.count - 1
        if roleItem.count <= 0 then
            local roleItem_index = table.indexof(self.leftItems, roleItem)
            table.remove(self.leftItems, roleItem_index)
        -- self.ListView_1:removeItem(roleItem_index - 1)
        end
        self:initLeftList()
        --@endregion

        --@region 刷新货币及背包容量
        self._curr_money = self._curr_money + sell_price
        PopText("您出售了一" .. tostring(itemAttr.unit) .. tostring(itemAttr.name) .. "获得了" .. tostring(sell_price) .. "碎银")
        self:refeshMoney()
        self:refreshWeight()
    end
end

--@desc: 右边物品点击
--@author:Liang SongQiang
--@time:2019-07-29 16:51:34
function BlackStoreLayer:clickRightItem(sellerItem)
    if PRINT_MODE == 1 then
        print("-------- click Seller Item ---------")
        Helper:print_lua_table(sellerItem)
        print("------------------------------------\n")
    end

    local itemAttr = self._rightRole:getOneItemByKey(sellerItem.itemId)

    --@region 检查左边列表是否可以加入(背包满时不可加入)
    local same_item = nil
    if MapIsEmpty(self.leftItems) == false then
        for _, leftItem in ipairs(self.leftItems) do
            if leftItem.itemId == sellerItem.itemId and leftItem.count < 99 then
                same_item = leftItem
                break
            end
        end
    end

    --@desc 是否需要新建数据结构插入
    local need_create = true
    if same_item ~= nil and itemAttr.canFold == ITEM_STATE_TRUE then
        need_create = false
    else
        if self._leftRole:checkIsNoLimitItem(sellerItem.itemId) == false and #self.leftItems + 1 > self._leftRole:getNumAttr("weight") then
            PopText("背包容量已达上限，无法购买。")
            return
        end
    end
    --@endregion

    --@desc 购买，需先判断是否玩家出售的道具，如果是，执行赎回操作
    local isRepurchase = false
    local repurchaseItem
    if MapIsEmpty(self._leftSoldList) == false then
        for i, soldItem in ipairs(self._leftSoldList) do
            if soldItem.itemId == sellerItem.itemId then
                repurchaseItem = soldItem
                break
            end
        end
    end

    if repurchaseItem ~= nil then
        --@region 赎回流程
        local itemAttr = self._rightRole:getOneItemByKey(sellerItem.itemId)

        -- 赎回流程，并且无需加入商人售出列表
        local buy_price = repurchaseItem.price

        --@desc 应该只有碎银物品才能赎回。
        local priceUnit = repurchaseItem.priceUnit

        if priceUnit ~= "money" then
            assert(false, "目前只支持碎银物品的赎回，请检查。")
        end

        if self._curr_money < buy_price then
            PopText("碎银不足")
            return
        end

        if need_create == true then
            --@desc 如果没有相同物品数据，则创建数据结构
            local left_item = {
                id = self._leftRole:getItemOnlyId(),
                itemId = sellerItem.itemId,
                count = 1,
                name = sellerItem.name,
                price = nil,
                priceUnit = nil
            }

            --@desc 添加到左边列表
            table.insert(self.leftItems, left_item)
        else
            if same_item == nil then
                assert(false, "same_item 此处不应该为nil，检查代码")
            end

            same_item.count = same_item.count + 1
        end
        self:initLeftList()

        --@region 清理左边玩家出售记录
        local repurchaseItem_index = table.indexof(self._leftSoldList,repurchaseItem)
        table.remove( self._leftSoldList,repurchaseItem_index)
        --@endregion

        sellerItem.count = sellerItem.count - 1
        if sellerItem.count <= 0 then
            --@desc 右边列表数量低于1，则删除
            local index = table.indexof(self.rightItems, sellerItem)
            table.remove(self.rightItems, index)
        end
        self:initRightList()

        --@desc 刷新当前金币数
        self._curr_money = self._curr_money - buy_price
        PopText("你赎回一" .. tostring(itemAttr.unit) .. tostring(itemAttr.name) .. "花费了" .. tostring(math.abs(buy_price)) .. "碎银")
        self:refeshMoney()
        self:refreshWeight()
    else
        local itemAttr = self._rightRole:getOneItemByKey(sellerItem.itemId)

        --@desc 正常购买流程
        local buy_price = sellerItem.price

        local priceUnit = Helper:getDef(sellerItem.priceUnit, "money")

        if priceUnit == "money" then
            if moneyGoodsPrice[sellerItem.itemId] then
                buy_price = moneyGoodsPrice[sellerItem.itemId]
            end

            local textList = {
                Text_tital = itemAttr.name,
                Text_type = itemAttr:getItemShowType(),
                Text_dsc = itemAttr.dsc,
                Text_price = "售价:" .. buy_price .. self._rightRole:getCHAttrName(priceUnit),
                Text_affirm = "确定购买" .. itemAttr.name .. "吗？",
                Text_havenum = "已拥有:" .. self._leftRole:getItemTotalCount(itemAttr.id) .. itemAttr.unit
            }
            PopupLayerController:showLayer(
                "ShoppingDialogLayer",
                function(layer)
                    layer:showLayer(textList, EMPTY_FUNC)
                    layer:setButton_confirm(
                        "确定",
                        function()
                            --@desc 购买确定

                            --@desc 碎银购买流程
                            if self._curr_money < buy_price then
                                PopText("碎银不足")
                                return
                            end

                            if not_cache_item_type[itemAttr.type] == true then
                                --@desc 不需要进入背包的物品无需加入已售列表，所以碎银应该及时结算。
                                self._leftRole:addItemCount(itemAttr.id, 1)
                                self._leftRole:setAttr("money", math.max(0, self._leftRole:getNumAttr("money") - buy_price))
                            else
                                --@region 加入商人已售列表
                                --@desc 商人售出物品的数据结构
                                local bought_item = {
                                    id = sellerItem.id,
                                    itemId = sellerItem.itemId,
                                    price = buy_price,
                                    priceUnit = "money"
                                }

                                table.insert(self._rightSoldList, bought_item)
                                --@endregion

                                --@region 左边列表刷新
                                if need_create == true then
                                    local buy_item = {
                                        id = self._leftRole:getItemOnlyId(),
                                        itemId = sellerItem.itemId,
                                        count = 1,
                                        name = sellerItem.name,
                                        price = nil,
                                        priceUnit = nil
                                    }

                                    table.insert(self.leftItems, buy_item)
                                else
                                    if same_item == nil then
                                        assert(false, "same_item 此处不应该为nil，检查代码")
                                    end

                                    same_item.count = same_item.count + 1
                                end
                            end
                            self:initLeftList()

                            sellerItem.count = sellerItem.count - 1
                            if sellerItem.count <= 0 then
                                --@desc 右边列表数量低于1，则删除
                                local index = table.indexof(self.rightItems, sellerItem)
                                table.remove(self.rightItems, index)
                            end
                            self:initRightList()

                            --@desc 刷新当前金币数
                            self._curr_money = math.ceil(self._curr_money - buy_price)

                            PopText("你购买一" .. tostring(itemAttr.unit) .. tostring(itemAttr.name) .. "花费了" .. tostring(math.abs(buy_price)) .. "碎银")

                            self:refeshMoney()
                            self:refreshWeight()
                        end
                    )
                    layer:setButton_close("取消", EMPTY_FUNC)
                end
            )
        elseif priceUnit == "yuanbao" then
            --@desc 元宝购买流程，无需加

            local isDiscount = self._leftRole:isHaveImprintingId("fuhuiyin")

            local isFreeSingle = self._leftRole:isHaveImprintingId("fulingyin")

            PopYuanBaoBuyItemLayer(
                itemAttr.id,
                function(eventType)
                    if eventType == "success" then
                        self._leftRole:addItemCount(itemAttr.id, 1)

                        if not_cache_item_type[itemAttr.type] == true then
                        else
                            --@endregion
                            --@region 左边列表刷新
                            if need_create == true then
                                local buy_item = {
                                    id = self._leftRole:getItemOnlyId(),
                                    itemId = sellerItem.itemId,
                                    count = 1,
                                    name = sellerItem.name,
                                    price = nil,
                                    priceUnit = nil
                                }

                                table.insert(self.leftItems, buy_item)
                            else
                                if same_item == nil then
                                    assert(false, "same_item 此处不应该为nil，检查代码")
                                end

                                same_item.count = same_item.count + 1
                            end
                            self:initLeftList()
                        end

                        sellerItem.count = sellerItem.count - 1
                        if sellerItem.count <= 0 then
                            --@desc 右边列表数量低于1，则删除
                            local index = table.indexof(self.rightItems, sellerItem)
                            table.remove(self.rightItems, index)
                        end
                        self:initRightList()

                        local desc = "你购买了 " .. tostring(itemAttr.name)
                        PopText(desc)

                        self:refeshMoney()
                        self:refreshWeight()
                    end
                end,
                {mark = {isDiscount = isDiscount, isFreeSingle = isFreeSingle}}
            )
        end
    end
end

Helper:classDefNodeGetInstance(BlackStoreLayer)
return BlackStoreLayer
00000000000000