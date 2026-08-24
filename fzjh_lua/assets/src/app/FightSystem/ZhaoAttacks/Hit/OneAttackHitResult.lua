--[[
    author:Seven
    time:2023-02-09 11:44:56
    desc: 记录每一次击中攻击结果
]]
local newClass = require("third.class.NewClass")

local isImpl = require("third.assertIsInstance.assertIsInstance")

local OneAttackHitResult = {}

function OneAttackHitResult:create()
    return OneAttackHitResult.new()
end

function OneAttackHitResult:ctor()
    self.__attackerEffectModifierAttrs = {}

    self.__targetEffectModifierAttrs = {}
end

--@desc: 存放招式造成的伤害数组
--@author:Seven
--@time:2023-02-09 14:36:54
--@zhaoHurts: 招式造成的伤害数组
function OneAttackHitResult:setZhaoHurts(zhaoHurts)
    if zhaoHurts == nil then
        error("OneAttackHitResult:setZhaoHurts 参数zhaoHurts不可为nil")
    end

    self.__zhaoHurts = zhaoHurts
end

function OneAttackHitResult:getZhaoHurts()
    if self.__zhaoHurts == nil then
        assert(false, "OneAttackHitResult:getZhaoHurts 招式攻击伤害为空，检查代码！")
    end

    return self.__zhaoHurts
end

function OneAttackHitResult:walkOneHitZhaoHurts(func)
    if table.getn(self.__zhaoHurts) <= 0 then
        return
    end

    for index, v in ipairs(self.__zhaoHurts) do
        if func(index, v) == true then
            break
        end
    end
end

function OneAttackHitResult:addAttackerEffectModifierAttr(effectModifier)
    table.insert(self.__attackerEffectModifierAttrs, isImpl(effectModifier, require("app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr")))
end

function OneAttackHitResult:getAttackerEffectModifierAttrs()
    return self.__attackerEffectModifierAttrs
end

function OneAttackHitResult:addTargetEffectModifierAttr(effectModifier)
    table.insert(self.__targetEffectModifierAttrs, isImpl(effectModifier, require("app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr")))
end

function OneAttackHitResult:getTargetEffectModifierAttrs()
    return self.__targetEffectModifierAttrs
end

return newClass("OneAttackHitResult", {}, OneAttackHitResult)
00000000000000