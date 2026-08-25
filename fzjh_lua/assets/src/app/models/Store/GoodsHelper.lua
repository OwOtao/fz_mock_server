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

local DUPLICATE_PURCHASE_FLOW_TYPE = {
    BLOCK = "block",
    CONTINUE = "continue"
}

GoodsHelper.DUPLICATE_PURCHASE_FLOW_TYPE = DUPLICATE_PURCHASE_FLOW_TYPE

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

--[[
    重复购买检索结果 searchInfo 字段说明：
    {
        goodsResults = {
            {
                goodsId = 命中商品 id,
                goodsName = 命中商品名称,
                itemId = 商品关联的物品/资源 id,
                hitResults = {
                    {
                        searchId = 检索条件表 id,
                        conditionId = 本次命中的条件 id,
                        searchType = 检索类型，如 101/201/301,
                        msg = 单条命中条件的提示文本
                    }
                },
                hitCount = 当前商品命中的条件数量
            }
        },
        goodsHitCount = 命中的商品数量,
        goodsCheckCount = 实际检测过的商品数量,
        needDetailResult = 是否需要展示 2.0 详情结果,
        canDirectPopText = 是否可以直接弹出唯一命中文案
    }
]]
local createDuplicateSearchInfo = function()
    return {
        -- 命中的商品结果列表；单商品和批量检测都使用该结构。
        goodsResults = {},
        -- 命中的商品数量。
        goodsHitCount = 0,
        -- 实际参与检测的商品数量。
        goodsCheckCount = 0,
        -- true 表示命中结果较复杂，需要走 2.0 详情展示。
        needDetailResult = false,
        -- true 表示只有一个简单命中；阻止流程可直接弹出 goodsResults[1].hitResults[1].msg。
        canDirectPopText = false
    }
end

local createConditionSearchInfo = function()
    return {
        hitResults = {},
        hitCount = 0
    }
end

local getHitCountByGoodsResults = function(goodsResults)
    local hitCount = 0

    if MapIsEmpty(goodsResults) then
        return hitCount
    end

    for _, goodsSearchInfo in ipairs(goodsResults) do
        hitCount = hitCount + (tonumber(goodsSearchInfo.hitCount) or 0)
    end

    return hitCount
end

local refreshDuplicateSearchInfoState = function(searchInfo)
    if searchInfo == nil then
        return nil
    end

    local hitCount = getHitCountByGoodsResults(searchInfo.goodsResults)
    local goodsCheckCount = tonumber(searchInfo.goodsCheckCount)

    if goodsCheckCount == nil then
        goodsCheckCount = 0
    end

    local goodsHitCount = tonumber(searchInfo.goodsHitCount)

    if goodsHitCount == nil then
        goodsHitCount = searchInfo.goodsResults ~= nil and #searchInfo.goodsResults or 0
    end

    searchInfo.goodsCheckCount = goodsCheckCount
    searchInfo.goodsHitCount = goodsHitCount

    searchInfo.needDetailResult = hitCount > 0 and (hitCount > 1 or goodsCheckCount > 1 or goodsHitCount > 1)
    searchInfo.canDirectPopText = hitCount == 1 and goodsCheckCount <= 1 and goodsHitCount <= 1

    return searchInfo
end

local appendConditionSearchInfo = function(target, source)
    if source == nil then
        return
    end

    local hitResults = source.hitResults

    if MapIsEmpty(hitResults) then
        return
    end

    for _, hitInfo in ipairs(hitResults) do
        table.insert(target.hitResults, hitInfo)
    end

    target.hitCount = #target.hitResults
end

local createGoodsDuplicateSearchInfo = function(searchInfo, goodsClass)
    if searchInfo == nil or goodsClass == nil or MapIsEmpty(searchInfo.hitResults) then
        return nil
    end

    local goodsSearchInfo = {
        goodsId = goodsClass:getId(),
        goodsName = goodsClass:getName(),
        itemId = goodsClass:getItemId(),
        hitResults = {},
        hitCount = 0
    }

    for _, hitInfo in ipairs(searchInfo.hitResults) do
        table.insert(
            goodsSearchInfo.hitResults,
            {
                searchId = hitInfo.searchId,
                conditionId = hitInfo.conditionId,
                searchType = hitInfo.searchType,
                msg = hitInfo.msg,
                goodsId = goodsSearchInfo.goodsId,
                goodsName = goodsSearchInfo.goodsName,
                itemId = goodsSearchInfo.itemId
            }
        )
    end

    goodsSearchInfo.hitCount = #goodsSearchInfo.hitResults

    return goodsSearchInfo
