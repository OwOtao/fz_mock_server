--[[
    author:Seven
    time:2023-03-25 10:36:15
    desc:
]]
local newClass = require("third.class.NewClass")

local BasicBuffEffectAppearence = {}

function BasicBuffEffectAppearence:create(res)
    return BasicBuffEffectAppearence.new():__init(res)
end

function BasicBuffEffectAppearence:__init(res)
    self.__res = res

    return self
end

-- Buff效果编号;
function BasicBuffEffectAppearence:getId()
    return self.__res.id
end

function BasicBuffEffectAppearence:getIdleExpressionType()
    return tonumber(self.__res.idleExpressionType)
end

-- 影响待机动画;
function BasicBuffEffectAppearence:getIdleExpression()
    return self.__res.idleExpression
end

-- 影响待机优先级;
function BasicBuffEffectAppearence:getIdleSort()
    return tonumber(self.__res.idleSort)
end

-- 影响受击动画和音效状态;
function BasicBuffEffectAppearence:getHurtExpression()
    return self.__res.hurtExpression
end

-- 影响受击优先级;
function BasicBuffEffectAppearence:getHurtSort()
    return tonumber(self.__res.hurtSort)
end

-- 效果生效角色头顶挂载文字;
function BasicBuffEffectAppearence:getActiveEffectRoleHeadText()
    return self.__res.activeEffectRoleHeadText
end

-- 效果生效角色头顶挂载文字优先级;
function BasicBuffEffectAppearence:getActiveEffectRoleHeadTextSort()
    return tonumber(self.__res.activeEffectRoleHeadTextSort)
end

-- 效果生效角色挂载护盾;
function BasicBuffEffectAppearence:getActiveEffectRoleShield()
    return self.__res.activeEffectRoleShield
end

-- 效果生效角色挂载护盾;
function BasicBuffEffectAppearence:getActiveEffectRoleShieldSort()
    return tonumber(self.__res.activeEffectRoleShieldSort)
end

-- 效果生效角色挂载脚底光环;
function BasicBuffEffectAppearence:getActiveEffectRoleFeetHalo()
    return self.__res.activeEffectRoleFeetHalo
end

-- 效果生效角色挂载脚底光环;
function BasicBuffEffectAppearence:getActiveEffectRoleFeetHaloSort()
    return tonumber(self.__res.activeEffectRoleFeetHaloSort)
end

return newClass("BasicBuffEffectAppearence", {}, BasicBuffEffectAppearence)
0000000