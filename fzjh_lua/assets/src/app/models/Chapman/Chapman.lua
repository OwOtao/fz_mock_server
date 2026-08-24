local User = require("app.models.user.User")

local Role = require("app.models.role.Role")

-- 特殊商人 商品列表从服务器获取
local Chapman = {}

local ChapmanMap = require("script.others.storechap.lua")["Sheet1"]
-- local ChapmanMap = {}

-- 检测是否由服务器获取商品列表
function Chapman:checkIsChapman(npcId)
	if MapIsEmpty(ChapmanMap) then
		return false
	end

	for i,v in pairs(ChapmanMap) do
		if v.npcId == npcId and v.isnew ~= 1 then
			return true
		end
	end
	return false
end

function Chapman:checkIsChapmanForNew(npcId)
	if MapIsEmpty(ChapmanMap) then
		return false
	end

	for i,v in pairs(ChapmanMap) do
		if v.npcId == npcId and v.isnew == 1 then
			return true
		end
	end
	return false
end

-- 检测是否冥币商人
function Chapman:checkIsDeadCurrency(npcId)
	-- npc201_65 npc01_28
	if string.find(npcId, "npc201_65") ~= nil or string.find(npcId, "zjsr") ~= nil then
		return true
	end
	return false
end

-- 获取冥币商人交易商品列表
function Chapman:getDeadCurrencyList(role, observerLayer, callBackFunc)
	TransCheck:checkAllUrlTrans()
    local list = {}
    role.blackMarket = {}
    -- 获取商人列表
    HttpManagerEx:getDeadCurrencyGoodsList(function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
            	PopText(errmsg)
            else
                if data and data.status == "OPEN" then
                    local items = data.list
                    role.items = {}
                    for k,v in pairs(items) do
                        print("冥币商人添加道具 " .. v.itemId)
                        -- 添加至商人
                        table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 1 , itemId = v.itemId, price = v.price, priceUnit = "deadCurrency"} )
                    end
                    local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
                    local layer = MapBagLayer:getInstance()
                    layer:show()
                    layer:setRoles(User:getRole(), role, function()
                    	local currMap = User:getRole():getCurrMap()
                        -- 刷新房间条件结果
                        currMap:doRoomConditionAndResult(observerLayer.mapLayer._currRoom.id)
                    end)
                    layer:setTextDeadCurrency(data.count)
                    layer:setNpcCanSale(false)
                    observerLayer:hide(true)
                    if callBackFunc then
                        callBackFunc()
                    end
                end
            end
        end
    end, IS_SHOW_WAITING)
end

-- 醉梦生商人
function Chapman:getChapmanList(role)
    TransCheck:checkAllUrlTrans()
    local list = {}
    role.blackMarket = {}
    -- 获取商人列表
    local baseId = role.saleId or role.baseId
    HttpManagerEx:getChapmanItemList(baseId, function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
                print(errmsg)
            else
                if data then
                    local items = data.list
                    role.items = {}
                    for k,v in pairs(items) do
                        print("商人添加道具 " .. v.itemId)
                        -- 添加至商人
                        -- table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = v.time , itemId = v.itemId, price = v.price} )
                        -- 购买一定次数后 价格变动
                        if v.is_buy_time <= 0 then
                            if v.price2 then
                                v.price = v.price2
                            end

                            if v.priceUnit2 then
                                v.priceUnit = v.priceUnit2
                            end
                        end

                        -- 可无限购买的道具
                        if v.is_buy == "Y" then
                            v.count = 999
                        end
                        table.insert( role.blackMarket , v )
                    end
                    local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
                    local layer = MapBagLayer:getInstance()
                    layer:show()
                    layer:setRoles(User:getRole(), role, function()
                        local currMap = User:getRole():getCurrMap()
                        -- 刷新房间条件结果
                        currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                    end)
                    layer:setTextYuanBao(data.yuanbao)
                    -- observerLayer:hide(true)
                    layer:setNpcCanSale(false)
                    -- if callBackFunc then
                    --     callBackFunc()
                    -- end
                end
            end
        end
    end, IS_SHOW_WAITING)
end

function Chapman:testBlackChapman(role)
    TransCheck:checkAllUrlTrans()
    role.blackMarket = {}
    -- 获取黑市商人列表
    HttpManagerEx:getMarketStoreList(function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
            else
                if data.status == "OPEN" and data.list then
                    local items = data.list
                    role.items = {}
                    for k,v in pairs(items) do
		    	--@desc 预防数据库返回 xxx = false 的情况
                        if type(v) ~= "boolean" and v then
                            local item = Item:getOneItemByKey(v.itemId)
                            if item then
                                print(item.id)
                                print("黑市商人添加道具 " .. item.name)
                                -- 添加至黑市商人
                                table.insert(
                                    role.blackMarket,
                                    {
                                        id = User:getRole():getItemOnlyId(),
                                        count = 1,
                                        itemId = v.itemId,
                                        name = item.name,
                                        price = v.price,
                                        priceUnit = v.priceUnit,
                                        discount = v.discount,
                                    }
                                )
                            end
                        else
                            if DEBUG_MODE == 1 then
                                print("服务器无物品")
                            end
                        end
                    end
                    PopupLayerController:showLayer("BlackStoreLayer",function (layer)
                        layer:showLayer(User:getRole(),role)
                    end)
                end
            end
        end
    end, IS_SHOW_WAITING)
