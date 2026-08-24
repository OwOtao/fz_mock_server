--[[
    author:Seven
    time:2025-01-17 15:07:20
    desc:
]]
--@RefType [MeridianResources]
local MeridianResources = require("app.models.Meridian.MeridianResources")

local PEI_YUAN_CONTANS = MeridianResources:getConstant().PEI_YUAN_COST_TYPE

local IPeiYuanFunc = require("app.models.Meridian.PeiYuan.IPeiYuanFunc")

local PeiYuanFactory = {}

--@desc: 获取培元功能实现类
--@author:Seven
--@time:2025-01-17 15:10:49
--@role: 需要进行培元的角色
--@replacedImprId: 被替换的经脉印记ID
--@peiYuanType: 培元类型
--@return [src.app.models.Meridian.PeiYuan.IPeiYuanFunc#IPeiYuanFunc]
function PeiYuanFactory:getPeiYuanFactory(role, pageIndex, replacedImprId, peiYuanType)
    local peiYuanFunc = nil

    if not table.contains(PEI_YUAN_CONTANS, peiYuanType) then
        error("PeiYuanFactory:getPeiYuanFactory 未知的培元类型:" .. tostring(peiYuanType))
    end

    if peiYuanType == PEI_YUAN_CONTANS.DING_ZHI_WAN then
        peiYuanFunc = require("app.models.Meridian.PeiYuan.DingZhiWanPeiYuanImpl"):create(role, pageIndex, replacedImprId, peiYuanType)
    else
        peiYuanFunc = require("app.models.Meridian.PeiYuan.RandomPeiYuanImpl"):create(role, pageIndex, replacedImprId, peiYuanType)
    end

    return peiYuanFunc
end

return PeiYuanFactory
000000000000000