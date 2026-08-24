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
local DingZhiWanPeiYuanImpl = {}

function DingZhiWanPeiYuanImpl:create(...)
    local p = DingZhiWanPeiYuanImpl.new()
    return p:__init(...)
end

function DingZhiWanPeiYuanImpl:__init(role, pageIndex, replacedImprId, peiYuanType)
    self.__role = assert(role, "DingZhiWanPeiYuanImpl:__init role is nil")

    self.__pageIndex = assert(pageIndex, "RandomPeiYuanImpl:__init pageIndex is nil")

    self.__replacedImprId = replacedImprId

    self.__itemCostNum = 1
    if peiYuanType == PEI_YUAN_CONTANT_TYPE.DING_ZHI_WAN then
        self.__peiYuanCost = DingZhiWanPeiYuanCost:create(role, self.__itemCostNum)
    else
        assert(false, "RandomPeiYuan not support peiYuanType:" .. tostring(peiYuanType))
    end

    return self
end

--@desc: 是否满足销毁
--@author:Seven
--@time:2025-01-17 15:14:10
--@succFunc: func()
--@failFunc: func(failmsg)
function DingZhiWanPeiYuanImpl:meetCost(succFunc, failFunc)
    return self.__peiYuanCost:meetCost(
        function()
            succFunc()
        end,
        function(failmsg)
            failFunc(failmsg)
        end
    )
end

--@desc:获取定志丸已使用数量
--@author:Seven
--@time:2025-01-20 16:30:35
--@succFunc: func(usedNum，nowNum)
--@failFunc: func(failmsg)
function DingZhiWanPeiYuanImpl:__getDingZhiWanUsedNum(succFunc, failFunc)
    HttpManagerEx:detectionGoods(
        "dingzhiwan",
        function(status, errcode, errmsg, data)
            if status == 200 then
                if errcode == 0 then
                    if data.numbers == nil then
                        failFunc("定志丸数量获取异常（-1）")
                        return
                    end
                    local nowNum = tonumber(data.numbers)

                    if data.usedNumber == nil then
                        failFunc("定志丸使用数量获取异常（-1）")
                        return
                    end

                    local usedNumber = tonumber(data.usedNumber)

                    succFunc(usedNumber, nowNum)
                else
                    local msg = tostring(errmsg) .. "（" .. errcode .. "）"
                    failFunc(msg)
                end
            else
                local __netStatusError = "定志丸获取发生异常 S : " .. status .. "  ）"

                failFunc(__netStatusError)
            end
        end
    )
end

--@desc: 培元
--@author:Seven
--@time:2025-01-17 15:01:08
--@succfunc: func(newImprId)
--@failfunc: func(failmsg)
function DingZhiWanPeiYuanImpl:peiyuan(succfunc, failfunc)
    --@RefType [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
    local sys = self.__role:getMeridianSystem()

    if not sys:hasMeridianImprintingByPage(self.__pageIndex, self.__replacedImprId) then
        return failfunc("当前页没有印记：" .. MeridianResources:getMeridianImprintingRes(self.__replacedImprId):getName())
    end

    self:__getDingZhiWanUsedNum(
        function(useNum, nowNum)
            local newImprId = MeridianHelper:getRandomHuaZhiMeridianImprintId(self.__pageIndex, sys, useNum + self.__itemCostNum)

            if newImprId == nil then
                newImprId = MeridianHelper:getPeiYuanRandomImprintingId(self.__pageIndex, sys, true)
            end

            if newImprId == nil then
                failfunc("没有可用的培元印记")
                return
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
        end,
        function(errmsg)
            failFunc(errmsg)
        end
    )
end

return newClass("DingZhiWanPeiYuanImpl", {IPeiYuanFunc}, DingZhiWanPeiYuanImpl)
000