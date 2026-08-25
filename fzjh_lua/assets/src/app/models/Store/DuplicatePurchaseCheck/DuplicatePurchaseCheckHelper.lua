local goodsSearchResource = require("script.store.goodsSearch")["Sheet1"]

local lru = require("third.cache.lru")

local GoodsSearchResourceClass = {}

function GoodsSearchResourceClass:create(id)
    id = tonumber(id) or error("GoodsSearchResourceClass:create() - id is nil or not number， id is "..tostring(id))
    local p = setmetatable({}, {__index = GoodsSearchResourceClass})
    p:__init(goodsSearchResource[id] or error("GoodsSearchResourceClass:create() - id is not exist in goodsSearchResource， id is "..tostring(id)))
    return p
end

function GoodsSearchResourceClass:__init(res)
    self.__res = res
end
function GoodsSearchResourceClass:getId()
    return self.__res.id
end
function GoodsSearchResourceClass:getSearchtype()
    return self.__res.searchtype
end
function GoodsSearchResourceClass:getSearchvalue()
    return self.__res.searchvalue
end
function GoodsSearchResourceClass:getJudgingcondition()
    return self.__res.Judgingcondition
end
function GoodsSearchResourceClass:getJudgingvalue()
    return self.__res.Judgingvalue
end

local DuplicatePurchaseCheckResourceMgr = {
    __cache = lru.new(30)
}

function DuplicatePurchaseCheckResourceMgr:getResource(id)
    id = tostring(id) ~= "nil" and tostring(id) or error("DuplicatePurchaseCheckResourceMgr:getResource() - id is nil")

    if self.__cache:get(id) then
        return self.__cache:get(id)
    end

    local res_class = GoodsSearchResourceClass:create(id)
    self.__cache:set(id, res_class)
    return res_class
end

--@desc: 获取商品重复检索条件资源类
--@author:Seven
--@time:2025-09-18 14:31:41
--@id: 重复检索条件id
--@return [src.app.models.Store.DuplicatePurchaseCheck.DuplicatePurchaseCheckHelper#GoodsSearchResourceClass]
local function getResource(id)
    return DuplicatePurchaseCheckResourceMgr:getResource(id)
end

local DuplicatePurchaseCheckHelper = {}

function DuplicatePurchaseCheckHelper.checkDuplicate(id, role)
    local res = getResource(id)
    local checkType = res:getSearchtype()
    --@RefType [src.app.models.Store.DuplicatePurchaseCheck.ADuplicatePurchaseCheck#ADuplicatePurchaseCheck]
    local checkClass = require("app.models.Store.DuplicatePurchaseCheck.DuplicatePurchaseCheck" .. tostring(checkType))

    local result, msg = checkClass:duplicateCheck(role, res)

    local searchInfo = {
        hitResults = {},
        hitCount = 0
    }

    if result then
        table.insert(
            searchInfo.hitResults,
            {
                -- 检索条件表 id，用于追踪命中的配置来源。
                searchId = res:getId(),
                -- 当前命中的条件 id；基础条件与 searchId 一致，组合逻辑中用于保留子条件来源。
                conditionId = res:getId(),
                -- 检索类型，如 101/201/301，用于结果展示分类。
                searchType = tostring(checkType),
                -- 当前命中条件的 2.0 提示文本。
                msg = msg
            }
        )
        searchInfo.hitCount = 1
    end

    return result, searchInfo
end

return DuplicatePurchaseCheckHelper
0000000