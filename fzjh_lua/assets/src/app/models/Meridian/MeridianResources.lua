local MeridianImprinting = requireWithEncrypt("script.meridian.meridianImprinting")["Sheet1"]

local MeridianImprintingRes = require("app.models.Meridian.MeridianImprintingRes")

local MeridianResources = {
    __cache = {}
}

local function GET_RES(imprintingId)
    for k, v in pairs(MeridianImprinting) do
        if v.imprintingId == imprintingId then
            return v
        end
    end

    return nil
end

--@desc: 获取基础经脉印记数据对象，如果没有返回nil,否则返回经脉印记对象列表
--@author:Seven
--@time:2025-01-16 14:54:31
--@meriImpId: 经脉印记ID
--@return [src.app.models.Meridian.MeridianImprintingRes#MeridianImprintingRes]
function MeridianResources:getMeridianImprintingRes(meriImpId)
    if self.__cache[meriImpId] then
        return self.__cache[meriImpId]
    end

    if not meriImpId then
        error("获取经脉印记资源，ID不可为空")
    end

    local res = GET_RES(meriImpId)
    if not res then
        error("没有找到经脉印记资源，id：" .. tostring(meriImpId))
    end

    return MeridianImprintingRes:create(res)
end

function MeridianResources:getAllMeridianImprintingRes()
    if self.__allListCache then
        return self.__allListCache
    end
    
    self.__allListCache = {}
    for __,v in pairs(MeridianImprinting) do
        table.insert(self.__allListCache, self:getMeridianImprintingRes(v.imprintingId))
    end

    return self.__allListCache
end

local MERIDIAN_CONTANTS = {
    PEI_YUAN_COST_TYPE = {
        --真气
        BREATHVAL = 1,
        -- 三才单
        SAN_CAI_DAN = 2,
        -- 定志丸
        DING_ZHI_WAN = 3
    },
    PEI_YUAN_BREATHVAL_COST = 180000
}

local CONTANTS_PROXY = TableProxy:createEncryptedTableRecursive(MERIDIAN_CONTANTS)

--@desc: 经脉相关程序定义常量表
--@author:Seven
--@time:2025-01-17 15:09:19
--@return [src.app.models.Meridian.MeridianResources#MERIDIAN_CONTANTS]
function MeridianResources:getConstant()
    return CONTANTS_PROXY
end

return MeridianResources
00000