local newclass = require("third.class.NewClass")

local currencyRes = require("script.others.monetarymanagement").Sheet1

local CurrencyResClass = {}

function CurrencyResClass:create(...)
    return CurrencyResClass.new():__init(...)
end
function CurrencyResClass:__init(res)
    self.__res = res
    return self
end

function CurrencyResClass:getCurrencyId()
    return self.__res.currencyId
end
function CurrencyResClass:getName()
    return self.__res.name
end
function CurrencyResClass:getDesc()
    return self.__res.desc
end
function CurrencyResClass:getIcon()
    return self.__res.icon
end
function CurrencyResClass:getTotalLimit()
    return self.__res.totalLimit
end
function CurrencyResClass:getTimeLimit()
    return self.__res.timeLimit
end
function CurrencyResClass:getLimitType()
    return self.__res.limitType
end
function CurrencyResClass:getLimitDay()
    return self.__res.limitDay
end
function CurrencyResClass:getFirstrefresh()
    return self.__res.firstrefresh
end
function CurrencyResClass:getReset()
    return self.__res.reset
end
function CurrencyResClass:getInherit()
    return self.__res.inherit
end
function CurrencyResClass:isTimeClear()
    return self.__res.time ~= "1"
end
function CurrencyResClass:getTimeClearText()
    if self.__res.time == "1" then
        return ""
    end
    return Helper:getTimeStrToCN(self.__res.time)
end
function CurrencyResClass:getBindType()
    return self.__res.bindType
end
function CurrencyResClass:getCurrencytype()
    return self.__res.currencytype
end
function CurrencyResClass:getDataback()
    return self.__res.databack
end

CurrencyResClass = newclass("CurrencyResClass", {}, CurrencyResClass)

local lru = require("third.cache.lru")
local CurrencyUtil = {
    __lruCache = nil
}

CurrencyUtil.__lruCache = lru.new(5)

function CurrencyUtil:getCurrencyResClass(currencyId)
    assert(currencyId, "CurrencyUtil:getCurrencyResClass currencyId is null")
    local resClass = self.__lruCache:get(currencyId)
    if resClass == nil then
        local res = currencyRes[currencyId]
        assert(res, "CurrencyUtil:getCurrencyResClass currencyId is not found, currencyId:" .. tostring(currencyId))
        resClass = CurrencyResClass:create(res)
        self.__lruCache:set(currencyId, resClass)
    end

    return resClass
end

function CurrencyUtil:isCurrencyId(currencyId)
    assert(currencyId, "CurrencyUtil:isCurrencyId currencyId is null")
    return currencyRes[currencyId] ~= nil
end

function CurrencyUtil:getCurrencyDesc(currencyId)
    assert(currencyId, "CurrencyUtil:getCurrencyDesc currencyId is null")
    if currencyRes[currencyId] then
        return currencyRes[currencyId].desc
    end
    assert(false, "CurrencyUtil:getCurrencyDesc currencyId is not found, currencyId:" .. tostring(currencyId))
end

function CurrencyUtil:getCurrencyName(currencyId)
    assert(currencyId, "CurrencyUtil:getCurrencyName currencyId is null")
    if currencyRes[currencyId] then
        return currencyRes[currencyId].name
    end
    assert(false, "CurrencyUtil:getCurrencyName currencyId is not found, currencyId:" .. tostring(currencyId))
end

function CurrencyUtil:getCurrencyIcon(currencyId)
    assert(currencyId, "CurrencyUtil:getCurrencyIcon currencyId is null")
    if currencyRes[currencyId] then
        return currencyRes[currencyId].icon
    end
    assert(false, "CurrencyUtil:getCurrencyIcon currencyId is not found, currencyId:" .. tostring(currencyId))
end

--[[
    @desc: 货币是否有版本控制，可回溯
    author:tanqinjian
    time:2025-06-17 15:52:14
    --@currencyId: 
    @return:
]]
function CurrencyUtil:isVersionContr(currencyId)
    assert(currencyId, "CurrencyUtil:isVersionContr currencyId is null")

    if currencyRes[currencyId] then
        return currencyRes[currencyId].databack == 1
    end

    assert(false, "CurrencyUtil:isVersionContr currencyId is not found, currencyId:" .. tostring(currencyId))
end

--[[
    @desc: 获取货币id列表
    author:tanqinjian
    time:2025-07-05 14:47:28
    @return:
]]
function CurrencyUtil:getCurrencyList()
    local list = {}

    for k, v in pairs(currencyRes) do
        table.insert(list, v.currencyId)
    end

    return list
end

--[[
    @desc: 获取货币周期上限类型
    author:tanqinjian
    time:2025-07-16 16:58:06
    --@currencyId: 
    @return:
]]
function CurrencyUtil:getLimitType(currencyId)
    assert(currencyId, "CurrencyUtil:isVersionContr currencyId is null")

    if currencyRes[currencyId] then
        return currencyRes[currencyId].limitType
    end
end

function CurrencyUtil:getLimitTypeText(currencyId)
    assert(currencyId, "CurrencyUtil:getLimitTypeText currencyId is null")

    if currencyRes[currencyId] then
        local text = {
            [1] = "本日",
            [2] = "本周",
            [3] = "本月"
        }

        if text[currencyRes[currencyId].limitType] then
            return text[currencyRes[currencyId].limitType]
        end

        return ""
    end

    return ""
end

function CurrencyUtil:getCurrencySalePrice(currencyId)
    assert(currencyId, "CurrencyUtil:getCurrencySalePrice currencyId is null")

    if currencyRes[currencyId] then
        return currencyRes[currencyId].salePrice
    end
end

return CurrencyUtil
00000000000