--[[
    主动技能招式伤害
]]
local class = require("third.class.NewClass")

local FightFormula = require("app.FightSystem.FightFormula")

local ActiveZhaoHurt = {}

function ActiveZhaoHurt:create()
    return self.new()
end

function ActiveZhaoHurt:ctor()
end

function ActiveZhaoHurt:setCharacter(character)
    self.__character = character
end

function ActiveZhaoHurt:setZhaoHurtRes(res)
    self.__zhaoHurtRes = res
end

function ActiveZhaoHurt:getId()
    return self.__zhaoHurtRes.id
end

function ActiveZhaoHurt:getHurtID()
    return self.__zhaoHurtRes.hurtID
end

function ActiveZhaoHurt:getChangeAttrType()
    return self.__zhaoHurtRes.changeAttrType
end

function ActiveZhaoHurt:getBreakShield()
    if tonumber(self.__zhaoHurtRes.breakShield) == 1 then
        return true
    elseif tonumber(self.__zhaoHurtRes.breakShield) == 0 then
        return false
    else
        error(("主动招式伤害：" .. self:getId() .. "穿透护盾值填写错误：非0或1，" .. tostring(self.__zhaoHurtRes.breakShield)))
    end
end

function ActiveZhaoHurt:getChangeAttrName()
    local attr_type = self:getChangeAttrType()

    if attr_type == 1 then
        return "qi"
    elseif attr_type == 2 then
        return "qiMax"
    elseif attr_type == 3 then
        return "neili"
    else
        assert(false, "ActiveZhaoHurt:getChangeAttrName ：changeAttrType 类型填写了未定义的数值 :" .. attr_type)
    end
end

function ActiveZhaoHurt:getComputingType()
    return self.__zhaoHurtRes.computingType
end

function ActiveZhaoHurt:getHurtDegreeID()
    return self.__zhaoHurtRes.hurtDegreeID
end

function ActiveZhaoHurt:getHurtGrow()
    if self.__zhaoHurtRes.hurtGrow == nil then
        error("ActiveZhaoHurt:getHurtGrow 主动招式伤害 id：" .. self:getId() .. " 伤害增长倍率hurtGrow未填写")
    end
    return self.__zhaoHurtRes.hurtGrow
end

function ActiveZhaoHurt:getHurtBase()
    if self.__zhaoHurtRes.hurtBase == nil then
        error("ActiveZhaoHurt:getHurtBase 主动招式伤害 id：" .. self:getId() .. " 主动基础伤害hurtBase未填写")
    end
    return self.__zhaoHurtRes.hurtBase
end

function ActiveZhaoHurt:getHurtDes()
    return self.__zhaoHurtRes.hurtDes
end

function ActiveZhaoHurt:getHurtValue()
    --@RefType[ZhaoHurtDegreeFactory]
    local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")

    local hurtDegreeGroup = ZhaoHurtDegreeFactory:createHurtDegreeGroup(self:getHurtDegreeID(), self.__character)

    local hurtDegreeValue = hurtDegreeGroup:getHurtValue()

    local autoAvgAtk = 1
    if self:getComputingType() == 1 then
        autoAvgAtk = FightFormula:calQiAvgDamage(self.__character, self.__character:getTarget())
    end

    local activeHurtValue = FightFormula:calActiveAttackHurtValue(autoAvgAtk, hurtDegreeValue, self:getHurtGrow(), self:getHurtBase())

    return activeHurtValue
end

return class("ActiveZhaoHurt", {}, ActiveZhaoHurt)
000000000000000