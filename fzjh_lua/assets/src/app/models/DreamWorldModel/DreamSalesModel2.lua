--[[
    梦境商人
]]
local DreamSalesModel2 = {}

local sales_item_res = require("script.dreamworld.dreamshop")["drptshop"]

local LIMIT_PREFIX = "drsold_"

local SELL_ITEM_TYPE = {
    NORMAL = 1,
    EQUIPS = 2,
    SKILL = 3,
    LIMITITEM = 4, --限定物品
    LIMITSKILL = 5 --限定武学
}

local SELLER_TYPE = {
    NORMAL = 1, 
    SPECIAL = 2 --购买成功，关闭商品列表，删除商人
}

function DreamSalesModel2:initSellerTypeAndItemType(map,seller,itemType,saleNum,salesType)
    self.itemType = itemType 
    self.itemMaxNum = saleNum --商品列表物品类型上限
    self.sellerType = salesType
    print("itemType = ",itemType,"saleNum = ",saleNum,"salesType = ",salesType)
end

--@desc: 初始化商品列表
function DreamSalesModel2:initSellerList(map,seller)
    if seller.dreamGoods == nil then
        seller.dreamGoods = {}
    else
        return
    end 

    --@desc 指定类型商品
    local itemType = self.itemType

    local player = map:getPlayer()
    local menpaiId = player:getFamilyId()
    local currFloor = player.dreamWorld.cFloor
    local clone_sales_list = clone(sales_item_res)
    local random_list = {}
    for k,v in pairs(clone_sales_list) do
        local dritemattr = v.dritemattr
        local drfloors = v.drfloors
        local minFloors = tonumber(string.split(drfloors,";")[1])
        local maxFloors = tonumber(string.split(drfloors,";")[2])
        if v.menpaiId == 0 or menpaiId == v.menpaiId then --@desc门派限制
            if dritemattr == itemType and (currFloor >= minFloors and currFloor <= maxFloors) then
                random_list[v.id] = v
            end
        end
    end

    --@desc 商品上限
    local itemMaxNum = self.itemMaxNum
    for i = 1, itemMaxNum do
        if MapIsEmpty(random_list) == false then
            local id = Helper:RandomByWeight(random_list, "drrand","id")
            local item_info = random_list[id]
            item_info.drcost = item_info.drcost * map:getPlayer():getFinalAttr("drSellItemMoneyAddPercent")
            table.insert(seller.dreamGoods, item_info)
            random_list[id] = nil
        else
            -- error(nil,"符合条件的商品不足3个")
            print("符合条件的商品不足"..itemMaxNum.."个")
            break
        end
    end

    if #seller.dreamGoods > 1 then
        table.sort(
            seller.dreamGoods,
            function(a, b)
                return tonumber(a.id) < tonumber(b.id)
            end
        )

        return true
    end

    return false
end