end

local appendGoodsDuplicateSearchInfo = function(target, goodsSearchInfo)
    if goodsSearchInfo == nil or MapIsEmpty(goodsSearchInfo.hitResults) then
        return
    end

    table.insert(target.goodsResults, goodsSearchInfo)
    target.goodsHitCount = #target.goodsResults
    refreshDuplicateSearchInfoState(target)
end

local getFirstDuplicatePurchaseHitInfo = function(searchInfo)
    if searchInfo == nil or MapIsEmpty(searchInfo.goodsResults) then
        return nil, nil
    end

    local goodsSearchInfo = searchInfo.goodsResults[1]

    if goodsSearchInfo == nil or MapIsEmpty(goodsSearchInfo.hitResults) then
        return nil, goodsSearchInfo
    end

    return goodsSearchInfo.hitResults[1], goodsSearchInfo
end

local getGoodsIdFromGoodsInfo = function(goodsInfo)
    if type(goodsInfo) == "table" then
        return goodsInfo.id or goodsInfo.goodsId
    end

    return goodsInfo
end

local isDuplicatePurchaseFlowType = function(flowType)
    return flowType == DUPLICATE_PURCHASE_FLOW_TYPE.BLOCK or flowType == DUPLICATE_PURCHASE_FLOW_TYPE.CONTINUE
end

local checkDuplicatePurchaseByLogic = nil
checkDuplicatePurchaseByLogic = function(role, logicSymbol, tableCondition, depth)
    depth = depth + 1
    assert(depth <= 5, "GoodsHelper:checkDuplicatePurchaseByLogic() - 嵌套规则过深，大于5层，请检查规则")
    -- body
    if logicSymbol == "or" then
        local searchInfo = createConditionSearchInfo()

        for i, conditionIdOrTable in ipairs(tableCondition) do
            local result = false
            local _searchInfo = nil

            if type(conditionIdOrTable) == "number" then
                result, _searchInfo = checkDuplicatePurchaseById(role, conditionIdOrTable)
            elseif type(conditionIdOrTable) == "table" then
                result, _searchInfo = checkDuplicatePurchaseByLogic(role, conditionIdOrTable[1], conditionIdOrTable[2], depth)
            else
                error("GoodsHelper:checkDuplicatePurchaseByLogic() - 不支持的参数类型 : " .. tostring(type(conditionIdOrTable)))
            end
            if result then
                appendConditionSearchInfo(searchInfo, _searchInfo)
            end
        end

        return searchInfo.hitCount > 0, searchInfo
    elseif logicSymbol == "and" then
        local searchInfo = createConditionSearchInfo()

        for i, conditionIdOrTable in ipairs(tableCondition) do
            local result = false
            local _searchInfo = nil

            if type(conditionIdOrTable) == "number" then
                result, _searchInfo = checkDuplicatePurchaseById(role, conditionIdOrTable)
            elseif type(conditionIdOrTable) == "table" then
                result, _searchInfo = checkDuplicatePurchaseByLogic(role, conditionIdOrTable[1], conditionIdOrTable[2], depth)
            else
                error("GoodsHelper:checkDuplicatePurchaseByLogic() - 不支持的参数类型 : " .. tostring(type(conditionIdOrTable)))
            end
            if not result then
                return false, createConditionSearchInfo()
            end

            appendConditionSearchInfo(searchInfo, _searchInfo)
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
    searchInfo: 结构见 createDuplicateSearchInfo 上方字段说明
]]
function GoodsHelper:checkDuplicatePurchase(role, goodsId)
    LogSystem:log(string.format("商品重复购买检测 ：开始检测 - 商品ID:【%s】", tostring(goodsId)))

    local goodClass = self:getGoodsResClass(goodsId)

    local searchCondition = goodClass:getSearchcondition()

    local searchInfo = createDuplicateSearchInfo()
    searchInfo.goodsCheckCount = 1

    if MapIsEmpty(searchCondition) then
        return false, searchInfo
    end

    local arg1 = searchCondition[1]
    if type(arg1) == "number" then
        local result, conditionSearchInfo = checkDuplicatePurchaseById(role, arg1)

        if result == true then
            appendGoodsDuplicateSearchInfo(searchInfo, createGoodsDuplicateSearchInfo(conditionSearchInfo, goodClass))
        end

        return result, refreshDuplicateSearchInfoState(searchInfo)
    end

    local logicSymbol = arg1

    local tableCondition = searchCondition[2]

    local depth = 0

    local result, conditionSearchInfo = checkDuplicatePurchaseByLogic(role, logicSymbol, tableCondition, depth)
    LogSystem:log(string.format("商品重复购买检测 ：结束检测 - 商品ID:【%s】, 检测结果:【%s】", tostring(goodsId), tostring(result)))

    if result == true then
        appendGoodsDuplicateSearchInfo(searchInfo, createGoodsDuplicateSearchInfo(conditionSearchInfo, goodClass))
    end

    return result, refreshDuplicateSearchInfoState(searchInfo)
