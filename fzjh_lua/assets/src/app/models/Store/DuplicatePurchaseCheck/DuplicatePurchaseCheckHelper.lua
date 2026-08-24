local goodsSearchResource = require("script.store.goodsSearch")["Sheet1"]

local lru = require("third.cache.lru")

local GoodsSearchResourceClass = {}

function GoodsSearchResourceClass:create(id)
    id = tonumber(id) or error("GoodsSearchResourceClass:create() - id is nil or not number")
    local p = setmetatable({}, {__index = GoodsSearchResourceClass})
    p:__init(goodsSearchResource[id] or error("GoodsSearchResourceClass:create() - id is not exist in goodsSearchResource"))
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

    local resutl, msg = checkClass:duplicateCheck(role, res)

    local searchInfo = {
        searchType = checkType,
        msg = msg
    }

    return resutl, searchInfo
end

return DuplicatePurchaseCheckHelper
000000