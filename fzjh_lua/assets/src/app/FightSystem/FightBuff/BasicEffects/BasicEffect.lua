--[[
    author:Seven
    time:2023-03-06 14:25:28
    desc: buff效果基础类
]]
local newClass = require("third.class.NewClass")

local BasicEffect = {}

function BasicEffect:create(res)
    return BasicEffect.new():__init(res)
end

function BasicEffect:__init(res)
    if res == nil then
        error("BasicEffect:__init 创建失败，参数为空")
    end

    self.__res = res

    return self
end

-- 编号;id
function BasicEffect:getId()
    return tostring(self.__res.id)
end

-- Buff效果ID;effectID
function BasicEffect:getEffectID()
    return self.__res.effectID
end

-- 效果类型;effectType
function BasicEffect:getEffectType()
    return self.__res.effectType
end

-- 效果类型参数;effectTypeParam
function BasicEffect:getEffectTypeParam()
    return self.__res.effectTypeParam
end

-- 效果固定参数;argsParam
function BasicEffect:getArgsParam()
    return self.__res.argsParam
end

-- -- 效果固定参数1;argsParam1
-- function BasicEffect:getArgsParam1()
--     return self.__res.argsParam1
-- end

-- -- 效果固定参数2;argsParam2
-- function BasicEffect:getArgsParam2()
--     return self.__res.argsParam2
-- end

-- -- 效果动态参数dynamicArg1;dynamicArg1
-- function BasicEffect:getDynamicArg1()
--     return self.__res.dynamicArg1
-- end

-- -- 效果动态参数dynamicArg2;dynamicArg2
-- function BasicEffect:getDynamicArg2()
--     return self.__res.dynamicArg2
-- end

-- 效果生效其作用目标受击帧头顶弹字
function BasicEffect:getEffectHurtRolePopTextOnHitFrame()
    return self.__res.effectHurtRolePopTextOnHitFrame
end

-- 点击主动招式按钮效果生效tips提示文本;activeEffectUseZhaoTips
function BasicEffect:getActiveEffectUseZhaoTips()
    return self.__res.activeEffectUseZhaoTips
end

-- 任意招式组合攻击结束时效果生效角色头顶弹字;activeEffectRolePop
function BasicEffect:getActiveEffectRolePop()
    return self.__res.activeEffectRolePop
end

-- 自身招式组合攻击结束时效果生效角色头顶弹字;activeEffectOwnRolePop
function BasicEffect:getActiveEffectOwnRolePop()
    return self.__res.activeEffectOwnRolePop
end

-- 招式组合攻击结束时效果自身生效值统计描述;activeEffectDesc
function BasicEffect:getActiveEffectDesc()
    return self.__res.activeEffectDesc
end

-- 招式组合攻击结束时，招式攻击过程造成的效果生效值统计描述;zhaoComboDirectDamgeDesc
function BasicEffect:getZhaoComboDirectDamgeDesc()
    return self.__res.zhaoComboDirectDamgeDesc
end

return newClass("BasicEffect", {}, BasicEffect)
00000000000