--[[
    author:Seven
    time:2024-02-29 18:19:00
    desc: 用于判断buff是否满足自身生效条件
]]
local newClass = require("third.class.NewClass")

--@RefType [Constants]
local BUFF_CONST = require("app.FightSystem.FightBuff.Constants")

local FightCommons = require("app.FightSystem.FightCommons")

local BuffMakeOnTrigger = {}

--@desc: 判断节点是否满足buff生效
--@author:Seven
--@time:2024-02-29 18:20:42
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
--@makeOnNode: 节点类型
--@buffConds: 配置条件
--@...: 环境相关参数
--@return: true | false
function BuffMakeOnTrigger:isMakeOn(buff, makeOnNode, buffConds, ...)
    if table.keyof(BUFF_CONST.BUFF_TRIGGER_ON_NODE_TYPE, makeOnNode) == nil then
        error("BuffMakeOnTrigger:isMakeOn makeOnNode is not exist ： " .. tostring(makeOnNode))
    end

    if MapIsEmpty(buffConds) == true then
        error("Buff触发条件节点删除条件（deleteBuffCon）为1的情况下，Buff触发条件（triggerBuffCons）为空 " .. buff:getBuffId())
    end

    local confNode = tonumber(buffConds[1])

    if confNode == nil then
        error("Buff生效节点 解析后错误： " .. tostring(buffConds[1]))
    end

    if tonumber(confNode) ~= makeOnNode then
        return false
    end

    local func = self["__on" .. makeOnNode]

    if func == nil then
        error("Buff触发条件节点 ： " .. tostring(makeOnNode) .. "暂未支持实现")
    end

    return func(self, buff, buffConds, ...)
end

--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
function BuffMakeOnTrigger:__checkBuffOwnerOnAttackContext(buff, condition, context)
    if condition == "all" then
        return true
    elseif condition == "def" then
        return context:getTarget() == buff:getBuffOwner()
    elseif condition == "atk" then
        return context:getAttacker() == buff:getBuffOwner()
    else
        error("BuffMakeOnTrigger:__checkBuffOwnerOnAttackContext 未知的buff持有者限制条件 ： 【" .. tostring(condition) .. "】 buffId : " .. buff:getBuffId())
    end

    return false
end

--@desc: 检测攻击命中结果限制
--@author:Seven
--@time:2024-02-29 20:14:36
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
function BuffMakeOnTrigger:__checkAttackResult(buff, condition, context)
    if tonumber(condition) == 0 then
        return true
    end

    return switch(
        tonumber(condition),
        {
            [1] = function()
                local isAllHit = true
                context:walkAllZhaoAttackInTheCombAttack(
                    function(i, zhaoAttack)
                        --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
                        zhaoAttack = zhaoAttack
                        if zhaoAttack:getHitType() ~= FightCommons.ATTACK_HIT_TYPE.HIT then
                            isAllHit = false
                            return false
                        end

                        return false
                    end
                )

                return isAllHit
            end,
            [2] = function()
                local hasParry = false
                context:walkAllZhaoAttackInTheCombAttack(
                    function(i, zhaoAttack)
                        --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
                        zhaoAttack = zhaoAttack
                        if zhaoAttack:getHitType() == FightCommons.ATTACK_HIT_TYPE.PARRY then
                            hasParry = true
                            return true
                        end

                        return false
                    end
                )
            end,
            [3] = function()
                local hasDodged = false
                context:walkAllZhaoAttackInTheCombAttack(
                    function(i, zhaoAttack)
                        --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
                        zhaoAttack = zhaoAttack
                        if zhaoAttack:getHitType() == FightCommons.ATTACK_HIT_TYPE.DODGE then
                            hasDodged = true
                            return true
                        end

                        return false
                    end
                )
                return hasDodged
            end,
            [4] = function()
                local hasParrySpec = false
                context:walkAllZhaoAttackInTheCombAttack(
                    function(i, zhaoAttack)
                        --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
                        zhaoAttack = zhaoAttack
                        if zhaoAttack:getHitType() == FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC then
                            hasParrySpec = true
                            return true
                        end

                        return false
                    end
                )
                return hasParrySpec
            end,
            [5] = function()
                local hasDodgedSpec = false
                context:walkAllZhaoAttackInTheCombAttack(
                    function(i, zhaoAttack)
                        --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
                        zhaoAttack = zhaoAttack
                        if zhaoAttack:getHitType() == FightCommons.ATTACK_HIT_TYPE.DODGE_SPC then
                            hasDodgedSpec = true
                            return true
                        end

                        return false
                    end
                )
                return hasDodgedSpec
            end,
            ["default"] = function()
                error("BuffMakeOnTrigger:__checkAttackResult 未知的攻击结果限制条件 ： 【" .. tostring(condition) .. "】 buffId : " .. buff:getBuffId())
            end
        }
    )
end

--@desc: 检测攻击上下文限制条件是否满足
--@author:Seven
--@time:2024-02-29 20:02:15
--@buffConfs: [makeOnNodeFromConf , buff持有者限制，招式组合结果限制]
--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
--@return: true | false
function BuffMakeOnTrigger:__checkAttackContextConfine(buff, buffConfs, context)
    local ownerCheck = self:__checkBuffOwnerOnAttackContext(buff, buffConfs[2], context)

    local hitResultCheck = self:__checkAttackResult(buff, buffConfs[3], context)

    if ownerCheck == true and hitResultCheck == true then
        return true
    end

    return false
end

--@desc:OnAnyCombFinish
--@author:Seven
--@time:2024-02-29 19:59:27
--@buffConfs: [makeOnNodeFromConf , buff持有者限制，招式组合结果限制]
--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext] || [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
--@return:
function BuffMakeOnTrigger:__on12(buff, buffConfs, context)
    return self:__checkAttackContextConfine(buff, buffConfs, context)
end

function BuffMakeOnTrigger:__on25(buff, buffConfs, context)
    return self:__checkAttackContextConfine(buff, buffConfs, context)
end

return BuffMakeOnTrigger
000000000000000