end

--@desc: 批量检测商品重复购买，并保留每个命中商品的独立检索结果
--@goodsList: { { id = 商品id, num = 数量 }, ... } 或 { 商品id, ... }
--@return: bool, searchInfo
function GoodsHelper:checkDuplicatePurchaseList(role, goodsList)
    local searchInfo = createDuplicateSearchInfo()

    if MapIsEmpty(goodsList) then
        return false, searchInfo
    end

    for _, goodsInfo in ipairs(goodsList) do
        local goodsId = getGoodsIdFromGoodsInfo(goodsInfo)

        if goodsId ~= nil then
            searchInfo.goodsCheckCount = searchInfo.goodsCheckCount + 1

            local result, goodsSearchInfo = self:checkDuplicatePurchase(role, goodsId)

            if result == true then
                for _, goodsResult in ipairs(goodsSearchInfo.goodsResults) do
                    appendGoodsDuplicateSearchInfo(searchInfo, goodsResult)
                end
            end
        end
    end

    return searchInfo.goodsHitCount > 0, refreshDuplicateSearchInfoState(searchInfo)
end

--@desc: 统一处理重复购买检索结果的 UI 入口
--@searchInfo: checkDuplicatePurchase/checkDuplicatePurchaseList 返回的 searchInfo
--@params: {
--  flowType = "block" | "continue", -- 必填：阻止后续流程/继续后续流程
--  onBack = function() end, -- 可选：详情页返回后的回调
--  onConfirm = function() end -- 可选：继续流程详情页确认后的回调
--}
--@return: handled, handleType
function GoodsHelper:handleDuplicatePurchaseSearchInfo(searchInfo, params)
    assert(params ~= nil, "GoodsHelper:handleDuplicatePurchaseSearchInfo() - params is nil")
    assert(isDuplicatePurchaseFlowType(params.flowType), "GoodsHelper:handleDuplicatePurchaseSearchInfo() - unsupported flowType : " .. tostring(params.flowType))
    assert(params.onBack == nil or type(params.onBack) == "function", "GoodsHelper:handleDuplicatePurchaseSearchInfo() - onBack must be function")
    assert(params.onConfirm == nil or type(params.onConfirm) == "function", "GoodsHelper:handleDuplicatePurchaseSearchInfo() - onConfirm must be function")

    searchInfo = refreshDuplicateSearchInfoState(searchInfo)

    if searchInfo == nil or searchInfo.goodsHitCount <= 0 then
        return false, "none"
    end

    local hitInfo = getFirstDuplicatePurchaseHitInfo(searchInfo)

    if params.flowType == DUPLICATE_PURCHASE_FLOW_TYPE.BLOCK and searchInfo.canDirectPopText == true and hitInfo ~= nil then
        assert(hitInfo.msg ~= nil, "GoodsHelper:handleDuplicatePurchaseSearchInfo() - hitInfo.msg is nil")
        PopText(hitInfo.msg)

        return true, "directPopText"
    end

    return true, "detail", self:showDuplicatePurchaseDetail(searchInfo, params)
end

--@desc: 展示重复购买检索详情 UI
function GoodsHelper:showDuplicatePurchaseDetail(searchInfo, params)
    assert(params ~= nil, "GoodsHelper:showDuplicatePurchaseDetail() - params is nil")
    assert(isDuplicatePurchaseFlowType(params.flowType), "GoodsHelper:showDuplicatePurchaseDetail() - unsupported flowType : " .. tostring(params.flowType))
    assert(params.onBack == nil or type(params.onBack) == "function", "GoodsHelper:showDuplicatePurchaseDetail() - onBack must be function")
    assert(params.onConfirm == nil or type(params.onConfirm) == "function", "GoodsHelper:showDuplicatePurchaseDetail() - onConfirm must be function")

    PopupLayerController:showLayer(
        "GoodsDuplicatePurchasePresenter",
        function(layer)
            layer:showLayer(
                {
                    searchInfo = searchInfo,
                    flowType = params.flowType,
                    onBack = params.onBack,
                    onConfirm = params.onConfirm
                }
            )
        end
    )
end

return GoodsHelper
0000000000