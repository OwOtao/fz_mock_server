--[[
    author:Seven
    time:2024-01-04 18:23:20
    desc: 统计效果造成属性变化，作用于攻击组合结束时
]]
local newClass = require("third.class.NewClass")

local BuffConf = require("app.FightSystem.Configuration.BuffConf")

local EffectModifierResultCount = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultCount")

local EffectModifierResultOnAttackCombFinishVisitor = {}

function EffectModifierResultOnAttackCombFinishVisitor:create(...)
    return EffectModifierResultOnAttackCombFinishVisitor.new():__init(...)
end

function EffectModifierResultOnAttackCombFinishVisitor:__init(context)
    self.__context = context

    self.__fight = self.__context:getFight()

    --@RefType [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.EffectModifierResultCount#EffectModifierResultCount]
    self.__effectModifierResultCount = EffectModifierResultCount:create()

    return self
end

--@effectModifierAttr: [src.app.FightSystem.CharacterHurt.BuffEffectHurt.ABuffEffectModifierAttr#ABuffEffectModifierAttr]
function EffectModifierResultOnAttackCombFinishVisitor:visitEffectModifierAttrs(effectModifierAttr)
    --@desc 效果目标id
    self.__effectModifierResultCount:addModifierAttr(effectModifierAttr)
end

function EffectModifierResultOnAttackCombFinishVisitor:getPrintAndPopTextList()
    local printList = {}
    local popList = {}
    local FightDesc = require("app.FightSystem.FightUtil.FightDesc")

    self.__effectModifierResultCount:walkModifierCount(
        function(c_id, effectId, ownerId, attrName, value)
            local basicEffect = BuffConf:getBasicEffect(effectId)

            local popDesc = basicEffect:getActiveEffectRolePop()

            local buffTarget = self.__fight:getCharacter(c_id)

            local buffOwner = self.__fight:getCharacter(ownerId)

            local printDesc = basicEffect:getZhaoComboDirectDamgeDesc()

            if printDesc ~= nil then
                --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
                local f_desc = FightDesc:create()

                f_desc:setAttacker(self.__context:getAttacker())

                f_desc:setDefender(self.__context:getTarget())

                f_desc:setBuffTarget(buffTarget)

                f_desc:setBuffOwner(buffOwner)

                f_desc:setBuffActualValue(math.ceil(math.abs(value)))

                f_desc:setText(printDesc)

                table.insert(printList, f_desc:getString())
            end

            if popDesc ~= nil then
                local f_desc = FightDesc:create()

                f_desc:setAttacker(self.__context:getAttacker())

                f_desc:setDefender(self.__context:getTarget())

                f_desc:setBuffTarget(buffTarget)

                f_desc:setBuffOwner(buffOwner)

                f_desc:setBuffActualValue(math.ceil(math.abs(value)))

                f_desc:setText(popDesc)

                table.insert(popList, {id = c_id, text = f_desc:getString()})
            end
        end
    )

    return printList, popList
end

return newClass("EffectModifierResultOnAttackCombFinishVisitor", {}, EffectModifierResultOnAttackCombFinishVisitor)
000000000000000