end

function Chapman:testChapman(role)
    TransCheck:checkAllUrlTrans()
    local list = {}
    role.blackMarket = {}
    -- 获取商人列表
    HttpManagerEx:getChapmanItemList(role.baseId, function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
            else
                if data then
                    local items = data.list
                    role.items = {}
                    for k,v in pairs(items) do
                        print("商人添加道具 " .. v.itemId)
                        -- 添加至商人
                        if v.is_buy_time <= 0 then
                            if v.price2 then
                                v.price = v.price2
                            end

                            if v.priceUnit2 then
                                v.priceUnit = v.priceUnit2
                            end
                        end
                        if v.is_buy == "Y" then
                            v.count = 999
                        end
                        table.insert( role.blackMarket , v )
                        --table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = v.time, itemId = v.itemId, price = v.price} )
                    end
                    local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
                    local layer = MapBagLayer:getInstance()
                    layer:show()
                    layer:setRoles(User:getRole(), role, function()end)
                    layer:setTextYuanBao(data.yuanbao)
                    layer:setNpcCanSale(false)
                end
            end
        end
    end, IS_SHOW_WAITING)
end

function Chapman:testDeadCurrency(role)
    TransCheck:checkAllUrlTrans()
    local list = {}
    role.blackMarket = {}
    -- 获取商人列表
    HttpManagerEx:getDeadCurrencyGoodsList(function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
                PopText(errmsg)
            else
                if data and data.status == "OPEN" then
                    local items = data.list
                    role.items = {}
                    for k,v in pairs(items) do
                        print("冥币商人添加道具 " .. v.itemId)
                        -- 添加至商人
                        table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 1 , itemId = v.itemId, price = v.price, priceUnit = "deadCurrency"} )
                    end
                    local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
                    local layer = MapBagLayer:getInstance()
                    layer:show()
                    layer:setRoles(User:getRole(), role, function()
                    end)
                    layer:setTextDeadCurrency(data.count)
                    layer:setNpcCanSale(false)
                end
            end
        end
    end, IS_SHOW_WAITING)
end

-- 新的npc商人  （所有用 币种 购买 都走订单流程）
function Chapman:getNpcChapman(role)
    TransCheck:checkAllUrlTrans()
    local list = {}
    role.blackMarket = {}
    -- 获取npc商人列表
    HttpManagerEx:getNewNpcChapmanItemList(role.baseId, function(status, errcode, errmsg, data, isEncrypted)
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
                    role.items = {}
                    -- Helper:print_lua_table(data)
                    for k,v in pairs(items) do
                        print("商人添加道具 " .. v.itemId,v.unit)
                        -- 添加至商人
                     
                       
                        -- table.insert( role.blackMarket , v )
                        table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 999 , itemId = v.itemId, price = v.price, priceUnit = v.unit } )
                        -- table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 1 , itemId = v.itemId, price = v.price, priceUnit = "deadCurrency"} )
                    end
                    role.canSale =1
                    
                    local MapBagLayer = require("app.views.layer.MapLayer.NpcMapBagLayer")
                    local layer = MapBagLayer:getInstance()
                    layer:show()
                    layer:setRoles(User:getRole(), role, function()
                        -- if observerLayer ~= nil then
                            local currMap = User:getRole():getCurrMap()
                            -- 刷新房间条件结果
                            currMap:doRoomConditionAndResult(currMap:getCurrRoomId())
                        -- end
                    end)
                    
                    -- 根据返回货币类型，设置商店显示货币
                    layer:setTextMoney(Helper:getDef(data.point, User:getRoleAttr("money")), Helper:getDef(data.unit, "money"))

                    -- if observerLayer ~= nil then
                    --     observerLayer:hide(true)
                    -- end
                    -- if callBackFunc then
                    --     callBackFunc()
                    -- end

                    layer:setNpcCanSale(false)
                end
            end
        end
    end, IS_SHOW_WAITING)
end

