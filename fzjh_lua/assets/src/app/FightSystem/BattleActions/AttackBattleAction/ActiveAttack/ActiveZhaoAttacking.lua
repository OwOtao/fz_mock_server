--[[
    author:Seven
    time:2022-11-17 17:13:43
    desc: 被动招式攻击中
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ABaseBattleAction = require("app.FightSystem.BattleActions.ABaseBattleAction")

--@SuperType [src.app.FightSystem.BattleActions.ABaseBattleAction#ABaseBattleAction]
local ActiveZhaoAttacking = {}

function ActiveZhaoAttacking:create(context)
    return ActiveZhaoAttacking.new():__init(context)
end

function ActiveZhaoAttacking:__init(context)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context
    return self
end

function ActiveZhaoAttacking:onInit()
end

function ActiveZhaoAttacking:onStart()
    FightUtil:printLog("招式攻击阶段 ：ActiveZhaoAttacking start")
    self.__duration = 0
    
    self.__currAttack = self.__context:getCurrZhaoAttack()

    self.__fight:notifyVeiwEvent(require("app.FightSystem.Veiws.ViewEvents.Events.ActiveZhaoAttackViewEvent"):create(self.__context, self.__currAttack))
end

function ActiveZhaoAttacking:onFinish()
    FightUtil:printLog("招式攻击阶段 ：ActiveZhaoAttacking finish")
end

function ActiveZhaoAttacking:onDestory()
end

function ActiveZhaoAttacking:onUpdate(ft)
    if self.__duration >= self.__currAttack:getDuration() then
        self:finish()
        return
    end

    self.__duration = self.__duration + ft
end

return newClass("ActiveZhaoAttacking", {ABaseBattleAction}, ActiveZhaoAttacking)
0000000000000000