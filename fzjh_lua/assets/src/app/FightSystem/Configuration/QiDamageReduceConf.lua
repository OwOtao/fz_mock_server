--[[
    气血免伤相关配置
]]
local QiDamageReduceConf = {}

local res = require("script.newbattle.demo.battleQiDamageAttrConf")["角色特殊战斗属性初始"]

function QiDamageReduceConf:getDefaultValue(id)
    local data = res[tostring(id)]

    if data == nil then
        error("QiDamageReduceConf:getDefaultValue 未找到id为" .. tostring(id) .. "的配置")
    end

    return data.attrDefault
end

function QiDamageReduceConf:getTipText(id)
    local data = res[tostring(id)]

    if data == nil then
        error("QiDamageReduceConf:getTipText 未找到id为" .. tostring(id) .. "的配置")
    end

    return data.attrTag
end

function QiDamageReduceConf:getAutoAttackReduceConfig()
    return {
        --@desc 甲等配置
        reduceIdConfLv1 = {
            setReduceRateIdLv1 = 100,
            setReduceRateIdLv2 = 101,
            setReduceRateIdLv3 = 102,
            setReduceValueIdLv1 = 109,
            setReduceValueIdLv2 = 110,
            setReduceValueIdLv3 = 111,
            setReduceBreakId = 300
        },
        --@desc 乙等配置
        reduceIdConfLv2 = {
            setReduceRateIdLv1 = 103,
            setReduceRateIdLv2 = 104,
            setReduceRateIdLv3 = 105,
            setReduceValueIdLv1 = 112,
            setReduceValueIdLv2 = 113,
            setReduceValueIdLv3 = 114,
            setReduceBreakId = 301
        },
        --@desc 丙等配置
        reduceIdConfLv3 = {
            setReduceRateIdLv1 = 106,
            setReduceRateIdLv2 = 107,
            setReduceRateIdLv3 = 108,
            setReduceValueIdLv1 = 115,
            setReduceValueIdLv2 = 116,
            setReduceValueIdLv3 = 117,
            setReduceBreakId = 302
        }
    }
end

function QiDamageReduceConf:getActiveAttackReduceConfig()
    return {
        --@desc 甲等配置
        reduceIdConfLv1 = {
            setReduceRateIdLv1 = 200,
            setReduceRateIdLv2 = 201,
            setReduceRateIdLv3 = 202,
            setReduceValueIdLv1 = 209,
            setReduceValueIdLv2 = 210,
            setReduceValueIdLv3 = 211,
            setReduceBreakId = 400
        },
        --@desc 乙等配置
        reduceIdConfLv2 = {
            setReduceRateIdLv1 = 203,
            setReduceRateIdLv2 = 204,
            setReduceRateIdLv3 = 205,
            setReduceValueIdLv1 = 212,
            setReduceValueIdLv2 = 213,
            setReduceValueIdLv3 = 214,
            setReduceBreakId = 401
        },
        --@desc 丙等配置
        reduceIdConfLv3 = {
            setReduceRateIdLv1 = 206,
            setReduceRateIdLv2 = 207,
            setReduceRateIdLv3 = 208,
            setReduceValueIdLv1 = 215,
            setReduceValueIdLv2 = 216,
            setReduceValueIdLv3 = 217,
            setReduceBreakId = 402
        }
    }
end

return QiDamageReduceConf
000