local class = require("third.class.NewClass")

local DreamMapRoleAttr = {}

function DreamMapRoleAttr:create()
    return DreamMapRoleAttr:new()
end

function DreamMapRoleAttr:ctor()
end

function DreamMapRoleAttr:setRole(role)
    self.__role = role
end

function DreamMapRoleAttr:getRole()
    return self.__role
end

function DreamMapRoleAttr:getMenPaiName()
    return "【门派】"..self.__role:getFamilyName()
end

function DreamMapRoleAttr:getMenPaiDesc()
    return User:getRole():getDreamSystem():getFamilyDesc(self.__role)
end

function DreamMapRoleAttr:getCon()
    local con = self.__role:getFinalAttr("con")

    local secCon = self.__role:getFinalAttr("secCon")
    
    return "【根骨】"..tostring(secCon+con).."/"..con
end

function DreamMapRoleAttr:getAtk()
    return "【攻击力】 "..tostring(Helper:mathFloor(self.__role:getAtk()))
end

function DreamMapRoleAttr:getStr()
    local str = self.__role:getFinalAttr("str")

    local secStr = self.__role:getFinalAttr("secStr")
    
    return "【臂力】"..tostring(secStr+str).."/"..str
end

function DreamMapRoleAttr:getDodge()
    return "【躲闪力】 "..tostring(Helper:mathFloor(self.__role:getDodge()))
end

function DreamMapRoleAttr:getDex()
    local dex = self.__role:getFinalAttr("dex")

    local secDex = self.__role:getFinalAttr("secDex")
    
    return "【身法】"..tostring(secDex+dex).."/"..dex
end

function DreamMapRoleAttr:getFangYu()
    return "【防御力】 "..tostring(Helper:mathFloor(self.__role:getDef()))
end

function DreamMapRoleAttr:getDamage()
    return "【伤害力】 "..tostring(Helper:mathFloor(self.__role:getPowerDamage()))
end

function DreamMapRoleAttr:getZhengQi()
    return "【侠义正气】 "..tostring(Helper:mathFloor(self.__role:getFinalAttr("zhengqi")))
end

function DreamMapRoleAttr:getFangHu()
    return "【防护力】 "..tostring(Helper:mathFloor(self.__role:getFangHu()))
end

return class("DreamMapRoleAttr", {}, DreamMapRoleAttr)
0000000000