--[[
    author:Seven
    time:2024-04-13 17:19:36
    desc: 商品发放请求对象
]]
local newClass = require("third.class.NewClass")

local GrantGoodRequest = {}

function GrantGoodRequest:create(...)
    return GrantGoodRequest:new():__init(...)
end

function GrantGoodRequest:__init(conf)
    self.__goodsList = assert(conf.goodsList, "goodsList is nil")

    self.__dataVersion = conf.dataVersion

    self.__yashiExpiredTime = conf.yashiExpiredTime

    self.__currencyVersion = conf.currencyVersion
    
    return self
end

function GrantGoodRequest:getGoodsList()
    return self.__goodsList
end

function GrantGoodRequest:getDataVersion()
    return self.__dataVersion
end

function GrantGoodRequest:getYashiExpiredTime()
    return self.__yashiExpiredTime
end

function GrantGoodRequest:getCurrencyVersion()
    return self.__currencyVersion
end

function GrantGoodRequest:tostring()
    return string.format("GrantGoodRequest goodsList:%s dataVersion:%s currencyVersion:%s", table.tostring(self.__goodsList), tostring(self.__dataVersion),tostring(self.__yashiExpiredTime),tostring(self.__currencyVersion))
end

return newClass("GrantGoodRequest", {}, GrantGoodRequest)
00