--@desc: 打开列表
--@author:Liang SongQiang
--@time:2019-09-29 18:31:51
--@map:[src.app.models.EMap.EMap#EMap]
--@seller: 梦境商人
function DreamSalesModel2:getSaleGoodsAndOpenLayer(map, seller,itemType,saleNum,salesType)
    self:initSellerTypeAndItemType(map, seller,itemType,saleNum,salesType)
    self:initSellerList(map,seller)

    local salesGoods = self:getSalesGoods(seller)
    local salesName = seller.name
    local sallerId = seller.id
    if MapIsEmpty(salesGoods) == false then
        PopupLayerController:showLayer(
            "DreamSalesLayer2",
            function(layer)
                layer:showLayer(map, salesGoods,salesName,sallerId)
            end
        )
    end
end

--@desc: 获取梦境商人销售列表
--@author:Liang SongQiang
--@time:2019-09-29 18:31:22
--@seller: 梦境商人
function DreamSalesModel2:getSalesGoods(seller)
    return seller.dreamGoods
end

--@desc 获取梦境商人类型
function DreamSalesModel2:getSellerType()
    return self.sellerType
end

--@desc: 购买物品
--@author:Liang SongQiang
--@time:2019-10-08 11:27:03
--@map:[src.app.models.EMap.EMap#EMap]
--@sellerItem: 商人售卖的物品
function DreamSalesModel2:buyItem(map, sellerItem, callback)
    callback = Helper:getDef(callback, EMPTY_FUNC)

    local limit_tag = LIMIT_PREFIX .. sellerItem.id

    local bought_count = map:getFlag(limit_tag)

    local item_type = sellerItem.dritemattr

    local info_list = {
        Text_tital = sellerItem.name,
        Text_type = nil,
        Text_dsc = sellerItem.dsc .. "\n \n" .. Helper:getDef(sellerItem.introduce, ""),
        Text_price = "售价:" .. sellerItem.drcost .. User:getRole():getCHAttrName("dreamPoints"),
        Text_affirm = "HIW确定购买" .. sellerItem.name .. "吗？NOR",
        Text_havenum = nil
    }

    local ok_func

    local player = map:getPlayer()
    if item_type == SELL_ITEM_TYPE.SKILL or item_type == SELL_ITEM_TYPE.LIMITSKILL then
        --@desc 技能

        local skill = Skill:getSkill(sellerItem.kfid)

        info_list.Text_type = "武学"

        local exp = player:getSkillExp(skill.id)
        if exp > 0 then
            info_list.Text_havenum = "已掌握"
        else
            info_list.Text_havenum = "未掌握"
        end

        ok_func = function()
            if bought_count >= sellerItem.drlimit then
                PopText("此商品已达购买次数。")
                return
            end
            
            local now_points = player:getAttr("dreamPoints")

            if now_points < sellerItem.drcost then
                PopText("碎银不足，无法购买")
                return
            end

            local skillLv = player:getSkillLv(skill.id)
            if skillLv >= 1000 then
                PopText("当前武学已达返璞归真境界，再购秘籍钻研也是无用。")
                return
            end

            User:getRole():getDreamSystem():addDreamSkillLevel(skill.id,player,sellerItem.kflv)
            local skillName = skill.name
            PopText("顿悟武道，"..skillName.."进境提升。")
            map:setFlag(limit_tag, bought_count + 1)
            player:addAttr("dreamPoints", -sellerItem.drcost)
            PopText("你消耗了" .. sellerItem.drcost .. User:getRole():getCHAttrName("dreamPoints"))
            callback()
        end
    elseif item_type == SELL_ITEM_TYPE.NORMAL or item_type == SELL_ITEM_TYPE.EQUIPS or item_type == SELL_ITEM_TYPE.LIMITITEM then
        local itemId = sellerItem.dritems

        info_list.Text_type = player:getOneItemByKey(itemId):getItemShowType()

        info_list.Text_havenum = "已拥有:" .. player:getItemTotalCount(itemId) .. sellerItem.unit

        --@desc 普通商品
        ok_func = function()
            if bought_count >= sellerItem.drlimit then
                PopText("此商品已达购买次数。")
                return
            end

            local now_points = player:getAttr("dreamPoints")

            if now_points < sellerItem.drcost then
                PopText("碎银不足，无法购买")
                return
            end

            if player:checkCanBuyTwoOrMoreThings({[itemId] = 1}, true) then
                player:addItemCount(itemId, 1)
                PopText("你获得了" .. info_list.Text_tital .. " X1")
                map:setFlag(limit_tag, bought_count + 1)
                player:addAttr("dreamPoints", -sellerItem.drcost)
                PopText("你消耗了" .. sellerItem.drcost .. User:getRole():getCHAttrName("dreamPoints"))
                callback()
            end
        end
    else
        PopText("商品类型错误。")

        return
    end

    return self:openShoppingDialog(info_list, ok_func,"确定")
end

--@desc: 出售物品
function DreamSalesModel2:saleItem(map, item, callback)    
    if item.priceUnit == "dreamPoints" and item.itemCanSale == 1 then
        local player = map:getPlayer()

        local info_list = {
            Text_tital = item.name,
            Text_type = player:getOneItemByKey(item.id):getItemShowType(),
            Text_dsc = item.dsc .. "\n \n" .. Helper:getDef(item.introduce, ""),
            Text_price = "售价:" .. item.salePrice .. User:getRole():getCHAttrName("dreamPoints"),
            Text_affirm = "HIW确定出售" .. item.name .. "吗？NOR",
            Text_havenum = "已拥有:" .. player:getItemTotalCount(item.id) .. item.unit
        }

        self:openShoppingDialog(info_list, function()
            player:addItemCount(item.id,-1)
    
            player:addAttr("dreamPoints", item.salePrice)
    
            PopText("你增加了" .. item.salePrice .. User:getRole():getCHAttrName("dreamPoints"))
    
            if callback then
                callback()
            end
        end,"出售")
    else
        PopText("该物品无法出售")
        return
    end
end

function DreamSalesModel2:openShoppingDialog(info_list, ok_func,buttonName)
    ok_func = Helper:getDef(ok_func, EMPTY_FUNC)
    buttonName = Helper:getDef(buttonName,"确定")
    PopupLayerController:showLayer(
        "ShoppingDialogLayer",
        function(layer)
            layer:showLayer(info_list, EMPTY_FUNC)
            layer:setButton_confirm(
                buttonName,
                function()
                    ok_func()
                end
            )
            layer:setButton_close("取消", EMPTY_FUNC)
        end
    )
end

return DreamSalesModel2
000000