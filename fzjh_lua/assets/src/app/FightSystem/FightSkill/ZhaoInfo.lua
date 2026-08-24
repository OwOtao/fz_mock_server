--[[
    被动招式 主动招式 通用招式信息
]]
local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ZhaoInfo = {
    __res = nil,
    __animHurtWeight = {}
}

function ZhaoInfo:create(res)
    local p = self.new()
    p:init(res)
    return p
end

function ZhaoInfo:init(res)
    self.__res = res

    if res.animResId == 0 then
        if res.animHurtTimes ~= 0 then
            assert(false, "招式：" .. res.id .. "动画资源ID;animResId 为0，但动画受击次数;animHurtTimes 或 动画受击伤害分配权值;animHurtWeight 不为0")
        end
    else
        if res.animHurtTimes > 0 then
            local list = string.split(tostring(res.animHurtWeight), "#")
            if #list ~= res.animHurtTimes then
                assert(false, "招式攻击:" .. res.id .. " animHurtWeight 与 animHurtTimes 个数匹配错误")
            end
            if MapIsEmpty(list) == false then
                for i, hurtWeight in ipairs(list) do
                    table.insert(self.__animHurtWeight, tonumber(hurtWeight))
                end
            else
                assert(false, "招式攻击:" .. res.id .. " animHurtWeight 解析错误")
            end
        end
    end
end

function ZhaoInfo:getId()
    return self.__res.id
end

function ZhaoInfo:getHurtWeight()
    return self.__res.hurtWeight
end

function ZhaoInfo:getAnimResId()
    return self.__res.animResId
end

function ZhaoInfo:getSoundStart()
    return self.__res.soundStart
end

function ZhaoInfo:getSoundId()
    return self.__res.soundId
end

function ZhaoInfo:getSoundType()
    return self.__res.soundType
end

function ZhaoInfo:getAnimHurtTimes()
    return self.__res.animHurtTimes
end

function ZhaoInfo:getAnimHurtWeight()
    return self.__animHurtWeight
end

function ZhaoInfo:getTotalAnimHurtWeight()
    local weight = 0

    for i, v in ipairs(self.__animHurtWeight) do
        weight = weight + v
    end

    if weight <= 0 then
        FightUtil:printLog(self.__animHurtWeight)
        assert(false, "招式攻击:" .. self:getId() .. " 获取动画权重错误：")
    end

    return weight
end

function ZhaoInfo:getAnimHurtWeightValue(index)
    if index <= 0 then
        assert(false, "ZhaoInfo:getAnimHurtWeightValue 获取动画伤害权重，参数不能小于1")
    end

    if index > #self.__animHurtWeight then
        assert(false, "ZhaoInfo:getAnimHurtWeightValue 获取动画伤害权重，参数越界：" .. index)
    end

    return self.__animHurtWeight[index]
end

return class("ZhaoInfo", {}, ZhaoInfo)
000