--[[
    author:Seven
    time:2025-01-17 15:44:50
    desc: 消耗定志丸培元
]]
local newClass = require("third.class.NewClass")

--@RefType [MeridianResources]
local MeridianResources = require("app.models.Meridian.MeridianResources")

local MERIDIAN_CONTANT = MeridianResources:getConstant()

local DingZhiWanPeiYuanCost = {}

function DingZhiWanPeiYuanCost:create(...)
    local p = DingZhiWanPeiYuanCost.new()
    return p:__init(...)
end

function DingZhiWanPeiYuanCost:__init(role, costNum)
    self.__role = assert(role, "DingZhiWanPeiYuanCost:__init role is nil")

    self.__costType = MERIDIAN_CONTANT.PEI_YUAN_COST_TYPE.DING_ZHI_WAN

    self.__itemId = "dingzhiwan"

    self.__itemNum = 1

    return self
end

function DingZhiWanPeiYuanCost:getCostType()
    return self.__costType
end

function DingZhiWanPeiYuanCost:meetCost(succFunc, failFunc)
    if self.__role:getItemCount(self.__itemId) < self.__itemNum then
        return failFunc("您的定志丸数量不足")
    end

    local inheritCount = self.__role:getAttr("inheritCount")
    if inheritCount < 1 then
        return failFunc("你的体内没有来自他人的内力，恐怕无法承受此药。")
    end

    return succFunc()
end

function DingZhiWanPeiYuanCost:peiYuanCost(succFunc, failFunc)
    return self:meetCost(
        function()
            HttpManagerEx:checkItemIsCanUse(
                self.__itemId,
                self.__itemNum,
                function(status, errcode, errmsg, data)
                    if status == 200 then
                        if errcode == 0 then
                            local useDingZhiWanNum = tonumber(data.dingzhiwannum)
                            self.__role:addItemCount("dingzhiwan", -self.__itemNum)
                            succFunc(useDingZhiWanNum)
                        else
                            PopText(errmsg .. "(" .. errcode .. ")")
                            failFunc(errmsg)
                        end
                    else
                        PopText(errmsg)
                    end
                end,
                IS_SHOW_WAITING
            )
        end,
        failFunc
    )
end

return newClass("DingZhiWanPeiYuanCost", {}, DingZhiWanPeiYuanCost)
00000