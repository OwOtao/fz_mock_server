--[[
    author:Seven
    time:2025-01-17 17:20:15
    desc:
]]
local newClass = require("third.class.NewClass")

local IPeiYuanFunc = require("app.models.Meridian.PeiYuan.IPeiYuanFunc")

local MeridianResources = require("app.models.Meridian.MeridianResources")

local MeridianHelper = require("app.models.Meridian.MeridianHelper")

local PEI_YUAN_CONTANT_TYPE = MeridianResources:getConstant().PEI_YUAN_COST_TYPE

local DingZhiWanPeiYuanCost = require("app.models.Meridian.PeiYuan.DingZhiWanPeiYuanCost")
local SanCaiDanPeiYuanCost = require("app.models.Meridian.PeiYuan.SanCaiDanPeiYuanCost")
local BreathvalPeiYuanCost = require("app.models.Meridian.PeiYuan.BreathvalPeiYuanCost")

--@SuperType [src.app.models.Meridian.PeiYuan.IPeiYuanFunc#IPeiYuanFunc]
local RandomPeiYuanImpl = {}

function RandomPeiYuanImpl:create(...)
    local p = RandomPeiYuanImpl.new()
    return p:__init(...)
end

function RandomPeiYuanImpl:__init(role, pageIndex, replacedImprId, peiYuanType)
    self.__role = assert(role, "RandomPeiYuanImpl:__init role is nil")

    self.__pageIndex = assert(pageIndex, "RandomPeiYuanImpl:__init pageIndex is nil")

    self.__replacedImprId = replacedImprId

    if peiYuanType == PEI_YUAN_CONTANT_TYPE.SAN_CAI_DAN then
        self.__peiYuanCost = SanCaiDanPeiYuanCost:create(role)
    elseif peiYuanType == PEI_YUAN_CONTANT_TYPE.BREATHVAL then
        self.__peiYuanCost = BreathvalPeiYuanCost:create(role)
    else
        assert(false, "RandomPeiYuan not support peiYuanType:" .. tostring(peiYuanType))
    end

    return self
end

--@desc: 是否满足消耗
--@author:Seven
--@time:2025-01-17 15:14:10
--@succFunc: func()
--@failFunc: func(failmsg)
function RandomPeiYuanImpl:meetCost(succFunc, failFunc)
    return self.__peiYuanCost:meetCost(
        function()
            succFunc()
        end,
        function(failmsg)
            failFunc(failmsg)
        end
    )
end

--@desc: 培元
--@author:Seven
--@time:2025-01-17 15:01:08
--@succfunc: func()
--@failfunc: func(failmsg)
function RandomPeiYuanImpl:peiyuan(succfunc, failfunc)
    --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    local sys = self.__role:getMeridianSystem()

    if not sys:hasMeridianImprintingByPage(self.__pageIndex, self.__replacedImprId) then
        return failfunc("当前页没有印记：" .. MeridianResources:getMeridianImprintingRes(self.__replacedImprId):getName())
    end

    local newImprId = MeridianHelper:getPeiYuanRandomImprintingId(self.__pageIndex, sys, false)

    if newImprId == nil then
        return failfunc("没有可用的培元印记")
    end

    self.__peiYuanCost:peiYuanCost(
        function()
            sys:replaceMeridianImprinting(self.__pageIndex, self.__replacedImprId, newImprId)
            sys:getRole():updateRoleBuff()
            succfunc(newImprId)
        end,
        function(failmsg)
            failfunc(failmsg)
        end
    )
end

return newClass("RandomPeiYuanImpl", {IPeiYuanFunc}, RandomPeiYuanImpl)
000000000000000