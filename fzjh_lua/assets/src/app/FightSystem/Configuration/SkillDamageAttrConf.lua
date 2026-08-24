--[[
Descripttion: 武学伤害属性配置表
version: 
Author: LvBin
Date: 2024-09-19 12:04:53
--]]
local res = require("script.newbattle.demo.skillDamageAttrConf")["data"]

local SkillDamageAttrConf = {}

function SkillDamageAttrConf:getSkillDamageAttrRes(id)
    local data = res[tostring(id)]

    if data == nil then
        assert(false, "找不到伤害属性 id ：" .. tostring(id))
    end

    return data
end

function SkillDamageAttrConf:getDamageClassName(id)
    local data = res[tostring(id)]

    if data == nil then
        assert(false, "找不到伤害属性 id ：" .. tostring(id))
    end

    return data.damageClassName
end

function SkillDamageAttrConf:getAtkDamageClassId(id)
    local data = res[tostring(id)]

    if data == nil then
        assert(false, "找不到伤害属性 id ：" .. tostring(id))
    end

    return data.atkDamageClassID
end

function SkillDamageAttrConf:getDefDamageClassId(id)
    local data = res[tostring(id)]

    if data == nil then
        assert(false, "找不到伤害属性 id ：" .. tostring(id))
    end

    return data.defDamageClassID
end

function SkillDamageAttrConf:getAtkDamageClassName(id)
    local data = res[tostring(id)]

    if data == nil then
        assert(false, "找不到伤害属性 id ：" .. tostring(id))
    end

    return data.atkDamageClassName
end

function SkillDamageAttrConf:getDefDamageClassName(id)
    local data = res[tostring(id)]

    if data == nil then
        assert(false, "找不到伤害属性 id ：" .. tostring(id))
    end

    return data.defDamageClassName
end

return SkillDamageAttrConf
000