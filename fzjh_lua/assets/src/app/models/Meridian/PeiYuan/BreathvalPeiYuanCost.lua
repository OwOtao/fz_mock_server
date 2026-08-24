--[[
    author:Seven
    time:2025-01-17 15:44:50
    desc: 消耗真气培元
]]
local newClass = require("third.class.NewClass")

--@RefType [MeridianResources]
local MeridianResources = require("app.models.Meridian.MeridianResources")

local MERIDIAN_CONTANTS = MeridianResources:getConstant()

local BreathvalPeiYuanCost = {}

function BreathvalPeiYuanCost:create(...)
    local p = BreathvalPeiYuanCost.new()
    return p:__init(...)
end

function BreathvalPeiYuanCost:__init(role)
    self.__role = assert(role, "BreathvalPeiYuanCost:__init role is nil")

    self.__costType = MERIDIAN_CONTANTS.PEI_YUAN_COST_TYPE.BREATHVAL

    return self
end

function BreathvalPeiYuanCost:getCostType()
    return self.__costType
end

function BreathvalPeiYuanCost:meetCost(succFunc, failFunc)
    local breathval = self.__role:getAttr("breathVal")
    if breathval < MERIDIAN_CONTANTS.PEI_YUAN_BREATHVAL_COST then
        return failFunc("真气不足")
    end

    return succFunc()
end

function BreathvalPeiYuanCost:peiYuanCost(succFunc, failFunc)
    return self:meetCost(
        function()
            self.__role:addAttr("breathVal", -MERIDIAN_CONTANTS.PEI_YUAN_BREATHVAL_COST)
            return succFunc()
        end,
        failFunc
    )
end

return newClass("BreathvalPeiYuanCost", {}, BreathvalPeiYuanCost)
000000