-- 新npc商人测试
function Chapman:testNpcChapman(role)
    TransCheck:checkAllUrlTrans()
    local list = {}
    role.blackMarket = {}
    -- 获取npc商人列表
    HttpManagerEx:getNewNpcChapmanItemList(role.baseId, function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode ~= 0 then
            else
                if data then
                    local items = data.list
                    role.items = {}
                    Helper:print_lua_table(data)
                    for k,v in pairs(items) do
                        print("商人添加道具 " .. v.itemId,v.unit)
                        -- 添加至商人
                     
                       
                        -- table.insert( role.blackMarket , v )
                        table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 999 , itemId = v.itemId, price = v.price, priceUnit = v.unit } )
                        -- table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 1 , itemId = v.itemId, price = v.price, priceUnit = "deadCurrency"} )
                    end
                    role.canSale =1
                    
                    local MapBagLayer = require("app.views.layer.MapLayer.NpcMapBagLayer")
                    local layer = MapBagLayer:getInstance()
                    layer:show()
                    layer:setRoles(User:getRole(), role, function()end)
                    layer:setTextMoney(Helper:getDef(data.point, User:getRoleAttr("money")), Helper:getDef(data.unit, "money"))
                    
                    -- local type = data.unit
                    -- if type then
                    --     if  type == "yuanbao" then
                    --         layer:setTextYuanBao(data.point)
                    --     elseif  type == "meiyu" then
                    --         layer:setTextMeiYu(data.points)
                    --     elseif  type == "mingbi" or  type == "deadCurrency" then
                    --         layer:setTextDeadCurrency(data.point)
                    --     end
                    -- end
                  

                    layer:setNpcCanSale(false)
                end
            end
        end
    end, IS_SHOW_WAITING)
end


function Chapman:checkIsCkChapman(role)
    local baseId = role.baseId

    local config = {
        yzguizinpc = true
    }

    if config[baseId] == true then
        return true
    end
    
    return false
end

function Chapman:getCkChapmanStoreList(role)
    TransCheck:checkAllUrlTrans()
    local list = {}
    -- 获取npc商人列表
    HttpManagerEx:getStorageBox(role.baseId, function(status, errcode, errmsg, data, isEncrypted)
        -- PopText("返回数据 是否有加密  == "..tostring(isEncrypted))
        if isEncrypted == false then
            Collection:memoryCheat(User:getRoleAttr("userid"), "proxyData", 0, data)
            return
        end
        if status == 200 then
            if errcode == 0 then
                Helper:print_lua_table(data)

                --@RefType [src.app.models.Chapman.CkChapman#CkChapman]
                local CkChapman = require("app.models.Chapman.CkChapman")
                CkChapman:setNpcId(role.baseId)
                CkChapman:setNowBoxList(data.storage)
                CkChapman:setNowPoint(data.point)
                CkChapman:setSellerItems(data.list)
                CkChapman:setSellerUnit(data.unit)

                PopupLayerController:showLayer("ChuWuXiangSalesLayer",function (layer)
                    layer:showLayer(CkChapman)
                end)
            else
                PopText(errmsg)
            end
        end
    end, IS_SHOW_WAITING)
end

--检查是否为声望商人
function Chapman:checkIsPrestigeChapman(role)
    if string.find(role.id, "shengwang") then 
        return true
    end
    return false
end
--获取声望商人列表
function Chapman:getPrestigeChapmanStoreList(role)
    local player=User:getRole()
    local prestigeChapmanFamily=role.menpai
    print("role.menpai:",role.menpai,"player.menpai:",player:getFamilyId(),"role.id:",role.id)
    local playerFamily= player:getFamilyId()
    if prestigeChapmanFamily==playerFamily or DEBUG_MODE==1 then 
    else
        PopText("不是本门弟子，不能交易")
        return false
    end
    TransCheck:checkAllUrlTrans()
    role.blackMarket = {}
    -- 获取npc商人列表
    local is_refresh = "N"
    HttpManagerEx:getPrestigeGoods(role.id,is_refresh,function(status, errcode, errmsg, data, isEncrypted)
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
                    role.items = {}
                    -- Helper:print_lua_table(data)
                    for k,v in pairs(items) do
                        print("商人添加道具 " .. v.itemId,v.unit)
                        -- 添加至商人
                     
                       
                        -- table.insert( role.blackMarket , v )
                        table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 999 , itemId = v.itemId, price = v.price, prestige=v.needSw, priceUnit = v.unit } )
                        -- table.insert( role.blackMarket , { id = User:getRole():getItemOnlyId() , count = 1 , itemId = v.itemId, price = v.price, priceUnit = "deadCurrency"} )
                    end
                    role.canSale =1
                    local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
                    local layer = MapBagLayer:getInstance()
                    layer:show()
                    layer:setCurrPrestigeInfo(data.shengwang,data.title)
                    layer:setRoles(User:getRole(), role, function()
                        layer:setCurrPrestigeInfo() --清空声望商人相关信息
                    end)
                    
                    -- 根据返回货币类型，设置商店显示货币
                    layer:setTextGongXianDian(Helper:getDef(data.point, User:getRoleAttr("money")), Helper:getDef(data.unit, "money"))

                    -- if observerLayer ~= nil then
                    --     observerLayer:hide(true)
                    -- end
                    -- if callBackFunc then
                    --     callBackFunc()
                    -- end
                    local nextRemove = data.next_yuanbao --刷新所需元宝数量
                    print("刷新需 ",nextRemove)
                    layer:setNextRefreshPrice(nextRemove)
                    layer.Text_desc:setVisible(true)
					layer.Text_desc:setString("花费"..nextRemove.."元宝立即刷新")
                    
                    layer:setNpcCanSale(false)
                end
            end
        end
    end, IS_SHOW_WAITING)
end

return Chapman000000000