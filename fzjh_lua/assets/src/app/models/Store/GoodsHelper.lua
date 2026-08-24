--[[
    author:Seven
    time:2024-04-12 16:01:23
    desc:
]]
local shoplistRes = require("res.script.store.shoplist")["Sheet1"]
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local LogSystem = require("app.models.LogSystem.LogSystem")

--@RefType [src.app.models.Store.Goods#Goods]
local Goods = require("app.models.Store.Goods")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local GOODS_TYPE = Goods.Const.TYPE

local GoodsHelper = {}

local cacheClass = {}

local PROCESS_TYPE = {
    [GOODS_TYPE.CLIENT_ITEM] = true,
    [GOODS_TYPE.CLIENT_SPECIAL_ITEM] = true,
    [GOODS_TYPE.CLIENT_ATTR] = true,
    [GOODS_TYPE.CLIENT_ROLE_TITLE] = true,
    [GOODS_TYPE.SERVER_UNLOCK_RES] = true
}

--@desc: 获取商品资源类
--@author:Seven
--@time:2024-04-12 16:28:28
--@id: 商品id
--@return [src.app.models.Store.Goods#Goods]
function GoodsHelper:getGoodsResClass(id)
    local index = tostring(id)
    if cacheClass[index] then
        return cacheClass[index]
    end

    local data = shoplistRes[index]

    if not data then
        error("GoodsHelper:getGoodsResClass() - 未找到商品信息 id : " .. index)
    end

    local goodClass = Goods:create(data)

    cacheClass[index] = goodClass

    return goodClass
end

--@desc: 服务器发放商品
--@author:LvBin
--@time:2024-04-13 17:42:40
--@grantObjiect: 获取商品的角色
--@grantGoodRequest:  [src.app.models.Store.GrantGoodRequest#GrantGoodRequest]
function GoodsHelper:fromNetworkGrantGoods(grantObjiect, grantGoodRequest)
    return self:__grantGoods(grantObjiect, grantGoodRequest)
end

function GoodsHelper:__clientListCheck(list)
    for i, goods_info in ipairs(list) do
        local goodClass = self:getGoodsResClass(goods_info.id)
        if goodClass:getItype() == Goods.Const.TYPE.CLIENT_SPECIAL_ITEM or PROCESS_TYPE[goodClass:getItype()] ~= true then
            error("客户端发放系统不允许发放特殊商品 ：" .. tostring(goods_info.id))
        end
    end
end

--@desc: 本地发放商品
--@author:LvBin
--@time:2024-04-13 17:42:40
--@grantObjiect: 获取商品的角色
--@grantGoodRequest:  [src.app.models.Store.GrantGoodRequest#GrantGoodRequest]
function GoodsHelper:fromClientGrantGoods(grantObjiect, grantGoodRequest)
    self:__clientListCheck(grantGoodRequest:getGoodsList())
    return self:__grantGoods(grantObjiect, grantGoodRequest)
end

--@desc: 发放奖励
--@author:Seven
--@time:2024-04-13 17:22:14
--@grantObjiect: 发放对象
--@goodRequest: [src.app.models.Store.GrantGoodRequest#GrantGoodRequest]
--@return: 待补充
function GoodsHelper:__grantGoods(grantObjiect, grantGoodRequest)
    local list = {}

    isImplement(grantGoodRequest, require("app.models.Store.GrantGoodRequest"))

    local goodslist = grantGoodRequest:getGoodsList()

    for i, goodsInfo in ipairs(goodslist) do
        local isOk, resultOrErrmsg = pcall(self.__grantGood, self, grantObjiect, goodsInfo.id, goodsInfo.num)

        if not isOk then
            print(string.format("GoodsHelper:__grantGoods() - error : { list:【%s】; index:【%s】, errmsg：【%s】}", table.tostring(goodslist), tostring(i), resultOrErrmsg))
            print(debug.traceback())
            break
        else
            table.insert(list, resultOrErrmsg)
        end
    end

    local dataVersion = grantGoodRequest:getDataVersion()

    if dataVersion ~= nil then
        grantObjiect:getServerActionSystem():setDataVersion(dataVersion)
    end

    local yashiExpiredTime = grantGoodRequest:getYashiExpiredTime()

    if yashiExpiredTime then
        grantObjiect:updateYaShiStatus(yashiExpiredTime)
    end

    local currencyVersion = grantGoodRequest:getCurrencyVersion()

    if currencyVersion then
        grantObjiect:setCurrencyVersion(currencyVersion)
    end

    return list
end

function GoodsHelper:__grantGood(grantObjiect, id, num)
    local goodClass = self:getGoodsResClass(id)

    local itype = goodClass:getItype()

    if not PROCESS_TYPE[itype] then
        return nil
    end

    return switch(
        itype,
        {
            [GOODS_TYPE.CLIENT_ITEM] = function()
                return self:__grantItem(grantObjiect, goodClass, num)
            end,
            [GOODS_TYPE.CLIENT_SPECIAL_ITEM] = function()
                return self:__grantSpecialItem(grantObjiect, goodClass, num)
            end,
            [GOODS_TYPE.CLIENT_ATTR] = function()
                return self:__grantAttr(grantObjiect, goodClass, num)
            end,
            [GOODS_TYPE.CLIENT_ROLE_TITLE] = function()
                return self:__grantRoleTitle(grantObjiect, goodClass, num)
            end,
            [GOODS_TYPE.SERVER_UNLOCK_RES] = function()
                return self:__grantUnlockItem(grantObjiect, goodClass, num)
            end
        }
    )
end

function GoodsHelper:__grantItem(grantObjiect, goodClass, num)
    local ItemId = goodClass:getItemId()
    grantObjiect:addItemCount(ItemId, num)

    return goodClass
end

function GoodsHelper:__grantSpecialItem(grantObjiect, goodClass, num)
    local ItemId = goodClass:getItemId()
    grantObjiect:addItemCount(ItemId, num)

    return goodClass
end

function GoodsHelper:__grantAttr(grantObjiect, goodClass, num)
    local attrName = goodClass:getItemId()
    grantObjiect:addAttr(attrName, num)

    return goodClass
end

function GoodsHelper:__grantRoleTitle(grantObjiect, goodClass, num)
    local id = goodClass:getItemId()

    assert(num == 1, "称号只能发放1个，商品id:" .. id)
    -- 只适用于新称号
    grantObjiect:addBasicTitle(id)

    return goodClass
end

function GoodsHelper:__grantUnlockItem(grantObjiect, goodClass, num)
    local id = goodClass:getItemId()

    if id == "jmskillpage" then
        grantObjiect:getMeridianSystem():unlockMeridianImprintingPage()
    end

    return goodClass
end

function GoodsHelper:checkRoleBagGoods(role, goodsList)
    local items = {}

    for i, v in ipairs(goodsList) do
        local goods = GoodsHelper:getGoodsResClass(v.id)

        if goods:getItype() == Goods.Const.TYPE.CLIENT_ITEM or goods:getItype() == Goods.Const.TYPE.CLIENT_SPECIAL_ITEM then
            local itemId = goods:getItemId()

            if items[itemId] then
                items[itemId] = tonumber(v.num) + items[itemId]
            else
                items[itemId] = tonumber(v.num)
            end
        end
    end

    return role:checkCanBuyTwoOrMoreThings(items, false)
end

local checkDuplicatePurchaseById = function(role, checkId)
    local DuplicatePurchaseCheckHelper = require("app.models.Store.DuplicatePurchaseCheck.DuplicatePurchaseCheckHelper")

    -- body
    return DuplicatePurchaseCheckHelper.checkDuplicate(checkId, role)
end

local checkDuplicatePurchaseByLogic = nil
checkDuplicatePurchaseByLogic = function(role, logicSymbol, tableCondition, depth)
    depth = depth + 1
    assert(depth <= 5, "GoodsHelper:checkDuplicatePurchaseByLogic() - 嵌套规则过深，大于5层，请检查规则")
    -- body
    if logicSymbol == "or" then
        for i, conditionIdOrTable in ipairs(tableCondition) do
            local result = false
            local searchInfo = {
                msg = nil,
                searchType = nil,
            }

            if type(conditionIdOrTable) == "number" then
                result, searchInfo = checkDuplicatePurchaseById(role, conditionIdOrTable)
            elseif type(conditionIdOrTable) == "table" then
                result, searchInfo = checkDuplicatePurchaseByLogic(role, conditionIdOrTable[1], conditionIdOrTable[2], depth)
            else
                error("GoodsHelper:checkDuplicatePurchaseByLogic() - 不支持的参数类型 : " .. tostring(type(conditionIdOrTable)))
            end
            if result then
                return true, searchInfo
            end
        end

        return false
    elseif logicSymbol == "and" then
        local msg = nil
        local searchInfo = {
            msg = nil,
            searchType = nil,
        }
        for i, conditionIdOrTable in ipairs(tableCondition) do
            local result = false
            if type(conditionIdOrTable) == "number" then
                result, searchInfo = checkDuplicatePurchaseById(role, conditionIdOrTable)
            elseif type(conditionIdOrTable) == "table" then
                result, searchInfo = checkDuplicatePurchaseByLogic(role, conditionIdOrTable[1], conditionIdOrTable[2], depth)
            else
                error("GoodsHelper:checkDuplicatePurchaseByLogic() - 不支持的参数类型 : " .. tostring(type(conditionIdOrTable)))
            end
            if not result then
                return false 
            end
        end
        return true , searchInfo
    else
        error("GoodsHelper:checkDuplicatePurchaseByLogic() - 不支持的逻辑符号 : " .. tostring(logicSymbol))
    end

    return false
end

--[[
 返回数据：
    result true|false,
    searchInfo：{
        msg:检索提示语,
        searchType:检索类型
    }
]]
function GoodsHelper:checkDuplicatePurchase(role, goodsId)
    LogSystem:log(string.format("商品重复购买检测 ：开始检测 - 商品ID:【%s】", tostring(goodsId)))

    local goodClass = self:getGoodsResClass(goodsId)

    local searchCondition = goodClass:getSearchcondition()

    if MapIsEmpty(searchCondition) then
        return false
    end

    local arg1 = searchCondition[1]
    if type(arg1) == "number" then
        return checkDuplicatePurchaseById(role, arg1)
    end

    local logicSymbol = arg1

    local tableCondition = searchCondition[2]

    local depth = 0

    local msg = nil

    local result, searchInfo = checkDuplicatePurchaseByLogic(role, logicSymbol, tableCondition, depth)
    LogSystem:log(string.format("商品重复购买检测 ：结束检测 - 商品ID:【%s】, 检测结果:【%s】", tostring(goodsId), tostring(result)))

    return result, searchInfo
end

return GoodsHelper
00