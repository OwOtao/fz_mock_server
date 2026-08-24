--[[
    author:Seven
    time:2025-01-17 15:44:50
    desc: 消耗三才丹培元
]]
local newClass = require("third.class.NewClass")

--@RefType [MeridianResources]
local MeridianResources = require("app.models.Meridian.MeridianResources")

local MERIDIAN_CONTANT = MeridianResources:getConstant()

local SanCaiDanPeiYuanCost = {}

function SanCaiDanPeiYuanCost:create(...)
    local p = SanCaiDanPeiYuanCost.new()
    return p:__init(...)
end

function SanCaiDanPeiYuanCost:__init(role)
    self.__role = assert(role, "SanCaiDanPeiYuanCost:__init role is nil")

    self.__costType = MERIDIAN_CONTANT.PEI_YUAN_COST_TYPE.SAN_CAI_DAN

    return self
end

function SanCaiDanPeiYuanCost:getCostType()
    return self.__costType
end

function SanCaiDanPeiYuanCost:meetCost(succFunc, failFunc)
    if self.__role:getItemCount("sancaidan") < 1 then
        PopText("您没有三才丹")
        return
    end

    return succFunc()
end

function SanCaiDanPeiYuanCost:peiYuanCost(succFunc, failFunc)
    return self:meetCost(
        function()
            self.__role:addItemCount("sancaidan", -1)

            return succFunc()
        end,
        failFunc
    )
end

return newClass("SanCaiDanPeiYuanCost", {}, SanCaiDanPeiYuanCost)
0000000000