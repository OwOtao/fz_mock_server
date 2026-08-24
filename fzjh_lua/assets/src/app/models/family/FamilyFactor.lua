local newClass = require("third.class.NewClass")

local FamilyFactor = {}

function FamilyFactor:create(data)
    return FamilyFactor.new(data)
end

-- 门派id;id
function FamilyFactor:getId()
    return self.id
end

-- 门派名称;name
function FamilyFactor:getName()
    return self.name
end

-- 门派攻击系数;atkFamily
function FamilyFactor:getAtkFamily()
    return self.atkFamily
end

-- 门派防御系数;defFamily
function FamilyFactor:getDefFamily()
    return self.defFamily
end

-- 门派命中系数;apFamily
function FamilyFactor:getApFamily()
    return self.apFamily
end

-- 门派招架系数;parryFamily
function FamilyFactor:getParryFamily()
    return self.parryFamily
end

-- 门派闪躲系数;dodgeFamily
function FamilyFactor:getDodgeFamily()
    return self.dodgeFamily
end

-- 门派伤害系数;damageFamily
function FamilyFactor:getDamageFamily()
    return self.damageFamily
end

-- 门派保护系数;protectFamily
function FamilyFactor:getProtectFamily()
    return self.protectFamily
end

-- 门派特殊说明;dsc
function FamilyFactor:getDsc()
    return self.dsc
end

-- 简介;litteDesc
function FamilyFactor:getLitteDesc()
    return self.litteDesc
end

-- 默认师傅;defaultTeacher
function FamilyFactor:getDefaultTeacher()
    return self.defaultTeacher
end

-- 门派心法;familySkill
function FamilyFactor:getFamilySkill()
    return self.familySkill
end

function FamilyFactor:getNpcs()
    local list = {}

    local i = 1
    while self["npc" .. i] ~= nil and string.len(tostring(self["npc" .. i])) >= 1 do
        table.insert(list, self["npc" .. i])
        i = i + 1
    end

    return list
end

return newClass("FamilyFactor", {}, FamilyFactor)
000