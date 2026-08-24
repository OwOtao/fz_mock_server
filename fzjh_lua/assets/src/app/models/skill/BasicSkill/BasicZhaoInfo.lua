--[[
    author:Seven
    time:2022-11-19 16:27:38
    desc:通用招式信息
]]

local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BasicZhaoInfo = {
    __res = nil,
    __animHurtWeight = {}
}

BasicZhaoInfo.SOUND_TYPE = {
    ZHAO_ORIGIN = 0,
    ATTACKER_WEAPON = 1
}

function BasicZhaoInfo:__init(res)
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
    return self
end

function BasicZhaoInfo:getId()
    return self.__res.id
end

function BasicZhaoInfo:getHurtWeight()
    return self.__res.hurtWeight
end

function BasicZhaoInfo:getAnimResId()
    return self.__res.animResId
end

function BasicZhaoInfo:getSoundStart()
    return self.__res.soundStart
end

function BasicZhaoInfo:getSoundId()
    return self.__res.soundId
end

function BasicZhaoInfo:getSoundType()
    return self.__res.soundType
end

function BasicZhaoInfo:getAnimHurtTimes()
    return self.__res.animHurtTimes
end

function BasicZhaoInfo:getAnimHurtWeight()
    return self.__animHurtWeight
end

function BasicZhaoInfo:getTotalAnimHurtWeight()
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

function BasicZhaoInfo:getAnimHurtWeightValue(index)
    if index <= 0 then
        assert(false, "BasicZhaoInfo:getAnimHurtWeightValue 获取动画伤害权重，参数不能小于1")
    end

    if index > #self.__animHurtWeight then
        assert(false, "BasicZhaoInfo:getAnimHurtWeightValue 获取动画伤害权重，参数越界：" .. index)
    end

    return self.__animHurtWeight[index]
end

return class("BasicZhaoInfo", {}, BasicZhaoInfo)00